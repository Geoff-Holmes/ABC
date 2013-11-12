function [obj, figHandle]...
    = plotJntParameterPosteriors(obj, model, axisRange)

% [obj, figHandle] = plotJntParameterPosteriors(obj, model, axisRange)

% shortcut
iModel = obj.candMods(model);
% check for abort
if sum(iModel.pActive) < 2
    display('Only one active parameter for this model')
    return
end
% has the user not specified a range for the axis
if nargin < 3
    axisRange = 0;
end

figHandle = figure;

% get parameters and weights for this model
phi = vertcat(obj.params{end}{obj.results.modInds{model}});
wts    = obj.weights{end}(obj.results.modInds{model});

% number of divisions along axes i.e. resolution of image
pts = 100;

% get all parameter pairings
idxs = bldIdx(find(iModel.pActive));
nPairs = length(idxs);

% get subplot arrangement
[rws, cls] = grhOptSubPlots(nPairs);

% plot joint distribution for each pair of parameters
for j = 1:nPairs
    % get indicies of this pair
    idx = idxs{j};
    
    subplot(rws, cls, j)

    if axisRange==0
        % no range specified so use full prior
        sb = linspace(iModel.priorLo(idx(1)), ...
            iModel.priorHi(idx(1)), pts+1);
        sD = linspace(iModel.priorLo(idx(2)), ...
            iModel.priorHi(idx(2)), pts+1);
    else
        % use user specified axis ranges
        sb = linspace(axisRange(1), axisRange(2), pts+1);
        sD = linspace(axisRange(3), axisRange(4), pts+1);
    end

    sb = sb(2:end);
    sD = sD(2:end);

    bdel = sb(2)-sb(1);
    Ddel = sD(2)-sD(1);

    % add points outside boundary for reflection
    xtra = 33;
    sb1 = [sb(1)-xtra*bdel:bdel:sb(1)-bdel sb sb(end)+bdel:bdel:sb(end)+xtra*bdel];
    sD1 = [sD(1)-xtra*Ddel:Ddel:sD(1)-Ddel sD sD(end)+Ddel:Ddel:sD(end)+xtra*Ddel];
    
    % shortcuts
    Nsb1 = length(sb1);
    NsD1 = length(sD1);
    
    % collect coordinates in 2 column array
    C = zeros(Nsb1 * NsD1, 2);
    for i = 1:Nsb1
        for k = 1:NsD1
            C((i-1)*length(sD1)+k,:) = [sb1(i) sD1(k)];
        end
    end
    
    % create adapted density kernel for estimation
    sig = cov(phi(:, idx))*eye(2)/5;
    % initialise for result
    f = zeros(1,size(C,1));
    
    % add 'sandpile' kernel corresponding to each accepted weighted sample
    for i = 1:size(phi,1)
        f = f + wts(i) * ...
            mvnpdf(C, phi(i,idx), sig)';
    end

    % reshape into original grid for plotting
    f = reshape(f, pts+2*xtra, pts+2*xtra);
    % reflect probability mass outside boundaries back in
    f = reflect(f, xtra);
    
    % plot result
    imagesc(flipud(f))

%     % get maximum
%     Nsb = length(sb);
%     NsD = length(sD);
%     C = zeros(Nsb * NsD, 2);
%     for i = 1:Nsb
%         for k = 1:NsD
%             C((i-1)*length(sD)+k,:) = [sb(i) sD(k)];
%         end
%     end
%     f = reshape(f, 1, pts^2);
%     [~, kmax] = max(f);
%     map = C(kmax,:)
%     
%     obj.results.map{model} = map;

%     if sum(tagP)
%     try
%         [~, xb] = min(abs(sb-tagP(idx(1))));
%         [~, xD] = min(abs(wrev(sD)-tagP(idx(2))));
%         hold on
%         plot(xb, xD, 'k+', 'MarkerSize', 12, 'LineWidth', 2)
%     %     plot(xb, xD, 'w+', 'MarkerSize', 16, 'LineWidth', 4)
%     catch
%         display('true parameter not known')
%     end
%     end

    fSz = 10;
    tks = pts/5:pts/5:pts;
    set(gca, 'XTick', [0 tks])
    set(gca, 'XTickLabel', [0 round(100*sb(tks))/100])
    set(gca, 'YTick', [0 tks])
    set(gca, 'YTickLabel', wrev([0 sD(tks)]))
    xlabel(iModel.pNames(idx(1)), 'FontSize', fSz)
    ylabel(iModel.pNames(idx(2)), 'FontSize', fSz)

end

suptitle([iModel.name ' model'])

%%%%%%%%%%%%% sub functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Idxs = bldIdx(J)

Idxs = {};
if length(J) > 2

    for k = J(2:end)
        Idxs{end+1} = [J(1) k];
    end
    Jextra = bldIdx(J(2:end));
    lJx = length(Jextra);
    Idxs(end+1:end+lJx) = Jextra;  
else
    Idxs = {J};
end


function Y = reflect(X, s)

% reflect all points beyond boundary back into matrix

assert(3*s<=size(X,1))
Y = X(s+1:end-s, s+1:end-s);

for i = 1:4
    A = X(1:s, 1:s);
    B = X(s+1:end-s, 1:s);
    B(1:s,:) = B(1:s,:) + flipud(A);
    Y(:,1:s) = Y(:,1:s) + fliplr(B);
    X = flipud(X');
    Y = flipud(Y');
end
