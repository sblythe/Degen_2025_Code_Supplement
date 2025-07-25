
% load(myfile, 'trLabel', 'trackmat', 'allChannels', 'nucmask', 'parameters', 'mcpmask');
% myfile='/Users/ellie/Documents/MATLAB/Ellie/MS2_Gal4/MovieAnalysisStructures_updated/gt_200_1_analysis.mat';

% test=hb_700_3_anlaysis;
% test=hb_200_1_anlaysis;
% trackmat=test.tracking.trackmat;
% trLabel=test.tracking.labeltrack;
mcpmat=im2double(test.ms2);
mcpmask=test.ms2Mask;
nucmask=test.nuclearMask;
overmeta=[];

% set desired time range
% tStart = parameters.nuclearCycleStart(end);
% trackmat = trackmat(:,tStart:end);
% trLabel = trLabel(:,:,tStart:end);
% mcpmat = im2double(allChannels(:,:,:,tStart:end,parameters.mcpChannel));
% mcpmask = mcpmask(:,:,:,tStart:end);
% nucmask = nucmask(:,:,:,tStart:end);
nucmax = projectNuclearMask(nucmask, 0.5);

%% If need to do tracking
% Get intensities values for each tracked nucleus
fprintf('Calculating MS2 signal for each track ... \n')

validTrackIdx = 1:size(trackmat, 1);
trLabel4D = labelTrack4D(trLabel, nucmask); % converts label matrix to 4D
mcpspots = mcpmat .* mcpmask;
trackMcp = getObjTrackIntensity(trLabel4D, mcpspots, validTrackIdx,overmeta);

%% Tracking already done
validTrackIdx=test.tracking.validTrackIdx;
trackMcp=test.tracking.trackms2;
mcpspots = mcpmat .* mcpmask;

%%

% create cellmask
% embryo mask optional; useful at higher zooms and early NC
embryomask= ones(size(nucmax));
cellmask = getCellMask(nucmax, embryomask);

% % normalize 
% accTrackMcp = cumsum(trackMcp, 2,'omitnan'); % Ellie added the omitnan flag
% normMcpTrack = (trackMcp - min(trackMcp(:))) / (max(trackMcp(:)) - min(trackMcp(:)));
% normAccMcpTrack = (accTrackMcp - min(accTrackMcp(:))) / (max(accTrackMcp(:)) - min(accTrackMcp(:)));
% 
% % Mcp @ T 
% mcp_cells = cellmaskIntensityFill(normMcpTrack, trLabel, validTrackIdx, cellmask);
% 
% % acc Mcp
% acc_mcp_cells = cellmaskIntensityFill(normAccMcpTrack, trLabel, validTrackIdx, cellmask);

% no tracking
mcpCellFill = cellFillUntracked(mcpmat, mcpmask, cellmask);

%% save tracked cells 
% savedir = fileparts(myfile);
% savedir='/Users/ellie/Documents/MATLAB/Ellie/MS2_Gal4/Gt-10_200Hz_noOverview';
% savedir='/Users/ellie/Documents/MATLAB/Ellie/MS2_Gal4/HbP2_200Hz_noOVerview/';
savedir = '/Volumes/BlytheLab_Files/Imaging/Ellie/ZGA_talk/';
% saveMovieFx([savedir, filesep, 'mcp_cells'], mcp_cells);
% saveMovieFx([savedir, filesep, 'acc_mcp_cells'], acc_mcp_cells);
saveMovieFx([savedir, filesep, 'mcp_exampleHbP2'], mcpCellFill);

% Save histone and ms2DOG
histone = squeeze(max(test.histoneRFP,[],3));
saveMovieFx([savedir, filesep, 'his_exampleHbP2'],histone);


ms2DOG = squeeze(max(test.ms2Mask,[],3));
% ms2DOG=ms2DOG./max(ms2DOG(:));
saveMovieFx([savedir, filesep, 'ms2DOG_exampleHbP2'],ms2DOG);



