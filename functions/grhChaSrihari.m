function D = grhChaSrihari(A, B, cntrSpacing)

% D = grhHistDist(A, B, cntrs)
%
% compute distance between histograms
% using algorithm 1 from Cha & Srihari
% http://www.sciencedirect.com/science/article/pii/S0031320301001182
%
% each row of A and B is a set of histogram values
% final distance is summed over all rows
%
% cntrs added to cope with variable bar width histograms

D1 = A - B;
% allow for variable length bins
if nargin == 3
    D1 = D1 .* cntrSpacing;
end
D2 = cumsum(D1,2);
D3 = abs(D2);
D4 = sum(D3,2);
D = sum(D4);


% D = sum(sum(abs(cumsum(A-B,2)),2));