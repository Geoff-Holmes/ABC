function distance = testMetric2(A, B)

parfor i = 1:length(A)
    
    histA(i,:) = hist(A(i,:));
    histB(i,:) = hist(B(i,:));
    
end

distance = max(max(abs(histA-histB)));