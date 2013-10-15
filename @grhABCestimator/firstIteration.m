function obj = firstIteration(obj)


% select model from model prior
dummy = rand(1, obj.sizePop);
modInd = sum(bsxfun(@ge, dummy, obj.modelPrior'));


% parallel loop
parfor i = 1:obj.sizePop
    
    simObs(i) = obj.candMods(models(modInd)).simulate();
    
end
    


