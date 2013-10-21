function obj = testConstructor(obj)

% obj = testConstructor(obj)

obs = obj.targetObs;
Nobs = size(obs, 1);

[cnt, edgs(1,:)] = grhEqCountHist(obs(1,:));

parfor i = 2:size(obs,1)
    
    [~, edgs(i,:)] = grhEqCountHist(obs(i,:));
    
end

obj.Nobs = Nobs;
obj.custom.cnt = cnt;
obj.custom.edgs = edgs;

