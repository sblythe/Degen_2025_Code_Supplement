function rowIdx = getRowIdx(trackmat, t, ID)
% GETROWIDX returns the row idx of trackmat for a given time and object idx
%   Supporting function of trackNuclei.m 
    
t_track = trackmat(:,t);
rowIdx = find(t_track == ID);

end

