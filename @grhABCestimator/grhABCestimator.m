classdef grhABCestimator < handle
    
    properties
        
        targetObs;              % target observations
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
        models;                 % (index) model samples from posterior disn
        params;                 % corresponding parameter samples 
%         simObs;                 % corresponding simObs
%         errors;                 % corresponding errors
        weights;                % corresponding weights
                
    end
    
    methods
        
        function obj = grhABCestimator(obs, metric, candMods)
            
            obj.targetObs = obs;
            obj.metric    = metric;
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