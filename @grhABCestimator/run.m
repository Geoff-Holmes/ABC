function obj = run(obj)

% obj = run(obj)

obj.firstIteration;
while obj.it <= obj.totalNits
    obj.mainIteration;
end
display('Finished estimation')
display('Post-processing')

obj.getModelMarginalPosterior;
