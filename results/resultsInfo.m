function Out = resultsInfo(field, match, loadOpt)

addpath('functions')
addpath('metricConstructors')

fls = dir('results/*.mat');

Out = cell(2,0);

for i = 1:length(fls)
    
    R = importdata(fls(i).name);
    if nargin
        if isstr(match)
            flag = strfind(getfield(R, field), match);
        else
            flag = getfield(R, field) == match;
        end
        if flag
            fls(i).name
            R
            if nargin == 3 
                if loadOpt
                    Out(:, end+1) = {fls(i).name; importdata(fls(i).name)};
                end
            end 
        end
    else
        fls(i).name
        R
    end
end

