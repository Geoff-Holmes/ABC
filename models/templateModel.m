function out = templateModel(params, metaData, create)

% out = templateModel(params, metaData, create)

paramNames = {'param_1', 'param_2'};
if nargin == 0
    out = paramNames;
else
    
    p1 = params(1);
    p2 = params(2);
    
    if nargin == 3 && create
        % make a test dataset 
        % creation simulation code
        out = ... ;
        
    else
        % one step ahead prediction for each time point prior to last
        x(1) = metaData.initialObs;
        out = ...;
    end

end