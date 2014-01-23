function obj = templateMetricConstructor(obj, targetObs)

% obj = templateMetricConstructor(obj, targetObs)

% store the targetObs within the 'custom' field of the metric object
obj.custom.targetObs = targetObs;

% alternatively do some processing to the target obs first and then store
% the summary output you want within the custom field of the metric object
% e.g.
% Nobs = length(targetObs);
% for i = 1:Nobs
%     hst = hist(target(Obs(i,:));
% end
% obj.custom.Nobs = Nobs;
% obj.custom.hst  = hst;

% point the metric object towards the associated calling function which is
% defined in the second function below 
obj.callHandle = @templateMetric_Call


% function corresponding to obj.callHandle in function above
function d = templateMetric_Call(metricObj, X)

% d = templateMetric_Call(metricObj, X)

% use observation / summary quantities stored in custom field of the metric
% object to calculate the distance between simulated obs / summary stats X
% and the target ones
% e.g. for a simple sum of sqaured errors metric

d = sum(sum((metricObj.custom.targetObs(:) - X(:)).^2));


