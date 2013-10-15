classdef grhSimulator
    
    properties
        
        func;    % the simulator function
        params;  % names of parameters
        nParams;  % number of free parameters
        priorLo; % lower bounds of priors
        priorHi; % upper bounds of priors
        samplesOld; % last gen parameter sets associated with this model
        weights; % corresponding weights
        errors;  % corresponing errors
        samplesNew; % generation in process
        targetObs; % target
        metric;    % distance measure
    end
    
    methods
        
        function obj = grhSimulator(func, priorLo, priorHi, meta)
            
            obj.func = func;
            obj.params = obj.func();
            % assumes calling func with nargin == 0 returns param names
            obj.nParams = length(obj.params);
            try
                assert(length(priorLo) == obj.nParams ...
                && length(priorHi) == obj.nParams)
            catch ex
                display(['For this simulator, prior limits must both ' ...
                    'have ' num2str(obj.nParams) ' entries.'])
                rethrow(ex)
            end
            obj.priorLo = priorLo;
            obj.priorHi = priorHi;
            obj.targetObs = meta.targetObs;
            obj.metric = meta.metric;
            
        end
    end
end
            