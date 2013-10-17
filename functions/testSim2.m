function [out] = testSim2(params)

paramNames = {'param1', 'param2'};

if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    out = sum(params);
    
end




