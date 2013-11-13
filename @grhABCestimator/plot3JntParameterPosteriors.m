function plot3JntParameterPosteriors(obj, model, wt)

% plot3JntParameterPosteriors(obj, model, wt)

if nargin < 3
    wt = 0;
end

% shortcut to model
iModel = obj.candMods(model);

% get all parameter samples and corresponding weights for this model
params = vertcat(obj.params{end}{obj.results.modInds{model}});
weights = obj.weights{end}(obj.results.modInds{model});

% get all triples of the parameters
idxs = nchoosek(find(iModel.pActive), 3);
nTriples = size(idxs, 1);

% plot a 3d figure for each parameter triple
for j = 1:nTriples

    figure; hold on
    
    % plot each parameter sample
    for i = 1:size(params, 1)
        handle = plot3(params(i,idxs(j,1)), params(i,idxs(j,2)), ...
            params(i,idxs(j,3)), '.');
        if wt
            set(handle, 'markerSize', ceil(weights(i)*20000));
        end
    end

    xlabel(iModel.pNames(idxs(j,1)))
    ylabel(iModel.pNames(idxs(j,2)))
    zlabel(iModel.pNames(idxs(j,3)))
    
    xlim([iModel.priorLo(idxs(j,1)) iModel.priorHi(idxs(j,1))])
    ylim([iModel.priorLo(idxs(j,2)) iModel.priorHi(idxs(j,2))])
    zlim([iModel.priorLo(idxs(j,3)) iModel.priorHi(idxs(j,3))])
    
    
end