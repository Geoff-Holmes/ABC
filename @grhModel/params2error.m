function error = params2error(obj, params)

% simulate model for param choice and return error from target obs

simObs = obj.func(params);

error = obj.metric(simObs, obj.targetObs);



