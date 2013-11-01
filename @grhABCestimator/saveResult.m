function saveResult(obj, path, name)

% saveResult(obj, path, name)

if nargin < 2
    path = './';
else
    if ~strcmp(path(end), '/')
        path = [path '/'];
    end
end
        
if nargin < 3

    id = 0;
    flag = 1;

    while flag

        id = id + 1;
        name = ['Result' num2str(id)];
        flag = exist([path name '.mat']) == 2

    end
end

if exist([path name '.mat']) == 2
    display('File already exists - not saving')
else
    dummyStruct.(name) = obj
    save([path name], '-struct', 'dummyStruct', name)
    display(['Saving ' path name '.mat'])
end
