function [obj, params] = mainIteration(obj)

% obj = mainIteration(obj)

% get indices of models still represented in last generation
liveModels = unique(obj.models{obj.p-1});

% get model perturbation probs
modMarks = linspace(0, 1, length(liveModels));
modMarks = modMarks(2:end);

% get standard deviation for parameter perturbation kernel
% corr variance is twice weighted variance of last parameter generation
for model = liveModels % loop over model indices
    
    % get indices of samples representing this model
    ind = obj.models{obj.p-1} == model;
    
    % get cumsum of wts for this model
    temp = obj.weights{obj.p-1}(ind);
    temp = temp / sum(temp);
    cumWtsMod{model} = cumsum(temp);
 
    if length(ind) > 1 % otherwise leave as before
        
        % get parameters as array
        pArray{model} = vertcat(obj.params{obj.p-1}{ind});
        
        % weighted mean
        muW = sum(bsxfun(@times, obj.weights{obj.p-1}(ind)', pArray{model}));
    
        % weighted covariance
        sdW{model} = sqrt(2 * sum(bsxfun(@times, obj.weights{obj.p-1}(ind)', ...
            bsxfun(@minus, pArray{model}, muW).^2)));
        
        % store indices for this model
        modIndLast{model} = ind;
        
    end
end

% get cumulative weights across all samples
cumWts = cumsum(obj.weights{obj.p-1});

% counter for accepted samples
Npassed = 0;

while Npassed < obj.sizePop
    
    % try new samples in 'extra' parallel batches
    extra = max(10, 2 * (obj.sizePop - Npassed));
    
    parfor i = 1:extra
        
        % pick a model from current marginal
        dummy = rand();
        pk = find(cumWts >= dummy, 1, 'first');
        model = obj.models{obj.p-1}(pk);
        
        % perturb model if there is more than one left
        if length(liveModels) > 1
            if rand() > obj.prKeepMod;
                pk1 = find(modMarks >= rand(), 1, 'first');
                mTemp = liveModels(liveModels ~= model);
                model = mTemp(pk1);           
            end
        end
        
        % shortcut to model
        iModel = obj.candMods(model);
        
        % pick a random parameter set for this model acc to weights
        pk = find(cumWtsMod{model} >= rand(), 1, 'first');
        % generate a perturbed parameter according to proposal disn
        paramProp = abs(normrnd(pArray{model}(pk,:), sdW{model}));
        
        % check for boundaries on paramProp and regenerate if necessary
        while sum(paramProp >= iModel.priorLo) ...
                < iModel.nParams ...
                || sum(paramProp <= iModel.priorHi) ...
                < iModel.nParams 
            paramProp = abs(normrnd(pArray{model}(pk,:), sdW{model})); 
        end
           
        % simulate model / parameter set pair
        simObs = iModel.simltr(paramProp, obj.metaData);
        err  = obj.metric(simObs, obj.targetObs);
        if err < obj.tolSched(obj.p)
            models(i) = model;
            params{i} = paramProp;
            errors(i) = err;
        end
    end % parfor
    
    % identify which sample passed error tolerance test and how many
    passedInd = ~cellfun(@isempty, params);
    NnewPassed = sum(passedInd);
    
    % store those that passed
    idx = Npassed+1:Npassed+NnewPassed;
    obj.models{obj.p}(idx) = models(passedInd);
    obj.params{obj.p}(idx) = {params{passedInd}};
    
    if obj.Bwts
        weights(idx) = (1 - ...
            (errors(passedInd)/obj.tolSched(obj.p)).^2)/obj.tolSched(obj.p);
    else
        weights(idx) = 1;
    end
    
    % update counter
    Npassed = Npassed + NnewPassed;
end % while

% main weight update
% get indices of models still represented in new generation
liveModsNew = unique(obj.models{obj.p});

for model = liveModsNew
    
    % shortcut to model
    iModel = obj.candMods(model);
    
    % get indices of samples representing this model
    ind = obj.models{obj.p} == model;
    
    % get number of samples for this model in both gens
    Nnew = sum(ind);
    Nold = sum(modIndLast{model});
    
    % convert to numbers
    ind = find(ind);
    ind0 = find(modIndLast{model});
    
    % initialise
    K = zeros(Nnew,Nold);
    
    % weight calculations
    for i = 1:Nnew
        for j = 1:Nold
            K(i,j) = mvnpdf(obj.params{obj.p}{ind(i)}, ...
            obj.params{obj.p-1}{ind0(j)}, sdW{model}.^2);
        end
        wUp(ind(i)) = ...
            weights(ind(i)) / sum(obj.weights{obj.p-1}(ind0) .* K(i,:));
        
%         wUp(ind(i)) = weights(ind(i))*prod(betapdf((obj.params{obj.p}{ind(i)}-iModel.priorLo) ...
%             ./iModel.priorSt, ones(1,iModel.nParams), ones(1,iModel.nParams))) / sum(obj.weights{obj.p-1}(ind0) .* K(i,:));
    end
    
    obj.weights{obj.p} = wUp / sum(wUp);
    
end
    
% store size of population
obj.sizeGens(obj.p) = Npassed;
% update iteration count
obj.p = obj.p + 1; 