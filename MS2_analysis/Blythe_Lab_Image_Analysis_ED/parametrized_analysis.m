% this function will apply the parameters generated in the
% "build_analysis_parameters" script and output the location of parB foci
% along the sampled AP axis.
% besides the input parameters, it also contains a logical that determines
% whether or not to save the data. 

function [output] = parametrized_analysis(parameters, saveoutput)

parp = gcp('nocreate');
if isempty(parp)
    parpool(6);
end

% import movie

data = import_movie(parameters);
hismat = data.allChannels(:,:,:,:,parameters.histoneChannel);
mcpmat = data.allChannels(:,:,:,:,parameters.mcpChannel);


% [allI,allmeta] = parameters.importFunction(parameters.filename, ...
%     parameters.importSkip, parameters.importIncludeLast);
% 
% data = allI(1);
% overview = allI{2};
% meta = allmeta{1};
% overmeta = allmeta{2};
% 
% Isplit = parameters.channelSplitFunction(data{1,1}, meta);
% 
% overIsplit = parameters.channelSplitFunction(overview, overmeta);
% 
% parI = Isplit{parameters.parChannel};
% parmat = parameters.imageArrayingFunction(parI, meta);
% 
% hisI = Isplit{parameters.histoneChannel};
% hismat = parameters.imageArrayingFunction(hisI, meta);
% 
% overI = overIsplit{parameters.histoneChannel};
% overmat = parameters.imageArrayingFunction(overI, overmeta);
% 
% lastmax = max(cat(3, hismat(:,:,:,meta.SizeT)), [], 3);
% overmax = max(cat(3, overmat), [], 3);


% Find AP axis position of the movie.

overmeta = data.overmeta;

% overmeta = parameters.flipCheckFunction({imrotate(data.overmax,90)}, overmeta);
% 
% overmeta = parameters.apAxisFindingFunction(data.overmax, data.lastmax, ...
%     overmeta, data.meta);


% Segment Nuclei

nucmask = parameters.nuclearSegmentationFunction(hismat, parameters);

% Find MCP foci

ce = parameters.contrastEnhanceFunction(mcpmat, ...
    parameters.contrastEnhanceSphereRad);

dog = parameters.dogFunction(ce, parameters.DoGsigma1, ...
    parameters.DoGsigma2);

if parameters.filterByNucmask
    dog2 = nucmaskFilt(dog, nucmask, NaN);
end

bw = zeros(size(dog2));
for t = 1:size(dog2,4)
    bw(:,:,:,t) = imbinarize(dog2(:,:,:,t), 'global');
end

bwf = parameters.filterFunction(bw, parameters.minFocusVolRad, ...
    parameters.maxFocusVolRad, parameters.minFocusPlaneOccupancy, ...
    parameters.excludeFociInPlane);


% % Find ParB foci
% 
% parCE = parameters.contrastEnhanceFunction(parmat, meta, ...
%     parameters.contrastEnhanceSphereRad);
% 
% parDOG = parameters.dogFunction(parCE, meta, ...
%     parameters.DoGsigma1, parameters.DoGsigma2);
% 
% parDOGf = parameters.filterFunction(parDOG, nucmask, meta, ...
%     parameters.minFocusVolRad, parameters.maxFocusVolRad, ...
%     parameters.minFocusPlaneOccupancy, parameters.excludeFociInPlane, ...
%     parameters.focusIntensityPvalCutoff);


% make an overview movie

check = parameters.checkMovieFunction(data.meta, bwf, nucmask, hismat);

implay(check)


% compile output

output.analysisDate = datetime;
output.parameters = parameters;
output.meta = data.meta;
output.overmeta = overmeta;
output.lastmax = data.lastmax;
output.overmax = data.overmax;
output.nucmask = nucmask;
output.mcpmask = bwf;
output.segmentationCheckMovie = check;

if saveoutput
    % check if an output directory exists:
    [~ , basename] = fileparts(parameters.filename);
    savefile = strcat(parameters.saveDirectory, filesep, ...
            basename,'_analysis');

    if ~exist(savefile,'dir')
        mkdir(savefile)
    end

    save(strcat(savefile, filesep, 'initial_analysis'),'output','-v7.3')
end

