classdef grhMetric
    
    properties
        
        targetObs;
        
    end
    
    methods
        
        function obj = grhMetric(targetObs)
            % obj = grhMetric(targetObs)
            obj.targetObs = targetObs;
        
        end
    end
    
%     methods(Abstract)
%         dist(obj);
%     end
end
        
            
        