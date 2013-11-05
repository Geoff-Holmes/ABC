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
obs = importdata('data/levyDiffusion_1pt8_75.mat');
% convert to cell if not already
if ~iscell(obs)
    obs = num2cell(obs, 2);
end

% create candidate model objects 
M = grhModel(@Pure_Diffusion, 0, 250);
N = grhModel(@Levy_Diffusion, [1 1], [3 250]);

metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

% create main object
E=grhABCestimator(obs, metaData, @population_ChaSrihari, [N]);
clear obs metaData M N
E.optionSetter('sizePop', 400);

% run estimation
E.run;

% matlabpool close

% plot (and store some) results
E.plotModelMarginalPosterior;
E.parameterPosteriors;
for j = 1:length(E.candMods)
    E.jntParameterPosteriors(j);
end

% save in folder results
E.saveResult('results')


