function [obj, params] = mainIteration(obj)

% obj = mainIteration(obj)

tic;
display(['iteration : ' num2str(obj.it)])

% store state of random number gen at start of this iteration
obj.rng(obj.it) = rng;

% get number of cores available
nCores = matlabpool('size');

% get indices of models still represented in last generation
liveModels = unique(obj.models{obj.it-1});

% get model perturbation probs
modMarks = linspace(0, 1, length(liveModels));
modMarks = modMarks(2:end);

% initialise
cumWtsMod = cell(1,length(liveModels));
pArray    = cell(1,length(liveModels));
sdW       = cell(1,length(liveModels));
modIndLast= cell(1,length(liveModels));

display('Calculating proposal densities')
% get standard deviation for parameter perturbation kernel
% corr variance is twice weighted variance of last parameter generation
for model = liveModels % loop over model indices
    
    %shortcut
    iModel = obj.candMods(model);
    
    % get indices of samples representing this model
    ind = obj.models{obj.it-1} == model;

    % store indices for this model
    modIndLast{model} = ind;
    
    % get cumsum of wts for this model
    temp = obj.weights{obj.it-1}(ind);
    temp = temp / sum(temp);
    cumWtsMod{model} = cumsum(temp);
 
    % get parameters as array
    temp = vertcat(obj.params{obj.it-1}{ind});
    pArray{model} = temp(:, iModel.pActive);
    
    if sum(ind) > 1 
       
        % weighted mean
        muW = sum(...
            bsxfun(@times, obj.weights{obj.it-1}(ind)', pArray{model}));
    
        % weighted covariance
        sdW{model} = sqrt(...
            2 * sum(bsxfun(@times, obj.weights{obj.it-1}(ind)', ...
            bsxfun(@minus, pArray{model}, muW).^2)));
    else
        sdW{model} = iModel.priorSt(iModel.pActive)/2;
    end
end

% get cumulative weights across all samples
cumWts = cumsum(obj.weights{obj.it-1});

% counter for accepted samples
Npassed = 0;

flag = 0; fac = 3; cntr = 0;% for determining parallel batch sizes

while Npassed < obj.sizePop
        
    flag = flag + 1;
    
    % try new samples in 'extra' parallel batches
    if flag == 1 % first try a rough guess prob. on the low side
        extra = fac * obj.sizePop;
    else    
        if flag > 1
            % calculate acceptance rate so far
            acceptanceRate = (Npassed / cntr);
            extra = max(5 * nCores, ...
                ceil((obj.sizePop - Npassed) / acceptanceRate));
        end
    end
    
    cntr = cntr + extra;
    
    % initialise
    params  = cell(1, extra);
    models  = zeros(1, extra);
%     weights = zeros(1, extra);
    errors  = zeros(1, extra);
    
    display(['Running ' num2str(extra) ' sims'])
    
    parfor i = 1:extra

        % progress
        if ~mod(i,1000)
            display(...
                ['Starting simulation ' num2str(i) ' of ' num2str(extra)])
        end
        
        % pick a model from current marginal
        dummy = rand();
        pk = find(cumWts >= dummy, 1, 'first');
        model = obj.models{obj.it-1}(pk);
        
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
        paramProp = zeros(1,iModel.nParams);
        paramProp(iModel.pActive) = normrnd(pArray{model}(pk,:), sdW{model})
        
        % check for boundaries on paramProp and regenerate if necessary
        while sum(paramProp >= iModel.priorLo) ...
                < iModel.nParams ...
                || sum(paramProp <= iModel.priorHi) ...
                < iModel.nParams 
            paramProp(iModel.pActive) = normrnd(pArray{model}(pk,:), sdW{model}); 
        end
           
        % simulate model / parameter set pair
        simObs = iModel.simltr(paramProp, obj.metaData);
        err  = obj.metric.call(simObs);
        if err < obj.tolSched(obj.it)
            models(i) = model;
            params{i} = paramProp;
            errors(i) = err;
        end
    end % parfor
    
    % update total sims count for info
    obj.totalSims(obj.it)...
        = obj.totalSims(obj.it) + extra;
    
    % identify which samples passed error tolerance test and how many
    passedInd = ~cellfun(@isempty, params);
    NnewPassed = sum(passedInd);
    
    % store those that passed
    idx = Npassed+1:Npassed+NnewPassed;
    obj.models{obj.it}(idx) = models(passedInd);
    obj.params{obj.it}(idx) = {params{passedInd}};
    
    if obj.Bwts
        weights(idx) = (1 - (errors(passedInd)/...
            obj.tolSched(obj.it)).^2)/obj.tolSched(obj.it);
    else
        weights(idx) = 1;
    end
    
    % update counter
    Npassed = Npassed + NnewPassed;
end % while

display('Calculating weights')
% main weight update
% get indices of models still represented in new generation
liveModsNew = unique(obj.models{obj.it});

% initialise
wUp = zeros(1, Npassed);

for model = liveModsNew

    % shortcut to model
    iModel = obj.candMods(model);
    
    % get correct function for proposal density
    if iModel.nParams == 1
        densityHandle = @normpdf;
    else
        densityHandle = @mvnpdf;
    end
    
    % get indices of samples representing this model
    ind = obj.models{obj.it} == model;
    
    % get number of new samples for this model
    Nnew = sum(ind);
    
    % convert to numbers
    ind = find(ind);
    ind0 = find(modIndLast{model});
    
    % initialise
    dummy = zeros(1,Nnew);
    
    % enable slice
    modWeights = weights(ind);
    
    % weight calculations
    parfor i = 1:Nnew
        
%         K = densityHandle(obj.params{obj.it}{ind(i)}, ...
%             cell2mat(obj.params{obj.it-1}(ind0)'), sdW{model}.^2)';
%         dummy(i) = ...
%             modWeights(i) / sum(obj.weights{obj.it-1}(ind0) .* K); 

    % assumes uniform prior
        temp = cell2mat(obj.params{obj.it-1}(ind0)');
        dummy(i) = ...
            modWeights(i) / sum(obj.weights{obj.it-1}(ind0) .* ...
            densityHandle(obj.params{obj.it}{ind(i)}(iModel.pActive), ...
            temp(:, iModel.pActive), sdW{model}.^2)');
        
%     % old code for beta prior
%     wUp(ind(i)) = weights(ind(i))*prod(betapdf(...
%         (obj.params{obj.it}{ind(i)}-iModel.priorLo)./iModel.priorSt,...
%         ones(1,iModel.nParams), ones(1,iModel.nParams)))...
%         / sum(obj.weights{obj.it-1}(ind0) .* K(i,:));

    end
    
    wUp(ind) = dummy;
    
end

% normalise and store weights
obj.weights{obj.it} = wUp / sum(wUp);
      
% store size of population
obj.sizeGens(obj.it) = Npassed;

% update run time counter
obj.runTime(obj.it) = toc;

% update iteration count
obj.it = obj.it + 1; 

% final iteration tasks
if obj.it > obj.totalNits
    obj.runTime(obj.totalNits+1) = sum(obj.runTime);
    hrs = floor(obj.runTime / 3600);
    rem = obj.runTime - hrs*3600;
    mins = floor(rem / 60);
    secs = round(rem - mins*60);
    obj.runTime = [num2str(hrs) ' hrs ' num2str(mins)...
        ' mins ' num2str(secs) ' secs'];
end