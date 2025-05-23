function [trackms2 trackmat labeltrack trackmeta mov validTrackIdx ltrack4D trackAP]=track_ms2_ED(analysis_struct,max_dist,maxObjSize,minObjSize,overmeta)
    fprintf('Tracking nuclei ... \n')

    intmat=analysis_struct.ms2Mask.*double(analysis_struct.ms2);
    nucmask=analysis_struct.nuclearMask;
    hMin=analysis_struct.parameters.hMin;
    nucmax = projectNuclearMask(nucmask, hMin);


    % Track
    fprintf('Tracking nuclei ... \n')

    implay(nucmax)
    trackmat = trackNuclei(nucmax,max_dist);
    labeltrack = labelTrack(trackmat, nucmax);


    % Filter track
    fprintf('Filtering tracks by size and duration ... \n')

%     minObjSize = 0;
    minTrackLife = 0; % don't filter out any tracks here, wait until end

    trackmeta.minObjSize=minObjSize;
    trackmeta.maxObjSize=maxObjSize;
    trackmeta.minTrackLife=minTrackLife;

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


    % Color label nuclei by track
    fprintf('Preparing labelled track movie... \n')

    shuffle_cmap = 1;
    mov = track2rgb(labeltrack, shuffle_cmap);
    implay(mov)


    % Get intensities values for each tracked nucleus
    fprintf('Calculating intensity for each track ... \n')

    ltrack4D = labelTrack4D(labeltrack, nucmask); % converts label matrix to 4D
    trackms2 = zeros(length(validTrackIdx), size(nucmask,4));
    [trackms2 trackAP] = getObjTrackIntensity_ED(ltrack4D, intmat, validTrackIdx, overmeta);


    % Heatmaps of intensity over time
    figure;
    trackms2_2=trackms2+10;
    trackms2_2(isnan(trackms2_2))=0;
    imagesc(trackms2_2);
    xlabel('Frames')
    ylabel('Nuclei')
    title('Relative Nuclear Intensity')
    cmap = [1 1 1; parula];
    colormap(cmap)
    caxis([0 max(trackms2(:))]);
    colorbar

    figure; 
    plot(trackms2', 'Color', [0.2, 0.4, 0.7, 0.2])


    fprintf('Done! \n')
end
