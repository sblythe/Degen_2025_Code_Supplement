%% NOTE about determining anaphse
% Determined anaphase by the frame where there was
% space between the first chromosomes that pulled apart

%% Specify file paths

clearvars
close all

path = 'path to folder of Leica files';
fp1 = strcat(path,'Leica file');

% List of paths to Leica files
filepaths = {fp1};
i = 1; % Index of movie you'd like to analyze

% Paths to where you'd like the analysis and summary structures saved
savePath = 'placeholder/';
analysispath = sprintf(strcat(savePath,'analysis_%i'),i);
summarypath = sprintf(strcat(savePath,'summary_%i'),i);

%% Load movie and image analysis parameters

% Load analysis parameters
load('path to MS2_parameters (included in the MS2_analysis folder)');

% Load movie for analysis
movie = load_movie(filepaths{i},parameters); % channel1=ms2, channel2=nuc, channel3=brightfield

%% Determine NC13 bounds manually
implay(squeeze(max(movie.channel2mat(:,:,:,:),[],3)))


%% Record NC13 bounds
bounds = [];

diff(bounds)/6 % cycle time in min

%% Create nuclear mask and set variables
nucmask = nucSeg4Dglobal(movie.channel2mat(:,:,:,bounds(1):bounds(2)),parameters); %original recommended parameters: smoothSigma = 3; openSphereRad = 7;lowerVolCutoffRad = 15. New 2, 4, 5

movie.meta.SizeT = size(nucmask,4); 
ms2mat = movie.channel1mat(:,:,:,bounds(1):bounds(2));
hismat = movie.channel2mat(:,:,:,bounds(1):bounds(2)); 
meta = movie.meta;
overmeta = movie.overmeta;
lastmax = movie.lastmax;

sum(ms2mat(:))

%% Run the analysis (find spots)

ms2CE = parameters.contrastEnhanceFunction(ms2mat, ...
    parameters.contrastEnhanceSphereRad);

ms2DOG = parameters.dogFunction(ms2CE, ...
    parameters.DoGsigma1, parameters.DoGsigma2);

ms2DOGf = parameters.filterFunction(ms2DOG, nucmask, meta, ...
    parameters.minFocusVolRad, parameters.maxFocusVolRad, ...
    parameters.minFocusPlaneOccupancy, parameters.excludeFociInPlane, ...
    parameters.focusIntensityPvalCutoff, parameters.minTotalIntensity);

h = implay(squeeze(sum(ms2DOGf,3)));
set(h.Parent,'Name','p=0.1')

% make an overview movie
check = parameters.checkMovieFunction(meta, ms2DOGf, nucmask, hismat);

output = struct;
output.analysisDate = datetime;
output.parameters = parameters;
output.metadata = meta;
output.overviewMetadata = overmeta;
output.lastMax = lastmax;
output.nuclearMask = nucmask;
output.ms2Mask = ms2DOGf;
output.segmentationCheckMovie = check;
output.histoneRFP = hismat;
output.ms2 = ms2mat;

movie_analysis = output;

%% Find AP axis location

overmax = movie.overmax; 

overmeta = parameters.flipCheckFunction({imrotate(overmax,90)}, overmeta);
overmeta = parameters.apAxisFindingFunction(overmax, lastmax, overmeta, meta);

movie_analysis.overviewMetadata = overmeta;
movie_analysis.overviewMax = overmax;


%% Track nuclei. Find ms2 intensity
movie_analysis.parameters.hMin=1; 

nucmask = movie_analysis.nuclearMask;
nucmax = projectNuclearMask(nucmask, movie_analysis.parameters.hMin);
n = size(nucmax,3);
means = [];
for j = round(.25*n):round(.75*n)
    stats = regionprops(nucmax(:,:,j)>0); 
    means = [means mean([stats.Area])]; 
end
maxObjSize = 1.5*mean(means(means>0));
maxdist = 50; % standard: 50

% Could pass NC13 bounds to track_ms2 (uncomment lines in the function)
[trackms2 trackmat labeltrack trackmeta labelmov validTrackIdx ltrack4D trackAP] = track_ms2_ED(movie_analysis,maxdist,maxObjSize,0,overmeta); 

movie_analysis.tracking.trackms2 = trackms2;
movie_analysis.tracking.trackmat = trackmat;
movie_analysis.tracking.labeltrack = labeltrack;
movie_analysis.tracking.trackmeta = trackmeta;
movie_analysis.tracking.labelmov = labelmov;
movie_analysis.tracking.ltrack4D = ltrack4D;
movie_analysis.tracking.validTrackIdx = validTrackIdx;
movie_analysis.tracking.trackAP = trackAP;
movie_analysis.NC13bounds = bounds;

%% Save 
save(analysispath,'movie_analysis','-v7.3') 

summary = struct;
summary.filename = movie_analysis.metadata.Filename;
summary.metadata = movie_analysis.metadata;
summary.overviewMetadata = movie_analysis.overviewMetadata; % includes ROI_APRange
summary.trackms2 = movie_analysis.tracking.trackms2;
summary.trackAP = movie_analysis.tracking.trackAP;
summary.labelmov = movie_analysis.tracking.labelmov;
summary.ms2MaskMax = squeeze(sum(movie_analysis.ms2Mask,3)); % allows for checking spot segmentation
summary.overmax = movie_analysis.overviewMax;
summary.NC13bounds = bounds;

save(summarypath,'summary','-v7.3') 