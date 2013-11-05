function out = simpleAR(params, metaData, create)

% out = simpleAR(params, metaData, create)

paramNames = {'a'};
if nargin == 0
    out = paramNames;
else
    
    a = params(1);
    
    if nargin == 3 && create
        % make a test dataset
        if length(params) > 1
            b = params(2);
        else
            b = 1;
        end
        x = metaData.initial;
        if size(x,1) > size(x,2), x = x'; end
        N = length(x);
        for t = 2:metaData.T
            x(t,:) = a * x(t-1,:) + b * randn(1,N);
        end

        out = x;
        
    else
        % one step ahead prediction for each time point prior to last
        x = metaData.targetObs';
        out = [x(1) a * x(1:metaData.T-1)];
    end

end