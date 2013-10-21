function dist = testDistance(X)


cnt = obj.cnt;

parfor i = 1:obj.Nobs
    
    cnt = histc(X(i,:), obj.edgs(i,:));
    err(i) = grhHistDist(X, cnt, obj.cntrs(i,:));
    
end