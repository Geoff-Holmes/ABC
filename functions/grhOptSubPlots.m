function [s, t, waste] = grhOptSubPlots(N)

% optimise subplot rows and columns to achieve N subplots with min waste

s = floor(sqrt(N));

if ~mod(N, s) & N/s-s<3
    t = N/s;
else
    s = s-1;
    if ~mod(N, s) & N/s-s<3
        t = N/s;
    else
        [s,t] = grhOptSubPlots(N+1);
    end
end

waste = s*t-N;
