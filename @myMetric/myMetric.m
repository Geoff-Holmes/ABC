classdef myMetric < grhMetric
    
    methods
        
        function obj = myMetric(targetObs)
            
            obj = obj@grhMetric(targetObs);
        end
        
        function distance = dist(obj, X)
            
            % distance = dist(obj, X)
            
            distance = obj.targetObs * X;
        end
    end
end