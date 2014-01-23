% Approximate Bayesian Computation Sequential Monte
% Carlo code using parfor loops where possible.

% close all
clear all

% seed random number generator using current time
rng('shuffle');

if ~matlabpool('size'), matlabpool, end

addpath('functions')
addpath('models')
addpath('metricConstructors')

% load target obs data
obsName = 'data/AR2_pt9_negpt5_pt1.mat';

% create candidate model objects 
% M = grhModel(@simulatorFunction, [lower limits on priors], [upper limits]);
M1 = grhModel(@Simple_AR, -5, 5);
M2 = grhModel(@AR2, [-5 -5], [5 5]);

% create main object 
% 3rd argument is handle for customised error metric constructor
% 4th is a list of candidate models
E=grhABCestimator(obsName, @sumSquareErrors, [M1 M2]);
clear obs metaData M1 M2
E.optionSetter('sizePop', 400);

% show all the model attributes
E

% run estimation
E.run;

% comment next line to save time reopening pool if required again
matlabpool close

% plot (and store some) results
if length(E.candMods) > 1
    E.plotModelMarginalPosterior;
end
E.plotParameterPosteriors;
for j = 1:length(E.candMods)
    E.plotJntParameterPosteriors(j);
end

% save in folder results
E.saveResult('results')


