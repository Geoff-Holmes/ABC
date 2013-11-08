function out = multiMigration(params, metaData)

% out = multiMigration(params, metaData)

paramNames = {'bias in', 'bias out', 'levy power', ' levy scale', ...
    'restriction', 'depletion'};

if nargin == 0
    out = paramNames;
else
    assert(length(paramNames) == length(params))
    
    bias1 = params(1);
    bias2 = params(2);
    pwr   = params(3);
    scl   = params(4);
    rstr  = params(5);
    depl  = params(6);
    
    x = metaData.initial;
    if size(x,1) > size(x,2), x = x'; end
    N = length(x);
    x = complex([x; zeros(metaData.T-1, N)]);
    
    dt = metaData.timeInc;
    
    % arbitrary min step length
    xmin = .1*scl;
    % max cut off
    xmax = 10*scl;
    
    % initialise receptor occupancy proportion for each cell
    R = metaData.initialOccupancy;
    % get restrction horizon
    L = metaData.restrictionHorizon;
    P = metaData.restrictionPoint;
    
    % time loop
    for t = 2:metaData.T
        % loop over all cells
        for n = 1:N
            % get levy flight step according to power law
            s = xmax + 1;
            while s > xmax
                u = rand();
                % inverse cdf for power law distribution
                s = xmin * (1 - u)^(-1/pwr);
            end
            % get isotropic direction
            q = rand() * 2 * pi;
            % incorporate angle to get x,y coords in complex form
            s = scl * s * exp(q*1i);

            % update position
            x(t, n) = x(t-1, n) + (bias2 - R(n) * bias1) + s;
            % check for boundary
            if real(x(t, n)) < 0
                x(t, n) = x(t, n) - real(x(t, n)); 
            else
                % check for an apply restriction
                if real(x(t-1,n)) <= P && real(x(t,n)) > P ...
                        && rand() < rstr;
                    % leave cell at restriction horizon
                    x(t,n) = x(t,n) - real(x(t,n)) + P;
                end
            end
   
            % update receptor levels
            R(n) = R(n) .* (1 - depl * max((L-real(x(t,n))),0)/L);
        end
    end
    
    out = x;
end
    

    
