classdef grhMetric < handle
    
    properties
        
        Nobs;        % number of observations
        custom;      % customized properties for each application
        callHandle;  % handle of customised calling function
        
    end
    
    methods
        
        function obj = grhMetric(targetObs, customConstructor)
            % obj = grhMetric(targetObs, customConstuctor)
            
            obj = customConstructor(obj, targetObs);
        
        end

        function d = call(obj, X)
            
            d = obj.callHandle(obj, X);

        end
    end
    
end
        
            
        