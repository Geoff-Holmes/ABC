classdef grhModel
    
    properties
        
        name;
        simltr;    % the simulator function
        pNames;    % names of parameters
        nParams;   % number of parameters
        priorLo;   % lower bounds of priors
        priorHi;   % upper bounds of priors
        
    end
    
    methods
        
        function obj = grhModel(func, priorLo, priorHi)
            
            obj.name = func2str(func);
            obj.simltr = func;
            obj.pNames = obj.simltr();
            % assumes calling func with nargin == 0 returns param names
            obj.nParams = length(obj.pNames);
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
           
        end
    end
end
            