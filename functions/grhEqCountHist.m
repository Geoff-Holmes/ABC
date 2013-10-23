function [cnt, edgs] = grhEqCountHist(X, bns, plt)

% [cnt, edgs] = grhEqCountHist(X, bns, plt)
%
% create a histogram which has equal count in each bin

if nargin < 2
    bns = 10;
end

% get sample info
X = sort(X);
N = length(X);

% get shortest distance between any two samples and decrease
xtra = min(X(2:end) - X(1:end-1)) / 10^5;

% get number of samples in each bin
n = N / bns;

% get indicies of all last samples in each bin
idx = round([1 (1:bns) * n]);
% get these samples
edgs = X(idx);

% add extra on to all but first to ensure even numbers in each bin
edgs(2:end) = edgs(2:end) + xtra;

% get each customised bin width
wdths = edgs(2:end)-edgs(1:end-1);

% apply edge based histogram
cnt = histc(X, edgs);
% don't need final (zero) value
cnt = cnt(1:end-1);

if nargin == 3 && plt

figure
for i = 1:bns
    
    if cnt(i)>0
        r(i) = rectangle('Position', [edgs(i) 0 wdths(i), cnt(i)/wdths(i)]);
        set(r(i), 'faceColor', 'b')
    end

end
end
