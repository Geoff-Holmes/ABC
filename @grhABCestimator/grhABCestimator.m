classdef grhABCestimator < handle
    
    properties
        
        targetObs;              % target observations
        metric;                 % measure of discrepancy simsObs-targetObs
        candMods;               % candidate models
        modelPrior;             % model prior cumulative distribution
        totalNits = 4;          % total number of SMC iterations
        n = 1;                  % current iteration
        sizePop = 4;         % population size
        p = 1;                  % current sample number
        prKeepMod = 0.6;        % for model perturbation
        figs = 1;               % flag for showing graphical output
        samples;                % model / parameterset samples from posterior disn
        weights;                % corresponding to samples
                
    end
    
    methods
        
        function obj = grhABCestimator(obs, metric, candMods)
            
            obj.targetObs = obs;
            obj.metric    = metric;
            obj.candMods  = candMods;
            obj.modelPrior ...
                = cumsum(ones(1,length(candMods))/length(candMods));
            obj.modelPrior = [0 obj.modelPrior(1:end-1)];
            
        end
        
    end
    
end