function out = AR2(params, metaData, create)

% out = AR2(params, metaData, create)

paramNames = {'a1', 'a2'};
if nargin == 0
    out = paramNames;
else
    
    a1 = params(1);
    a2 = params(2);
    
    if nargin == 3 && create
        % make a test dataset
        if length(params) > 2
            b = params(3);
        else
            b = 1;
        end
        x = metaData.initial;
        if size(x,1) > size(x,2), x = x'; end
        for t = 3:metaData.T
            x(t) = a1 * x(t-1) + a2 * x(t-2) + b * randn(1);
        end

        out = x';
        
    else
        % one step ahead prediction for each time point prior to last
        x = metaData.targetObs';
        out = [x(1:2) a1 * x(2:metaData.T-1) + a2 * x(1:metaData.T-2)];
    end

end