function obj = optionSetter(obj, varargin)

% obj = optionSetter(obj, varargin)
%

for i = 1:floor(length(varargin)/2)
    
    name = varargin{2*i-1};
    
    if isprop(obj, name)
        obj.(name) = varargin{2*i};
    else
        display(['ignoring unknown option : ' name])
    end
    
end
