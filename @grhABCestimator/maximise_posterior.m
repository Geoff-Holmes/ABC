function [MAP_params, meanW] = maximise_posterior(obj, covFac)

% find the MAP parameter set from the weighter sample provided by the ABC
% valid for a single model estimation

try
    assert(numel(unique(obj.models{end})) == 1);
catch ex
    display('Method only valid if a single model is represented in the posterior')
end

% get final weights and params
wts = obj.weights{end}';
pms = vertcat(obj.params{end}{:});

% get weighted mean
meanW = sum(bsxfun(@times, pms, wts));

deBias = 1/(1 - sum(wts.^2));
subMn = bsxfun(@times, sqrt(wts), bsxfun(@minus, pms, meanW));

% get weighted covariance
covW = deBias * subMn' * subMn;

x0 = mvnrnd(meanW, covW/3);
options = optimoptions('fminunc','Algorithm','trust-region', 'GradObj','on');%, 'tolFun', 1e-12);
MAP_params = fminunc(@(x) get_posterior_withGrad(x, covW/covFac, wts, pms), x0, options);

end

function [posterior, grad] = get_posterior_withGrad(x, covW, wts, pms)
% construct posterior from samples using sandpiles shaped like the weighted
% covariance
posterior = 0;
for i = 1:size(pms, 1)
    posterior = posterior - wts(i) * mvnpdf( x, pms(i,:), covW);
end

grad = 0;
for i = 1:size(pms, 1)
    grad = grad - (-wts(i) * mvnpdf( x, pms(i,:), covW) * (covW \ (x - pms(i,:))'));
end
end

