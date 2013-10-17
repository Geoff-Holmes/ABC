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
    end
end

% get cumulative weights across all samples
cumWts = cumsum(obj.weights{obj.p-1});

% counter for accepted samples
Npassed = 0;

while Npassed < obj.sizePop
    
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
        
      
        % pick a random parameter set for this model acc to weights
        pk = find(cumWtsMod{model} >= rand(), 1, 'first');
        % generate a perturbed parameter according to proposal disn
        paramProp = abs(normrnd(pArray{model}(pk,:), sdW{model}));
        
        % check for boundaries on paramProp and regenerate if necessary
        while sum(paramProp >= obj.candMods(model).priorLo) ...
                < obj.candMods(model).nParams ...
                || sum(paramProp <= obj.candMods(model).priorHi) ...
                < obj.candMods(model).nParams 
            paramProp = abs(normrnd(pArray{model}(pk,:), sdW{model})); 
        end
           
        % simulate model / parameter set pair
        simObs = obj.candMods(model).simltr(paramProp);
        error  = obj.metric(simObs, obj.targetObs);
        if error < obj.tolSched(obj.p)
            models(i) = model;
            params{i} = paramProp;
        end
    end
    
    % identify which sample passed error tolerance test and how many
    passed = ~cellfun(@isempty, params);
    NnewPassed = sum(passed);
    
    % store those that passed
    idx = Npassed+1:Npassed+NnewPassed;
    obj.models{obj.p}(idx) = models(passed);
    obj.params{obj.p}(idx) = {params{passed}};
    
    Npassed = Npassed + NnewPassed;
end

% store size of population
obj.sizeGens(obj.p) = Npassed;