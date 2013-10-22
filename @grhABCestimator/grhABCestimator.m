classdef grhABCestimator < handle
    
    properties
        
        targetObs;              % target observations
        metaData;               % initial conditions, time increment etc
        metric;                 % measure of discrepancy simsObs-targetObs
        candMods;               % candidate models
        modelPrior;             % model prior cumulative distribution
        totalNits = 4;          % total number of SMC iterations
        n = 1;                  % current iteration
        sizePop = 100;         % min population size
        sizeGens;               % actual pop size for each iteration
        p = 1;                  % current sample number
        prKeepMod = 0.6;        % for model perturbation
        figs = 1;               % flag for showing graphical output
        tolSched;               % error tolerance schedule
        Bwts = 1;               % flag for add weights a la Beaumont
        models;                 % (index) model samples from posterior disn
        params;                 % corresponding parameter samples 
        weights;                % corresponding weights
                
    end
    
    methods
        
        function obj = ...
                grhABCestimator(obs, metaData, metricConstructor, candMods)
            
            obj.targetObs = obs;
            obj.metaData  = metaData;
            obj.metric    = grhMetric(obj.targetObs, metricConstructor);
            obj.candMods  = candMods;
            % default uniform model prior
            obj.modelPrior ...
                = cumsum(ones(1,length(candMods))/length(candMods));
            
            obj.models = cell(obj.totalNits, 1); %obj.sizePop);
            obj.params = cell(obj.totalNits, 1); %obj.sizePop);
%             obj.errors = zeros(obj.totalNits, obj.sizePop);
            obj.weights = cell(obj.totalNits, 1); %obj.sizePop);
            

            
            
            
        end
        
    end
    
end