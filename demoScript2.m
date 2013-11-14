% Approximate Bayesian Computation Sequential Monte
% Carlo code using parfor loops where possible.

clear all

if ~matlabpool('size'), matlabpool, end

addpath('functions')
addpath('models')
addpath('metricConstructors')

% load target obs data
obsName = 'data/AggOrig.mat';
obs = importdata(obsName);
% convert to cell if not already
if ~iscell(obs)
    obs = num2cell(obs, 2);
end

% create candidate model objects 
% Models = [grhModel(@Pure_Diffusion, 0, 250) ...
%     grhModel(@Drift_Levy_Diffusion, [1 1 0], [3 250 5]) ...
%     grhModel(@Levy_Diffusion, [1 1], [3 250]) ...
%     grhModel(@Drift_Diffusion, [0 0], [5 250])];
% Models = [grhModel(@Drift_Levy_Diffusion, [1 1 0], [3 250 5]) ...
%     grhModel(@Levy_Diffusion, [1 1], [3 250])];

% u = [...
%     10 5 4 250 1 .1 ;...
%     10 0 4 250 1 .1 ;...
%      0 5 4 250 1  0 ;...
%      0 0 4 250 1  0 ;...
%     10 5 4 250 0 .1 ;...
%      0 0 4 250 0  0];
%  for i = 1:6
%      Models(i) = grhModel(@Multi_Migration, zeros(1, 6), u(i,:));
%  end

Models = grhModel(@Multi_Migration, zeros(1,6), [0 0 10 50 1 0]);
    
% metaData is packaged for easy passing to simulator
% the metaData components may vary depending on application
% initial obs and number of obs meta data set inside constructor
metaData = struct(...
    'initialOccupancy', ones(1, length(obs{1})), ...
    'restrictionPoint', 100, 'restrictionHorizon', 1000);

% create main object
E=grhABCestimator(obsName, @population_ChaSrihari, Models, metaData);
clear obs metaData M N
E.optionSetter('sizePop', 40);

% run estimation
E.run;

% comment next line to save time reopening pool if required again
% matlabpool close

% plot (and store some) results
E.plotModelMarginalPosterior;
E.plotParameterPosteriors;
for j = 1:length(E.candMods)
    E.plotJntParameterPosteriors(j);
end

% save in folder results
E.saveResult('results')


