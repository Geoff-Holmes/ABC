function [out] = testSim1(params, metaData)

paramNames = {'param1', 'param2', 'param3'};
if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    out = prod(params);
    
end




