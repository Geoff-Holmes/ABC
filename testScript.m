clear all

load data/diffusion1

M = grhModel(@diffusion, 0, 100);
N = grhModel(@testSim2, 10*ones(1,2),20*ones(1,2));

metaData.initial = obs(1,:);
metaData.timeInc = 1;
metaData.T       = size(obs,1);

E=grhABCestimator(obs, metaData, @testMetric2,[M N]);
E.firstIteration;

while E.p <= E.totalNits
    E.mainIteration;
end