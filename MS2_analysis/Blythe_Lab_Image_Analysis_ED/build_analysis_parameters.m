% Build Analysis Parameters: this is a script that will produce a
% parameters list for the analysis of ParB-GFP movies. Placeholder
% parameters here were used for a successful analysis of the indicated
% movie. Some of these need to be changed for every sample (e.g., filename)
% but most you want to keep the same for an entire analysis. 

clear
parameters = struct;

% Creation date
parameters.date = datetime;

% Import Parameters

% Enter the full path to the file to analyze
parameters.filename = '/Volumes/BLYTHE_DATA/Northwestern_Imaging_Copy/180608_2xnosParB_4xParSgt10_2.lif';

% Do any of the series in this file need to be skipped? If so, enter the
% series number in a vector. This is useful if you forgot to delete the 
% acquisition of the tile scan and need to omit this. (0 = don't skip any)
parameters.importSkip = 0;

% Do you want to include the last series as part of the movie, or is this
% an overview (tiled whole embryo) image? It should be an overview image if
% you want to determine the AP axis position of the movie. (0 = export the
% last series as a separate series).
parameters.importIncludeLast = 0;

% Which channel is the histone channel?
parameters.histoneChannel = 2;

% Which channel is the ParB channel?
parameters.parChannel = 1;

% These are the functions that will be used for importing the data.
parameters.importFunction = @stitcherV2;
parameters.channelSplitFunction = @split_channels;
parameters.imageArrayingFunction = @make4D;


% Axis Finding Parameters

% These are the functions that will be used to find the AP position of the
% movie that you've taken. 
parameters.flipCheckFunction = @add_flip_to_metadata;
parameters.apAxisFindingFunction = @findAPaxis;


% Nuclear Segmentation Parameters

% what is the 3D smoothing kernel for processing the raw histone image
% prior to nuclear segmentation?
parameters.smoothSigma = 3;

% what is the 3D kernel for performing morphological opening? 
parameters.openSphereRad = 7;

% what is the minimum volume radius (in pixels) for an object that is to be kept?
parameters.lowerVolCutoffRad = 15;

% This is the function that will perform 3D nuclear segmentation.
parameters.nuclearSegmentationFunction = @nucSeg4Dglobal;


% ParB Foci Finding Parameters

% what are the smoothing kernels that will be used for the first and second
% gaussian smoothing filters? These will be subtracted from one another to
% perform Difference of Gaussians filtering to identify ParB foci. The
% ratio between the two should be between 1:2 (more stringent) and 1:5
% (less stringent).
parameters.DoGsigma1 = 1;
parameters.DoGsigma2 = 2;

% what is the kernel for the contrast enhance function? 
parameters.contrastEnhanceSphereRad = 3;

% what are the minimum and maximum radii (in pixels) of ParB focal volumes?
parameters.minFocusVolRad = 3;
parameters.maxFocusVolRad = 100;

% what is the minimum number of Z-planes that a ParB focus must occupy in
% order for it to be kept?
parameters.minFocusPlaneOccupancy = 3;

% for which Z-planes do you want to exclude an object that passes the prior
% criteria? For example, if you caught too much of the chorion in one of
% the movies, you might want to exclude any Z-planes that contain the
% chorion. (0 = do not exclude any planes).
parameters.excludeFociInPlane = 0;

% what is the upper p-value limit of focal intensity for which you would
% like to keep a focus?
parameters.focusIntensityPvalCutoff = 0.05;

% these are the functions that perform the ParB focus finding.
parameters.contrastEnhanceFunction = @parContrastEnhance;
parameters.dogFunction = @parDoG4D;
parameters.filterFunction = @filterDOG;


% This function produces a movie of projected data to allow for checking
% the nuclear and ParB segmentation.
parameters.checkMovieFunction = @ParNucOverviewMovie;





