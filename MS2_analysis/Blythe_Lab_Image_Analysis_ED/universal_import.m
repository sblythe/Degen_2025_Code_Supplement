function [T, loggedFiles] = universal_import(T, loggedFiles, newFiles)
%UNIVERSAL_IMPORT opens importUI for files that need to be loaded, as 
%   determined by the analysis log table; updates table

allParam = cell(size(newFiles));
for i = 1:length(newFiles)
    myfile = newFiles{i};
    [path, basename] = fileparts(myfile);
    savedir = strcat(path, filesep, basename, '_analysis');   
    % enter parameters
    if i > 1
        lastparam = allParam{i-1};
        [parameters, 1] = importUI(myfile, lastparam);
    else
        [parameters, 0] = importUI(myfile);
    end
    if isempty(parameters)
        newFiles(i) = [];
        fprintf('Skipping %s \n', newFiles{i})
    else   
        parameters.filename = myfile;
        parameters.saveDirectory = savedir;
        parameters.importFunction = @stitcherV2;
        parameters.channelSplitFunction = @split_channels;
        parameters.imageArrayingFunction = @make4D;
        allParam{i} = parameters; 
        loggedFiles{end+1} = myfile;
    end
    
end


for i = 1:length(newFiles)
    fprintf('Importing %d / %d \n', i, length(newFiles))
    newVars = {'parameters', 'meta', 'allChannels'};
    parameters = allParam{i};
    data = import_movie(parameters);
    meta = data.meta;
    allChannels = data.allChannels;
    end       

    % save variables
    fprintf('Saving image matrices %d / %d \n', i, length(newFiles))
    savefile = [parameters.saveDirectory, '/initial_analysis'];
    if ~exist(parameters.saveDirectory,'dir')
        mkdir(parameters.saveDirectory)
    end
    save(savefile, newVars{:}, '-v7.3');

    % update log
    T = importLogMeta(T, parameters, meta);
end






end

