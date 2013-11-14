function out = Drift_Diffusion(params, metaData)

% out = driftDiffusion(params, metaData)

paramNames = {'drift', 'diffusivity'};
if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    
    d = params(1);
    D = params(2);
    x = metaData.initial;
    if size(x,1) > size(x,2), x = x'; end
    N = length(x);
%     dt = metaData.timeInc;
    
    for t = 2:metaData.T
        x(t,:) = x(t-1,:) + d + randn(1,N) * sqrt(2 * D);
        x(t,:) = x(t,:) .* (x(t,:) > 0); 
    end
    
    out = x;
end