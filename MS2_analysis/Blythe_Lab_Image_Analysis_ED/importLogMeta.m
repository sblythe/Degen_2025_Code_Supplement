function Tnew = importLogMeta(T, parameters, meta)
%UNTITLED3 Summary of this function goes here
%   Fx called during .lif file import
%   saves log to parameters.saveDirectory
%   INPUTS: parameters, meta, (overmeta)

% initialize struct
S = struct;

% Description
[filepath, name] = fileparts(parameters.filename);
S.Filename = name;
S.ImportDate = datetime('today');
S.Filepath = filepath; 
S.SaveDirectory = strcat(filepath, filesep, name, '_analysis');


for i = 1:length(parameters.channelName)
    fieldname = ['Channel', num2str(i)];
    S.(fieldname) = parameters.channelName{i};
%     excitation = [fieldname, 'Excitation'];
%     emission = [fieldname, 'Emission'];
%     gain = [fieldname, 'Gain'];
%     method = [fieldname, 'CollectionMethod'];
%     S.(excitation) = parameters.channelExcitation(i);
%     S.(emission) = parameters.channelEmmission{i};
%     S.(gain) = parameters.channelGain(i);
%     S.(method) = parameters.channelCollectionMethod{i}; % 'Standard', 'Counting', 'BrightR'
end

% Imaging Parameters
S.Magnification = meta.Magnification;
S.Immersion = meta.Immersion;
S.Zoom = meta.Zoom;
y = meta.SizeY * meta.microns_per_pixel_Y;
S.MicronSize = y;
S.ScanSpeed = meta.ScanSpeed;
S.ScanDirection = meta.ScanDirection;
S.SizeT = meta.SizeT;
S.SizeX = meta.SizeX;
S.SizeY = meta.SizeY;
S.SizeZ = meta.SizeZ;
S.SizeC = meta.SizeC;
reader = bfGetReader(parameters.filename);
S.SeriesCount = reader.getSeriesCount();


% % Nuclear Cycles / Time Reference Points  
% % movie set up specific (see "Generate Field Names from Variables")
% S.NuclearCycle12 = parameters.nuclearCycleStart(1);
% S.NuclearCycle13 = parameters.nuclearCycleStart(2);
% S.NuclearCycle14 = parameters.nuclearCycleStart(3);

% % Import Parameters
% % S.ImportDate;
% S.ImportSkip = parameters.importSkip;
% S.Overview = ~parameters.importIncludeLast;
% S.Tracking = parameters.trackNuclei;
% S.HistoneChannel = parameters.histoneChannel;



% add to existing log

% Convert struct to table
Tadd = struct2table(S);

% Check for discrepencies between column names
% Order does not matter, but must have same variables
varNamesMain = T.Properties.VariableNames;
varNamesAdd = Tadd.Properties.VariableNames;

[newVarMain] = setdiff(varNamesMain, varNamesAdd); % variables to append to Tadd; order does not matter
for i = 1:length(newVarMain)
    varName = newVarMain{i};
    var = [];
    Tadd = addvars(Tadd, var, 'NewVariableNames', varName);
end   
    
[newVarAdd, varIdxAdd] = setdiff(varNamesAdd, varNamesMain); % variables to append to T
for i = 1:length(newVarAdd)  
    varName = newVarAdd{i};
    var = cell(height(T), 1);
    T = addvars(T, var, 'NewVariableNames', varName);
end

% add to fields assuming variables perfect match
Tnew = [T; Tadd];



end

