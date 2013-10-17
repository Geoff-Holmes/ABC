function obj = firstIteration(obj)


% select model from model prior
dummy = rand(1, obj.sizePop);
modInd = sum(bsxfun(@ge, dummy, [0; obj.modelPrior(1:end-1)']));
clear dummy



% parallel loop
parfor i = 1:obj.sizePop
    
    % get chosen model
    thisMod = obj.candMods(modInd(i));
    % choose parameter set from prior for this model
    params{i} = thisMod.priorLo + thisMod.priorSt .* rand(1, thisMod.nParams);
    % simulate model with chosen parameter set
    simObs = thisMod.simltr(params{i});
    errors(i) = obj.metric(simObs, obj.targetObs);
    
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
    modInd = [modInd sum(bsxfun(@ge, dummy, [0; obj.modelPrior(1:end-1)']))];
    parfor i = counter+1:counter+extra
        % get chosen model
        thisMod = obj.candMods(modInd(i));
        % choose parameter set from prior for this model
        params{i} = thisMod.priorLo + thisMod.priorSt .* rand(1, thisMod.nParams);
        % simulate model with chosen parameter set
        simObs = thisMod.simltr(params{i});
        errors(i) = obj.metric(simObs, obj.targetObs);
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
parfor i = 1:obj.sizeGens(1)
    weights(i) = ...
        (1 - (errors(passedInd(i))/obj.tolSched(1)).^2)/obj.tolSched(1);
end

% normalise and store
obj.weights{1} = weights/sum(weights);

% update iteration number
obj.p = obj.p + 1;


    


