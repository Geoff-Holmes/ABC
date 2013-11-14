classdef grhABCestimator < handle
    
    properties
        
        obsName;                % name of obs dataset
        metaData;               % initial conditions, time increment etc
        metric;                 % measure of discrepancy simsObs-targetObs
        candMods;               % candidate models
        modelPrior;             % model prior cumulative distribution
        totalNits = 4;          % total number of SMC iterations
        it = 1;                 % current iteration
        sizePop = 100;          % min population size
        sizeGens;               % actual pop size for each iteration
        prKeepMod = 0.6;        % for model perturbation
        figs = 1;               % flag for showing graphical output
        tolSched;               % error tolerance schedule
        Bwts = 1;               % flag for add weights a la Beaumont
        models;                 % (index) model samples from posterior disn
        params;                 % corresponding parameter samples 
        weights;                % corresponding weights
        runTime;
        totalSims;
        rng;                   % state of rng at start of each iteration
        results;
                
    end
    
    methods
        
        function obj = grhABCestimator(...
                obsName, metricConstructor, candMods, metaData)
            
            % observations
            obj.obsName   = obsName;
            obs = importdata(obsName);
            % convert to cell if not already
            if ~iscell(obs)
                obs = num2cell(obs, 2);
            end
            
            % meta data
            if nargin == 4
                obj.metaData  = metaData;
            end
            obj.metaData.initial = obs{1};
            obj.metaData.T       = length(obs);
           
            
            % everything else
            obj.metric    = grhMetric(obs, metricConstructor);
            obj.candMods  = candMods;
            % default uniform model prior
            obj.modelPrior ...
                = cumsum(ones(1,length(candMods))/length(candMods));
            
            obj.models = cell(obj.totalNits, 1); 
            obj.params = cell(obj.totalNits, 1);
            obj.weights = cell(obj.totalNits, 1); 
            obj.totalSims = zeros(1, obj.totalNits);
            obj.runTime = zeros(1, obj.totalNits);
            obj.rng = rng;
            
        end
        
    end
    
end