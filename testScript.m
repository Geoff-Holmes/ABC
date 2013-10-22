
clear all

obs = importdata('data/AggOrig.mat');

M = grhModel(@diffusion, 0, 250);
% N = grhModel(@testSim2, 10*ones(1,2),20*ones(1,2));

metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

E=grhABCestimator(obs, metaData, @testConstructor, [M]);
clear obs metaData M N

E.firstIteration;

while E.p <= E.totalNits
    E.p
    E.mainIteration;
end

p = E.params{end};
grhWeightedHist([p{:}], E.weights{end}, 10)
xlim([E.candMods.priorLo E.candMods.priorHi])