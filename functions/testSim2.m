function [out] = testSim2(params, metaData)

paramNames = {'param1', 'param2'};

if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    out = sum(params);
    
end




