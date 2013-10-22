classdef grhMetric < handle
    
    properties
        
        targetObs;   % target observations to measure against
        Nobs;        % number of observations
        custom;      % customized properties for each application
        call;        % handle of customised calling function
        
    end
    
    methods
        
        function obj = grhMetric(targetObs, customConstructor)
            % obj = grhMetric(targetObs, customConstuctor)
            
            obj = customConstructor(obj, targetObs);
        
        end

        function d = dist(obj, X)
            
            d = obj.call(obj, X);

        end
    end
    
end
        
            
        