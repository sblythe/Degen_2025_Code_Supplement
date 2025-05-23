%% Get files to update - 10/28/20

% Opens window for selecting a csv file that acts as image analysis log
% exiting the window without selecting a file will create a new log
txt = 'Select project log to load, or exit window to create new';
[file, path] = uigetfile('*.csv', txt);
if file == 0
    projectLog = '';
    fprintf('No file selected. Creating new project log. \n');
else
    projectLog = fullfile(path, file);
    fprinf('Updating files from %s. \n', projectLog);
end

% If analysis log is new or empty, automatically open window to select
% files to add; otherwise store analysis log in a table
if isempty(projectLog)
    txt = 'Select image files to add to analysis';
    [file, path] = uigetfile('*.lif', txt, 'MultiSelect', 'On');
    newFiles = fullfile(path, file);
    % set analysis log directory to that of first added file
    projectLog = fullfile(path{1}, 'analysis_log.csv');
    fprintf('Analysis log save to %s \n', projectLog);
    %
    T = table;
    loggedFiles = {};
else
    T = readtable(projectLog, 'ReadVariableNames', 1);
    if isempty(T)
        txt = 'Analysis log empty. Select image files to add to analysis';
        [file, path] = uigetfile('*.lif', txt, 'MultiSelect', 'On');
        newFiles = fullfile(path, file);
        %
        loggedFiles = {};
    else
        newFiles = {};
        loggedFiles = fullfile(T.Filepath, T.Filename);
    end
end

% Gives user option to add more files to analysis log (if they have not
% already)
prompt = 'Do you want to add new files to this analysis?';
str = input(prompt, 's');
if strcmpi(str, 'y')
    txt = 'Select image files to add to analysis';
    [file, path] = uigetfile('*.lif', txt, 'MultiSelect', 'On');
    if ~isequal(file, 0)
        newFiles = fullfile(path, file);
    end
end
% ** see inputdlg and waitfor or uiwait to skipping to default response if
% user does not respond in ~30 sec


%% Import Script

% import pop up for all new files
% automatically fill with previous, (but include a reset button (eventually))

% load new files

[T, loggedFiles] = universal_import(T, loggedFiles, newFiles);

%% Nuc Seg Script

% X files ready for nuclear segmentation. Run all? 
% (currently only option is to run all or skip all, find way to select a few
% in the future - such as entering a key word/date {'200211*',(or) '*mcp*'}, ect)

% for all files with 'select new' option in parameters
% update list of files who need parameters based on param_apply


% segment files & update T

T = universal_nucseg(T, loggedFiles);

%% MS2 Seg Script

% same steps as nuc seg

T = universal_spotseg(T, loggedFiles);





%% (Par Seg Script)
%% (Tracking Script)
%%
%% Saving








