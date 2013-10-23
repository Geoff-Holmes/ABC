function b = grhWeightedHist(data, weights, bars)
    
    % produce a weighted histogram of samples in 'data'
    % which are weighted according to 'weights'
    % 'bars' is the number of bars
    % 
    % geoffrholmes@gmail.com  19-Sep-12
    
    % get hist to work out where to place bins centers
    [~, xout] = hist(data,bars);
    % calculate bin width
    wid = xout(2)-xout(1);
    % calculate bin edges
    lims = [xout'-wid/2 xout'+wid/2];
    % preallocate to keep matlab happy
    height = zeros(1,bars);
    % calucluate each bar height in turn
    for j = 1:bars
        % select the data that falls in this bin
        test4 = data>=lims(j,1) & data<lims(j,2);
        % add corresponding weights to get bar height
        height(j) = sum(weights.*test4);
    end
    
    % produce histogram
    b = bar(xout, height, 'w');
    ylim([0 1.1*max(height)]);
