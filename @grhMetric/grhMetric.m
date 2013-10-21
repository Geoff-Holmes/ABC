classdef grhMetric < handle
    
    properties
        
        targetObs;   % target observations to measure against
        Nobs;        % number of observations
        custom;      % customized properties for each application
        dist;        % handle of customised calling function
        
    end
    
    methods
        
        function obj = grhMetric(targetObs, customConstructor)
            % obj = grhMetric(targetObs, customConstuctor)
            obj.targetObs = targetObs;
            obj = customConstructor(obj);
        
        end
    end
    
%     methods(Abstract)
%         dist(obj);
%     end
end
        
            
        