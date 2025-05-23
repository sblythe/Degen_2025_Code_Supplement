% loop through parB lif files to save variables from 
% the parametrized_analysis function

runInputFunc = 0;

loadDirectory = '/Users/sblythe/Desktop/Current_parB_analysis';

folder = dir(loadDirectory);

filenames = {};
for ii = 3:length(folder)
    img_file = folder(ii).name;
    if(contains(img_file, '.lif') && contains(img_file, 'ParB_'))
        filenames{end + 1} = strcat(loadDirectory, '/', img_file);
    end   
end
    
% segment and filter all images before selecting embryo mask 

% load image, segment nuclei, and locate parB foci 

for ii = 1:length(filenames)
    var_file = filenames{ii};
    var_file = strcat(var_file(1:end-4), '_analysis/initial_analysis.mat');
    if ~exist(var_file)
        parameters = build_analysis_parameters_v2(filenames{ii});
        output = parametrized_analysis_v2(parameters, 1);
    end
end

% run functions that rely on user input - check AP flip, find AP axis, get
% NC start times
if runInputFunc
    for ii = 1:length(filenames)
       var_file = filenames{ii};
       var_file = strcat(var_file(1:end-4), '_analysis/initial_analysis');
       load(var_file, 'metadata')
       if metadata.getUserInput == 1
           input_analysis(var_file);
           NCstarts = get_NC_start(var_file);
       end
       if ~exist('NCstarts')
           NCstarts = metadata.NuclearCycleStarts;
       end
       lengthNC13(ii) = NCstarts(4) - NCstarts(3);
       close all
    end
end
    

    






     