function obj = firstIteration(obj)

% obj = firstIteration(obj)

tic;
display(['iteration : ' num2str(obj.it)])

% get number of cores available
nCores = matlabpool('size');

% set multiple of target population size for first batch
factor = 2;

% select model from model prior
multiModFlag = length(obj.candMods) > 1;
if multiModFlag
    dummy = rand(1, factor * obj.sizePop);
    modInd = sum(bsxfun(@ge, dummy, [0; obj.modelPrior(1:end-1)']));
    clear dummy
else 
    modInd = ones(1, factor * obj.sizePop);
end

% foster slicing for parallel
candMods = obj.candMods;
metaData = obj.metaData;
targetObs= obj.targetObs;

firstBatch = factor * obj.sizePop;

display(['Running ' num2str(firstBatch) ' sims'])

% parallel loop
parfor i = 1:firstBatch
    
    % progress
    if ~mod(i,1000)
        display(['Starting simulation ' num2str(i) ' of ' num2str(2*obj.sizePop)])
    end

    % get chosen model
    iModel = candMods(modInd(i));
    % choose parameter set from prior for this model
    params{i} = iModel.priorLo + iModel.priorSt .* rand(1, iModel.nParams);
    % simulate model with chosen parameter set
    simObs = iModel.simltr(params{i}, metaData);
    errors(i) = obj.metric.call(simObs);
    
end

counter = firstBatch;

% calc tolerance schedule
obj.getToleranceSchedule(errors);

% get number of samples passing first tolerance test
Npassed = sum(errors < obj.tolSched(obj.it));

while Npassed < obj.sizePop
    
    % calculate acceptance rate so far
    acceptanceRate = (Npassed / counter);
    % use rate to estimate how many more sims needed
    extra = max(5 * nCores, ...
        ceil((obj.sizePop - Npassed) / acceptanceRate));
            
    % select model from model prior
    if multiModFlag
        modInd = [modInd sum(bsxfun(@ge, rand(1, extra), ...
            [0; obj.modelPrior(1:end-1)']))];
    else
        modInd = [modInd ones(1, extra)];
    end

    display(['Running ' num2str(extra) ' sims'])

    parfor i = counter+1:counter+extra
        
        % progress
        if ~mod(i,1000)
            display(['Starting simulation ' ...
                num2str(i-ceil(counter/1000)*1000) ' of ' num2str(extra)])
        end
        
        % get chosen model
        iModel = obj.candMods(modInd(i));
        % choose parameter set from prior for this model
        params{i} = iModel.priorLo + iModel.priorSt .* rand(1, iModel.nParams);
        % simulate model with chosen parameter set
        simObs = iModel.simltr(params{i}, obj.metaData);
        errors(i) = obj.metric.call(simObs);
    end
    counter = counter + extra;
    Npassed = sum(errors < obj.tolSched(obj.it));

end  

% update total sim count for info
obj.totalSims(obj.it) = counter;

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

% update run time counter
obj.runTime(obj.it) = toc;

% update iteration number
obj.it = obj.it + 1;
