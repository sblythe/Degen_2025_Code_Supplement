% this function will apply the parameters generated in the
% "build_analysis_parameters" script in order to save a mask of segmented 
% nuclei and a mask of parB spots.
% besides the input parameters, it also contains a logical that determines
% whether or not to save the data. 
% updated 9/5/18

function [output] = parametrized_analysis_v2(parameters, saveoutput)

parp = gcp('nocreate');
if isempty(parp)
    parpool(10)
end

% import movie

[allI,allmeta] = parameters.importFunction(parameters.filename, ...
    parameters.importSkip, parameters.importIncludeLast);

data = allI(1);
overview = allI{2};
meta = allmeta{1};
overmeta = allmeta{2};

meta.getUserInput = 1;

Isplit = parameters.channelSplitFunction(data{1,1}, meta);

overIsplit = parameters.channelSplitFunction(overview, overmeta);

parI = Isplit{parameters.parChannel};
parmat = parameters.imageArrayingFunction(parI, meta);

hisI = Isplit{parameters.histoneChannel};
hismat = parameters.imageArrayingFunction(hisI, meta);

overI = overIsplit{parameters.histoneChannel};
overmat = parameters.imageArrayingFunction(overI, overmeta);

lastmax = max(cat(3, hismat(:,:,:,meta.SizeT)), [], 3);
overmax = max(cat(3, overmat), [], 3);


% Segment Nuclei

nucmask = parameters.nuclearSegmentationFunction(hismat, meta, ...
    parameters.smoothSigma, parameters.openSphereRad, ...
    parameters.lowerVolCutoffRad);


% Find ParB foci

parCE = parameters.contrastEnhanceFunction(parmat, meta, ...
    parameters.contrastEnhanceSphereRad);

parDOG = parameters.dogFunction(parCE, meta, ...
    parameters.DoGsigma1, parameters.DoGsigma2);

parDOGf = parameters.filterFunction(parDOG, nucmask, meta, ...
    parameters.minFocusVolRad, parameters.maxFocusVolRad, ...
    parameters.minFocusPlaneOccupancy, parameters.excludeFociInPlane, ...
    parameters.focusIntensityPvalCutoff, parameters.minTotalIntensity);


% make an overview movie

check = parameters.checkMovieFunction(meta, parDOGf, nucmask, hismat);

output = struct;
output.analysisDate = datetime;
output.parameters = parameters;
output.metadata = meta;
output.overviewMetadata = overmeta;
output.overviewMax = overmax;
output.lastMax = lastmax;
output.nuclearMask = nucmask;
output.parSpots = parDOGf;
output.segmentationCheckMovie = check;
output.histoneRFP = hismat;

if saveoutput
    % check if an output directory exists:
    [~ , basename] = fileparts(parameters.filename);

    if ~exist(strcat(parameters.saveDirectory, filesep, ...
            basename,'_analysis'),'dir')
        mkdir(strcat(parameters.saveDirectory, filesep, ...
            basename,'_analysis'))
    end
    
    savefile = strcat(parameters.saveDirectory, filesep, basename, ...
        '_analysis',filesep,'initial_analysis');
    save(savefile, '-struct', 'output', '-v7.3')
end


