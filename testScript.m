clear all
M = grhModel(@testSim1, zeros(1,3),ones(1,3));
N = grhModel(@testSim2, 10*ones(1,2),20*ones(1,2));
E=grhABCestimator(11,@testMetric,[M N]);
E.firstIteration;
E.mainIteration;