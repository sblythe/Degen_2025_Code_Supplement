function [trackInt trackAP trackInt_nan] = getObjTrackIntensity_ED(trLabel, intmat, validTrackIdx, overmeta)
%   GETOBJTRACKINTENSITY returns intensity over time for individual tracked
%   nuclei. Rows index track number. Columns index time tracked.
%
%        TRLABEL : 4D (y,x,z,t) track labelled matrix (see labelTrack4D.m)
%        INTMAT : intensity matrix from the channel you wish to measure
%        VALIDTRACKIDX : index of tracks for which to calculate intensity

sizeT = size(trLabel, 4);
trackInt = NaN(length(validTrackIdx), sizeT);
trackAP = NaN(length(validTrackIdx), sizeT);
trackInt_nan = NaN(length(validTrackIdx), sizeT);

h = waitbar(0);

for t = 1:size(trLabel, 4)
    waitbar(t/size(trLabel,4), h)
    L = trLabel(:,:,:,t);
    img = intmat(:,:,:,t);
    for i = 1:length(validTrackIdx)
        pixels = find(L == validTrackIdx(i));
        
        if ~isempty(pixels)
%             objInt = mean(img(pixels)); % Old code just averages
            
             if sum(img(pixels)>0)>0 
                    
                nucleus = img(pixels);
                spot = nucleus(nucleus>0);
                
%                 % If there is MS2 in the first or last frame, set the sum
%                 % of the spot to be nan
%                 [x,y,z] = ind2sub(size(img),pixels);
%                 z_nonzero=z(nucleus>0);
%                 if min(z_nonzero)==min(z) || max(z_nonzero)==max(z)
%                     objInt_nan=nan;
%                     objInt=sum(spot(:));
%                 else
                    objInt=sum(spot(:)); % Find sum of ms2 signal in spot volume
%                     objInt_nan=sum(spot(:));
%                 end
                
               
%                 [x,y,z] = ind2sub(size(img),pixels);
%                 z_nonzero=z(nucleus>0);
%                 if range(z_nonzero)>1
%                     chosen=pixels(z>=min(z_nonzero) & z<=min(z_nonzero)+2);
%                     nuc=img(chosen);
%                     spot=nuc(nuc>0);
%                     objInt=sum(spot(:)); % Find sum of ms2 signal in spot volume
%                 else
%                     objInt=0;
%                 end     

            else
                objInt=0;
            end         
            trackInt(i,t) = objInt;
%             trackInt_nan(i,t) = objInt_nan;
             
            % Calculate the AP position of the object in the track
            if ~isempty(overmeta)
                stats=regionprops(L== validTrackIdx(i));
                if length(stats)==1
                    centroid = round(stats(1).Centroid);
                    pos=overmeta.ROI_APMatrix(centroid(2),centroid(1));
                    trackAP(i,t) = pos;
                end 
            end
        end
    end
end

close(h);

end


