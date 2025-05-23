

%% collect user info in gui

% filename
filename = {'test1.mat', 'test2.mat', 'test3.mat'}';
% filepath
% save directory
% flip AP
% nChan
nChannels = [2, 2, 3]';
% channel names
% channel type/ analysis type
histoneChannel = [2, 2, 3]';
% analysis date (most recent)
% genotype 
% metadata

Tbl = table(filename, nChannels, histoneChannel);

file1 = 'analysis_log.txt';
file2 = 'analysis_log.csv';
file3 = 'analysis_log.xls';

writetable(Tbl, file1);
writetable(Tbl, file2);
writetable(Tbl, file3);
% writetable(Tbl, file3, 'WriteMode', 'overwritesheet'); %2020 only


%% read in txt log

T1 = readtable(file1);
T2 = readtable(file2);
T3 = readtable(file3);


%% add to log



%% search by filename- add new or update pre-existing file



%% write txt log




