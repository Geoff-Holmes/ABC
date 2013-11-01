% demonstrated improved Approximate Bayesian Computation Sequential Monte
% Carlo code using parfor loops where possible.
%
% The process is stochastic and occaisionally errors occurr that haven't
% been covered yet i.e. if one model has only one sample in a generation.

clear all

if ~matlabpool('size'), matlabpool, end

addpath('functions')
addpath('models')
addpath('metricConstructors')

% load target obs data
obs = importdata('data/AggOrig.mat');

% create candidate model objects 
M = grhModel(@Pure_Diffusion, 0, 250);
N = grhModel(@Levy_Diffusion, [1 1], [50 250]);

metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

% create main object
E=grhABCestimator(obs, metaData, @population_ChaSrihari, [M N]);
clear obs metaData M N
E.optionSetter('sizePop', 4000);

% run estimation
E.run;
E.saveResult('results')

% matlabpool close

% results
E.modelMarginalPosterior;
E.parameterPosteriors;
