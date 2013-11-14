function x = Drift_Levy_Diffusion(params, metaData)

% out = Levy_Diffusion(params, metaData)

paramNames = {'power', 'scale', 'drift'};
if nargin == 0
    x = paramNames;
else
    assert(length(paramNames) == length(params))
    
    pwr = params(1);
    scl = params(2);
    drift = params(3);
    
    x = metaData.initial;
    if size(x,1) > size(x,2), x = x'; end
    N = length(x);
    x = complex([x; zeros(metaData.T-1, N)]);
    
    % arbitrary min step length
    xmin = .1*scl;
    % max cut off
    xmax = 10*scl;
    
    for t = 2:metaData.T
        u = rand(1,N);
        % inverse cdf for power law distribution
        s = xmin * (1 - u) .^ (-1/pwr);
        % find steps over limit xmax
        ind = s > xmax;
        % recalculate as necessary
        Nfailed = sum(ind);
        while Nfailed
            u = rand(1,Nfailed);
            s(ind) = xmin * (1 - u) .^ (-1/pwr);     
            ind = s > xmax;
            Nfailed = sum(ind);
        end
        
        % get isotropic direction
        q = rand(1, N) * 2 * pi;
        % incorporate angle to get x,y coords in complex form
        s = scl * s .* exp(q*1i);

        % update position
        x(t, :) = x(t-1, :) + s + drift;
        
        % check for boundary
        x(t,:) = imag(x(t,:)) * 1i + real(x(t,:)) .* (real(x(t,:)) > 0);
    end
end