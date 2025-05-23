%% Load
fprintf('Running tracking demo ... \n')

% filename = '/Users/grad/Documents/MATLAB/Blythe_Lab_Image_Analysis-master 2/track_nuclei/demo_samples.mat';
% load(filename)

% analysis_struct=hbp2_201103_analysis;
% NC13bounds=[9 57];

% analysis_struct=kni64_201116_analysis;
% NC13bounds=[13 61];

analysis_struct=gt10_201124_analysis;
NC13bounds=[13 60];
% For gt, you seee spots frame 26 to 54
% NC13bounds=[26 54];

intmat=analysis_struct.ms2Mask.*double(analysis_struct.ms2); %mask 
intmat=intmat(:,:,:,NC13bounds(1):NC13bounds(2));
nucmask=analysis_struct.nuclearMask;
nucmask=nucmask(:,:,:,NC13bounds(1):NC13bounds(2));
hMin=0.5;
nucmax = projectNuclearMask(nucmask, hMin);

%% Track
fprintf('Tracking nuclei ... \n')

trackmat = trackNuclei(nucmax,20);
labeltrack = labelTrack(trackmat, nucmax);

%% Filter track
fprintf('Filtering tracks by size and duration ... \n')

minObjSize = 0;
maxObjSize = 600;
minTrackLife = floor(size(nucmax,3)*0); % don't filter out any tracks here, wait until end

validTrackIdx = filterTrack(trackmat, labeltrack, minObjSize, maxObjSize, minTrackLife);
filtTrackIdx = setdiff(1:size(trackmat,1), validTrackIdx);

labeltrack_orig=labeltrack; % save labels if don't want to do filtering
temp = labeltrack; 
for i = 1:length(filtTrackIdx)
    temp(labeltrack == filtTrackIdx(i)) = NaN;
end
labeltrack = temp;

% track stats
sumtrack = sum(trackmat(~isnan(trackmat))>0, 2, 'omitnan');
nTrack = sum(sumtrack(validTrackIdx));
nOmit = sum(sumtrack(filtTrackIdx));
percTrack = round((nTrack / (nTrack + nOmit)) * 100);
fprintf('%d %% of all objects tracked after filtering \n', percTrack);


%% Color label nuclei by track
fprintf('Preparing labelled track movie... \n')

shuffle_cmap = 1;
mov = track2rgb(labeltrack, shuffle_cmap);
implay(mov)

%% Get intensities values for each tracked nucleus
fprintf('Calculating intensity for each track ... \n')

ltrack4D = labelTrack4D(labeltrack, nucmask); % converts label matrix to 4D
trackOpa = zeros(length(validTrackIdx), size(nucmask,4));
trackOpa = getObjTrackIntensity(ltrack4D, intmat, validTrackIdx);


%% Heatmap of intensity over time

figure;
trackOpa2=trackOpa+0.005;
trackOpa2(isnan(trackOpa2))=0;
imagesc(trackOpa2);
xlabel('Frames')
ylabel('Nuclei')
title('Relative Nuclear Intensity')
cmap = [1 1 1; parula];
colormap(cmap)
caxis([0 max(trackOpa(:))]);
colorbar

figure; 
plot(trackOpa', 'Color', [0.2, 0.4, 0.7, 0.2])
%% Misc

% Leave out any tracks that have a nan in the "prime time" of ms2
rowmean=nanmean(trackOpa,1);
% figure;plot(rowmean)
ms2bounds=[min(find(rowmean)) max(find(rowmean))];
cropped=trackOpa(:,ms2bounds(1):ms2bounds(2));
colsum=sum(cropped,2);
track_continuousMS2=trackOpa(~isnan(colsum),:);

figure;
continuous2=track_continuousMS2+0.007; % 0.007 for gt, 0.005 for hb and kni
continuous2(isnan(continuous2))=0;
imagesc(continuous2);
xlabel('Frames')
ylabel('Nuclei')
title('MS2 Signal (continuous tracks)')
cmap = [1 1 1; parula];
colormap(cmap)
caxis([0 max(continuous2(:))]);
colorbar

% Filter out tracks that have nans in the prime time section (where ms2
% signal is)

fprintf('Done! \n')
