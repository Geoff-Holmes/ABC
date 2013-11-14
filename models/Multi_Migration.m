function x = Multi_Migration(params, metaData)

% x = multiMigration(params, metaData)

paramNames = {'bias in', 'bias out', 'levy power', ' levy scale', ...
    'restriction', 'depletion'};

if nargin == 0
    x = paramNames;
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
    
%     dt = metaData.timeInc;
    
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
        x(t, :) = x(t-1, :) + (bias2 - R * bias1) + s;
        
        % check for boundary
        x(t,:) = imag(x(t,:)) * 1i + real(x(t,:)) .* (real(x(t,:)) > 0);

        % check for and apply restriction
        if rstr
            test = real(x(t-1,:)) <= P & real(x(t,:)) > P;
            temp = rand(1, N) < rstr;
            test = test & temp;
            x(t, test) = P + imag(x(t, test)) * 1i; 
        end

        % update receptor levels
        R = R .* (1 - depl * max((L-real(x(t,:))),0)/L);
    end
end