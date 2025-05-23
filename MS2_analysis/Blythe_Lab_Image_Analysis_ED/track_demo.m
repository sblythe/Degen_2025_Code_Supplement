%% Load
fprintf('Running tracking demo ... \n')

filename = '/Users/isabella/Documents/MATLAB/tracking_functions/tracking_samples.mat';
load(filename)

%% Track
fprintf('Tracking nuclei ... \n')

trackmat = nucTracker_v3(nucmax);
labeltrack = labelTrack(trackmat, nucmax);

%% Filter track
fprintf('Filtering tracks by size and duration ... \n')

minObjSize = 0;
maxObjSize = 400;
minTrackLife = 10;

validTrackIdx = filterTrack(trackmat, labeltrack, minObjSize, maxObjSize, minTrackLife);
filtTrackIdx = setdiff(1:size(trackmat,1), validTrackIdx);

temp = labeltrack; 
for i = 1:length(filtTrackIdx)
    temp(labeltrack == filtTrackIdx(i)) = NaN;
end
labeltrack = temp;

% track stats
sumtrack = sum(trackmat, 2, 'omitnan');
nTrack = sum(sumtrack(validTrackIdx));
nOmit = sum(sumtrack(filtTrackIdx));
percTrack = round((nTrack / (nTrack + nOmit)) * 100);
fprintf('%d %% of all objects tracked after filtering', percTrack);


%% Color label nuclei by track
fprintf('Preparing labelled track movie... \n')

shuffle_cmap = 0;
mov = track2rgb(labeltrack, shuffle_cmap);
implay(mov)

%% Get intensities values for each tracked nucleus
fprintf('Calculating intensity for each track ... \n')

ltrack4D = labeltrack4D(labeltrack, nucmask); % converts label matrix to 4D
trackOpa = zeros(length(validTrackIdx), size(nucmask,4));
trackOpa = getObjTrackIntensity(ltrack4D, opamat, validTrackIdx);


%% Heatmap of intensity over time

figure;
imagesc(trackOpa);
xlabel('Frames')
ylabel('Nuclei')
title('Relative Nuclear Intensity')

%% Misc

fprintf('Done! \n')
