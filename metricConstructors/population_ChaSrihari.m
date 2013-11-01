function obj = population_ChaSrihari(obj, targetObs)

% obj = population_ChaSrihari(obj, targetObs)

% shortcuts
Nobs = length(targetObs);

if ~iscell(targetObs)
    targetObs = num2cell(targetObs, 2);
end

parfor i = 1:Nobs

    % get equal count histogram and edges for each time obs
    [iCnt, iEdgs] = grhEqCountHist(targetObs{i});
    % normalise
    cnt(i,:) = iCnt / sum(iCnt);    
    % get spacing between centres of bins
    cntrSpacing(i,:) = (iEdgs(1:end-1) + iEdgs(2:end)) / 2;
    % need intermediate step for parallel so tidy up
    edgs(i,:) = iEdgs;

end
   
% add to metric object
obj.Nobs = Nobs;
obj.custom.cnt = cnt;
obj.custom.edgs = edgs;
obj.custom.cntrs = cntrSpacing;
obj.callHandle = @population_ChaSrihari_Call;


% function corresponding to distHandle handle
function d = population_ChaSrihari_Call(estimatorObj, X)

% d = population_ChaSrihari_Call(estimatorObj, X)

% shortcuts
cntO = estimatorObj.custom.cnt;
edgs = estimatorObj.custom.edgs;
cntrSpacing = estimatorObj.custom.cntrs;

for i = 1:estimatorObj.Nobs
    
    % get count of sim data in bins corr to those for target obs
    cntX = histc(X(i,:), edgs(i,:));
    % normalise
    cntX = cntX / sum(cntX);
    % calculate the error for this obs time
    err(i) = grhChaSrihari(cntO(i,:), cntX(1:end-1), cntrSpacing(i,:));
    
end

% add errors up over all obs times
d = sum(err);
