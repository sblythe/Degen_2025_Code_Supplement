function validTrackIdx = filterTrack(trackmat, trLabel, minObjSize, maxObjSize, minTrackLife)
% FILTERTRACK Returns a list of tracks that meet requirements for object
% size and track length
%   Object size parameters helpful for removing tracks that include
%   over/under segmented nuclei
%
%        TRACKMAT : (see trackNuclei.m)
%        TRLABEL : (see labelTrack.m)


validTrackIdx = [];

trackLife = sum(~isnan(trackmat), 2);
validLife = find(trackLife >= minTrackLife);

filtSize = [];
sizeT = size(trLabel,3);
for t = 1:sizeT
    frame = trLabel(:,:,t);
    framelabels = unique(frame); framelabels(framelabels == 0) = [];
    cc = bwconncomp(frame);
    objSz = cellfun(@length, cc.PixelIdxList);
    filtSize = cat(1, filtSize, framelabels((objSz <= minObjSize | objSz > maxObjSize)));
%     filtSize = [filtSize; framelabels((objSz <= minObjSize | objSz > maxObjSize))]; % alternative added by Ellie 2/8/24
end
filtSize = unique(filtSize);

validTrackIdx = setdiff(validLife, filtSize);

end

%trackmatf = trackmat(validTrackIdx,:);
%labeltrackf(labeltrack == validTrackIdx) = NaN;