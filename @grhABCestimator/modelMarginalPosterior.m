function modelMarginalPosterior(obj)

mods = obj.models{end};
wts  = obj.weights{end};

for i = 1:length(obj.candMods)
    
    inds = mods == i;
    modProbs(i) = sum(wts(inds));
    
end

bar(modProbs)
ylabel('Normalised count')
title('Marginal posterior distribution over models')