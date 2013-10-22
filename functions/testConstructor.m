function obj = testConstructor(obj, targetObs)

% obj = testConstructor(obj)

% shortcuts
Nobs = length(targetObs);

if ~iscell(targetObs)
    targetObs = num2cell(targetObs, 2);
end

parfor i = 1:size(targetObs,1)

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
obj.distHandle = @testDistance;


% function corresponding to distHandle handle
function d = testDistance(obj, X)

% d = testDistance(obj, X)

% shortcuts
cntO = obj.custom.cnt;
edgs = obj.custom.edgs;
cntrSpacing = obj.custom.cntrs;

parfor i = 1:obj.Nobs
    
    % get count of sim data in bins corr to those for target obs
    cntX = histc(X(i,:), edgs(i,:));
    % normalise
    cntX = cntX / sum(cntX);
    % calculate the error for this obs time
    err(i) = grhChaSrihari(cntO(i,:), cntX(1:end-1), cntrSpacing(i,:));
    
end

% add errors up over all obs times
d = sum(err);




