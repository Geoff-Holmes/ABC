function parameterPosteriors(obj, opt)

% parameterPosteriors(obj, opt)
%
% opt 'fullrange' plots over entire prior range

% get results info
params = obj.params{end};
wts = obj.weights{end};
mods = obj.models{end};
modList = unique(mods);

for i = 1:length(modList)
    
    % shortcut
    iModel = obj.candMods(modList(i));
    
    % get indicies of samples for this model
    modInds = mods == modList(i);
    % and corresponding sample weights
    modWts  = wts(modInds);
    % ditto parameter sets
    modPms  = params(modInds);
    % package them for easy use
    pArray = vertcat(modPms{:});
    % get plotting info
    cols = iModel.nParams;
    figure;
    for j = 1:cols
        subplot(1,cols,j)
        grhWeightedHist(pArray(:,j)', modWts, 10);
        if nargin > 1 && strcmp(opt, 'fullrange')
            xlim([iModel.priorLo(j) iModel.priorHi(j)])
        end
        xlabel(iModel.pNames{j})
        if j == 1, ylabel('Normalised count'); end
        suptitle(['Model : ' num2str(i)])
    end
end

