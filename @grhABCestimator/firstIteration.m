function obj = firstIteration(obj)

% obj = firstIteration(obj)

% select model from model prior
multiModFlag = length(obj.candMods) > 1;
if multiModFlag
    dummy = rand(1, obj.sizePop);
    modInd = sum(bsxfun(@ge, dummy, [0; obj.modelPrior(1:end-1)']));
    clear dummy
else
    modInd = ones(1, obj.sizePop);
end

% foster slicing for parallel
candMods = obj.candMods;
metaData = obj.metaData;
targetObs= obj.targetObs;

% parallel loop
parfor i = 1:obj.sizePop
    
    % get chosen model
    thisMod = candMods(modInd(i));
    % choose parameter set from prior for this model
    params{i} = thisMod.priorLo + thisMod.priorSt .* rand(1, thisMod.nParams);
    % simulate model with chosen parameter set
    simObs = thisMod.simltr(params{i}, metaData);
    errors(i) = obj.metric.call(simObs);
    
end

counter = obj.sizePop;

% calc tolerance schedule
obj.getToleranceSchedule(errors);

% get index of samples passing first tolerance test
Npassed = sum(errors < obj.tolSched(1));

while Npassed < obj.sizePop
    
    % do at least double the number of extra needed
    extra = max(10, 2*(obj.sizePop - Npassed));
    % select model from model prior
    dummy = rand(1, extra);
    if multiModFlag
        modInd = ...
            [modInd sum(bsxfun(@ge, dummy, [0; obj.modelPrior(1:end-1)']))];
    else
        modInd = [modInd ones(1, extra)];
    end
    clear dummy
    parfor i = counter+1:counter+extra
        % get chosen model
        thisMod = obj.candMods(modInd(i));
        % choose parameter set from prior for this model
        params{i} = thisMod.priorLo + thisMod.priorSt .* rand(1, thisMod.nParams);
        % simulate model with chosen parameter set
        simObs = thisMod.simltr(params{i}, obj.metaData);
        errors(i) = obj.metric.call(simObs);
    end
    counter = counter + extra;
    Npassed = sum(errors < obj.tolSched(1));

end  

% get successful samples
passedInd = find(errors < obj.tolSched(1));
% passedInd = passedInd(1:obj.sizePop);

% store models and parameters
obj.models{1} = modInd(passedInd);
obj.params{1} = {params{passedInd}};
obj.sizeGens(1) = length(passedInd);

% calculate Beaumont weights
if obj.Bwts
    weights = (1 - (errors(passedInd)/obj.tolSched(1)).^2)/obj.tolSched(1);
    % normalise and store
    obj.weights{1} = weights/sum(weights);
else
    obj.weights{1} = ones(1, sizeGens(1));
end

% update iteration number
obj.p = obj.p + 1;


    


