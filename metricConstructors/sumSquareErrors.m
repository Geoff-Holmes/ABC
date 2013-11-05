function obj = sumSquareErrors(obj, targetObs)

% obj = sumSquareErrors(obj, targetObs)

obj.custom.targetObs = targetObs;
obj.callHandle = @sumSquareErrors_Call


% function corresponding to distHandle handle
function d = sumSquareErrors_Call(metricObj, X)

% d = sumSquareErrors_Call(metricObj, X)

d = sum(sum((metricObj.custom.targetObs(:) - X(:)).^2));


