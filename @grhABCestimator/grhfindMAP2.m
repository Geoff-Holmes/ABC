function obj = grhfindMAP2(obj, kernwidth)

% use opt toolbox to find MAP for joint parameter set for each 
% represented model

load(Rslt, 'phi', 'wts', 'Mod', 'MprmIdx', 'rng1', 'rngAdd', 'MODSN')

% make global so not required as args for cost function
global PHI WTS sig w pBnds

w = kernwidth;

models = unique(obj.models{end});
% MODSN = MODSN{end};

% optimisation options
options = optimset('Display', 'off', 'LargeScale', 'off');

% for each model represented in the posterior
for kk = 1:length(Models)
    
    mdl = Mods(kk);
    mdl;

    % get live parameter indices
    idx = MprmIdx{mdl};
    % get parameter sets and corresponding weights
    PHI = phi(Mod == mdl, idx);
    WTS = wts(Mod == mdl);
    
    clear x0 p 
   
    pBnds = rng1(:,idx);

    % get marginal parameter maxima for initial estimate
    for j = 1:length(idx)
        [f, xf] = ksdensity(PHI(:,j), 'Weights', WTS);
        [~, ind] = max(f);
        X0(j) = xf(ind);
    end

    sig = weightedcov(PHI, WTS)*eye(length(idx));
  
    % sig used to perturb starting point and 
    % also for kernel width in smoothPost
    
    % applying minization scheme from various starting points
    % which are randomly chosen
    for i = 1:33
        
        % perturb starting point from marginal maxes
        x0(i,:) = X0 + diag(sig)'.*randn(1,length(idx))/10;
        x0 = abs(x0);

        
        
       [p(i,:), ~] = fminunc(@fullPost, x0(i,:), options);
       
        if min(x0(i,:)==p(i,:)) == 1
            display('no movement')
        end
    end
    
    X0;
    p;
%     round(10*p)/10
%     round(100*p)/100
    % get results to various decimal places
    p1 = mode(round(10*p)/10);
    p2 = mode(round(100*p)/100);
    p3 = mode(round(100000*p)/100000);
    display(['Model : ' num2str(mdl) ' : ' ...
        num2str(round(MODSN(kk)*100)) '%'])
    display(num2str([p1;p2;p3]))
%     display(num2str(p2))

    
end

function F = fullPost(x)

global pBnds

F = smoothPost(x) + smoothPost(2*pBnds(1,:)-x) + smoothPost(2*pBnds(2,:)-x);



function f = smoothPost(x)

% evaluate kernel smoothed posterior at x for minimization

global PHI WTS sig w

sig1 = w*sig;

n = size(PHI);

assert(n(2) == length(x));

% get the distance of x from each phi
s0 = repmat(x, n(1), 1) - PHI;
% build exponential argument for gaussian
s1 = sig1\s0';
p1 = s0'.*s1;
% calculate gaussian
g = exp(-.5*sum(p1,1))/(2*pi*det(sig1))^(n(2)/2);
f = -sum(g.*WTS);

