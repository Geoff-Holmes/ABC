function out = Levy_Diffusion(params, metaData)

% out = Levy_Diffusion(params, metaData)

paramNames = {'power', 'scale'};
if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    
    pwr = params(1);
    scl = params(2);
    x = metaData.initial;
    if size(x,1) > size(x,2), x = x'; end
    N = length(x);
    dt = metaData.timeInc;
    
    % arbitrary min step length
    xmin = .1;
    % max cut off
    xmax = 10*scl;
    
    for t = 2:metaData.T
        for n = 1:N
            s = xmax + 1;
            while s > xmax
                u = rand();
                % inverse cdf for power law distribution
                s = xmin * (1 - u)^(-1/pwr);
            end
            % get direction
            q = rand() * 2 * pi;
            % incorporate angle to get x,y coords in complex form
            s = scl * s * exp(q*1i);

            % update
            x(t, n) = x(t-1, n) + s;
            if real(x(t, n)) < 0, x(t, n) = x(t, n) - real(x(t, n)); end
        end
    end
    
    out = x;
end