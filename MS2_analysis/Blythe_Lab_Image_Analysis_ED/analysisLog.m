function T = analysisLog(projectParameters, parameters)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% initialize struct
S = table;

% Import

% Nuclear Segmentation

% Spot Segmentation

% Tracking




%% add to existing log
% find and load project import log
% if project log does not exist, create new log
proj_log = projectParameters.importLog;
if isempty(proj_log)
    proj_log = [S.Filepath, '\importLog.csv'];
    T = table();
else
    T = readtable(proj_log);
end

% add to fields assuming variables perfect match
Tnew = [T; S];

% write to csv file
% log directory, name:
writetable(Tnew, proj_log); % does it overwrite or add row?


end

