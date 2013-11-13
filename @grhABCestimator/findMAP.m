function obj = findMAP(obj, kernwidth)

% obj = findMAP(obj, kernwidth)

% use opt toolbox to find MAP for joint parameter set for each 
% represented model

global pBnds params weights sig w

if nargin == 2
    w = kernwidth;
else
    w = 1;
end

% optimisation options
options = optimset('Display', 'off', 'LargeScale', 'off');

% for each model represented in the posterior
for model = find(obj.results.modelPosterior)
    
    iModel = obj.candMods(model);
    Nparams = sum(iModel.pActive);

    % get parameter sets and corresponding weights
    temp = vertcat(obj.params{end}{:});
    params = temp(obj.results.modInds{model}, iModel.pActive);
    weights = obj.weights{end}(obj.results.modInds{model});
   
    pBnds = [iModel.priorLo(iModel.pActive);...
        iModel.priorHi(iModel.pActive)];

    % get marginal parameter maxima for initial estimate
    X0 = zeros(1,Nparams);
    for j = 1:Nparams
        [f, xf] = ksdensity(params(:,j), 'Weights', weights);
        [~, ind] = max(f);
        X0(j) = xf(ind);
    end

    sig = weightedcov(params, weights)*eye(Nparams);
  
    % sig used to perturb starting point and 
    % also for kernel width in smoothPost
    
    % applying minization scheme from various starting points
    % which are randomly chosen
    T = 33;
    x0 = zeros(T, Nparams);
    
    for i = 1:T
        
        % perturb starting point from marginal maxes
        x0(i,:) = X0 + diag(sig)'.*randn(1,Nparams)/10;
        x0 = abs(x0);

        
        
       [p(i,:), ~] = fminunc(@fullPost, x0(i,:), options);
       
        if min(x0(i,:)==p(i,:)) == 1
            display('no movement')
        end
    end

    % get results to various decimal places
    p1 = mode(round(10*p)/10);
    p2 = mode(round(100*p)/100);
    p3 = mode(round(100000*p)/100000);
    display(['Model : ' iModel.name ' : ' ...
        num2str(round(obj.results.modelPosterior(model)*100)) '%'])
    display(iModel.pNames(iModel.pActive))
    display(num2str([p1;p2;p3]))
%     display(num2str(p2))

obj.results.map{model} = [p1; p2; p3];

clear p
    
end

clear pBnds params weights sig w


function F = fullPost(x)

global pBnds

F = smoothPost(x) + smoothPost(2*pBnds(1,:)-x) + smoothPost(2*pBnds(2,:)-x);



function f = smoothPost(x)

% evaluate kernel smoothed posterior at x for minimization

global params weights sig w

sig1 = w*sig;

n = size(params);

assert(n(2) == length(x));

% get the distance of x from each params
s0 = repmat(x, n(1), 1) - params;
% build exponential argument for gaussian
s1 = sig1\s0';
p1 = s0'.*s1;
% calculate gaussian
g = exp(-.5*sum(p1,1))/(2*pi*det(sig1))^(n(2)/2);
f = -sum(g.*weights);

