function out = Pure_Diffusion(params, metaData)

% out = Pure_Diffusion(params, metaData)

paramNames = {'diffusivity'};
if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    
    D = params;
    x = metaData.initial;
    if size(x,1) > size(x,2), x = x'; end
    N = length(x);
%     dt = metaData.timeInc;
    
    for t = 2:metaData.T
        x(t,:) = x(t-1,:) + randn(1,N) * sqrt(2 * D);
        x(t,:) = x(t,:) .* (x(t,:) > 0); 
    end
    
    out = x;
end