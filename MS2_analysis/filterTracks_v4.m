function filtered = filterTracks_v4(summary)

    % Sort tracks
    tagged_tracks = [mean(summary.trackAP,2,'omitnan') bin2D(summary.trackms2)]; % NOTE: this function filters binned data
    sorted_tagged = sortrows(tagged_tracks,1,'ascend');
    sorted_ms2 = sorted_tagged(:,2:end);

    % Leave out any tracks that are nan in the 'prime time' of ms2
    rowmean = mean(sorted_ms2,1,'omitnan');
    if find(rowmean)
        ms2bounds = [min(find(rowmean)) max(find(rowmean))];
    else
        ms2bounds = [round(size(sorted_ms2,2)/4) round(size(sorted_ms2,2)*3/4)]; % if the movie contains no ms2 signal
    end
    cropped = sorted_ms2(:,ms2bounds(1):ms2bounds(2));
    nonans_tagged = sorted_tagged(~isnan(sum(cropped,2)),:); % this still has nans where nuclei were not tracked
    filtered = nonans_tagged;
    
    % Set ms2 bursts that are < ~1.5 min long to 0
    minLength = 8;
    for i = 1:size(filtered,1)
        track = filtered(i,2:end);
        nonzeroTrack = track > 0;

        nonzero_n = 0;
        for j = 1:length(nonzeroTrack)
            
            if nonzeroTrack(j) == 1
                nonzero_n = nonzero_n + 1;

                if nonzero_n == minLength && j >= 80+minLength % any spots that appear after nuclear breakdown are just noise
                    track(j-nonzero_n:end) = 0;
                end

            elseif nonzeroTrack(j) == 0
     
                if nonzero_n < minLength

                    if j >= minLength 
                        
                        track(j-nonzero_n:j) = 0;

                        if j > length(track)-minLength % border case at the end of the nuclear cycle
                            track(j:end) = 0; 
                        end

                    elseif j < minLength % border case at the start of the nuclear cycle

                        track(1:j) = 0;

                    end

                end

                nonzero_n = 0; % re-set non-zero count
            end
        end
        filtered(i,2:end) = track;
    end
    
    filtered(:,2:11) = 0; % remove any noise in the first three minutes
    
    filtered(isnan(nonans_tagged)) = nan; % nan. NOTE the filtered matrix still has the AP position tags and nans where nuclei were not tracked
end
