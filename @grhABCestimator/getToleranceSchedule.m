function obj = getToleranceSchedule(obj, Ebase, scheme, maxPrctile, minPrctile)

% obj = getToleranceSchedule(obj, scheme, maxPrctile, minPrctile)
% 
% scheme can be 'exponential', 'linear'
% maxPrctile
% minPrctile

if nargin < 5, minPrctile = 1;
    if nargin < 4, maxPrctile = 50;
        if nargin < 3, scheme = 'exponential';
        end
    end
end

N = obj.totalNits;
et(1) = prctile(Ebase, maxPrctile);
et(N) = prctile(Ebase, minPrctile);

if strcmp(scheme, 'linear')
        et = linspace(et(1), et(N), N);
else
%     if strcmp(scheme,'exponential')
    a = (log(et(1))-log(et(N)))/N;
    i = 2:N-1;
    et(i) = et(1)*exp(-a*(i));
%     end
end

obj.tolSched = et;