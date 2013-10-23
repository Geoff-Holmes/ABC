
clear all

obs = importdata('data/AggOrig.mat');

M = grhModel(@diffusion, 0, 250);
N = grhModel(@driftDiffusion, [0 0], [20 250]);

metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

E=grhABCestimator(obs, metaData, @population_ChaSrihari, [M N]);
clear obs metaData M N

tic

E.firstIteration;

while E.p <= E.totalNits
    iteration = E.p
    E.mainIteration;
end

toc

p = E.params{end};
grhWeightedHist([p{:}], E.weights{end}, 10)
xlim([E.candMods.priorLo E.candMods.priorHi])