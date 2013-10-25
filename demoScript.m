% demonstrated improved Approximate Bayesian Computation Sequential Monte
% Carlo code using parfor loops where possible.
%
% The process is stochastic and occaisionally errors occurr that haven't
% been covered yet i.e. if one model has only one sample in a generation.

clear all

load rngErr
rng(s);

if ~matlabpool('size'), matlabpool, end

addpath('functions')

% load target obs data
obs = importdata('data/AggOrig.mat');

% create candidate model objects 
M = grhModel(@pureDiffusion, 0, 250);
N = grhModel(@driftDiffusion, [0 0], [20 250]);

metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

% create main object
E=grhABCestimator(obs, metaData, @population_ChaSrihari, [M N]);
clear obs metaData M N
E.optionSetter('sizePop', 4000);

% run estimation
E.run;

E.runTime

% matlabpool close

% % token presentation of results
% m = E.models{end};
% p = E.params{end};
% w = E.weights{end};
% 
% m1 = m == 1;
% 
% w1 = w(m1);
% p1 = p(m1);
%     
% grhWeightedHist([p1{:}], w1, 10)
% xlim([E.candMods(1).priorLo E.candMods(1).priorHi])
% xlabel('Posterior distribution over Diffusivity (model 1)')