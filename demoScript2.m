% Approximate Bayesian Computation Sequential Monte
% Carlo code using parfor loops where possible.

clear all

if isempty(gcp('nocreate')); parpool; end

addpath('functions')
addpath('models')
addpath('metricConstructors')

% load target obs data
obs = importdata('data/AggOrig.mat');
% convert to cell if not already
if ~iscell(obs)
    obs = num2cell(obs, 2);
end

% create candidate model objects 
% Models = [grhModel(@Pure_Diffusion, 0, 250) ...
%     grhModel(@Drift_Levy_Diffusion, [1 1 0], [3 250 5]) ...
%     grhModel(@Levy_Diffusion, [1 1], [3 250]) ...
%     grhModel(@Drift_Diffusion, [0 0], [5 250])];
Models = [grhModel(@Drift_Levy_Diffusion, [1 1 0], [3 250 5]) ...
    grhModel(@Levy_Diffusion, [1 1], [3 250])];

% metaData is packaged for easy passing to simulator
% the metaData components may vary depending on application
metaData.initial = obs{1};
metaData.timeInc = 1;
metaData.T       = length(obs);

% create main object
E=grhABCestimator(obs, metaData, @population_ChaSrihari, Models);
clear obs metaData M N
E.optionSetter('sizePop', 4000);

% run estimation
E.run;

% comment next line to save time reopening pool if required again
matlabpool close

% plot (and store some) results
E.plotModelMarginalPosterior;
E.plotParameterPosteriors;
for j = 1:length(E.candMods)
    E.plotJntParameterPosteriors(j);
end

% save in folder results
E.saveResult('results')


