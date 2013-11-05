function plotModelMarginalPosterior(obj)

% plotModelMarginalPosterior(obj)

figure
bar(obj.results.modelPosterior)
ylabel('Normalised count')
xlim([0 length(obj.candMods)+1])
set(gca, 'XTickLabel', {obj.candMods(:).name});
title('Marginal posterior distribution over models')