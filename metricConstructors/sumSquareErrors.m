function obj = sumSquareErrors(obj, targetObs)

% obj = sumSquareErrors(obj, targetObs)

if iscell(targetObs)
    obj.custom.targetObs = cell2mat(targetObs);
else
    obj.custom.targetObs = targetObs;
end

obj.callHandle = @sumSquareErrors_Call


% function corresponding to obj.callHandle
function d = sumSquareErrors_Call(metricObj, X)

% d = sumSquareErrors_Call(metricObj, X)

d = sum(sum((metricObj.custom.targetObs(:) - X(:)).^2));


