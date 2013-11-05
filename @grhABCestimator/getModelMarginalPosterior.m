function obj = getModelMarginalPosterior(obj)

% obj = getModelMarginalPosterior(obj)

mods = obj.models{end};
wts  = obj.weights{end};

modelNames = {};

for i = 1:length(obj.candMods)
    
%     modelNames{i} = obj.candMods(i).name;
    inds = mods == i;
    modProbs(i) = sum(wts(inds));
    modInds{i} = inds;
    
end

obj.results.modelPosterior = modProbs;
obj.results.modInds = modInds;

% figure
% bar(modProbs)
% ylabel('Normalised count')
% xlim([0 length(obj.candMods)+1])
% set(gca, 'XTickLabel', modelNames);
% title('Marginal posterior distribution over models')