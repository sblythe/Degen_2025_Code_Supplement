function trLabel = labelTrack(trackmat, nucmax)
% LABELTRACK Build a matrix that labels nuclei by their track number.
%   Individual tracks are referenced by their row number in
%   trackmat. Assign row number (track number) to corresponding objects in 
%   nucmax
%   
%        TRACKMAT : n x t matrix containing indices of tracked objects (see
%        trackNuclei())
%        NUCMAX : max projected nuclear mask 

trLabel = zeros(size(nucmax));
for t = 1:size(nucmax,3)
    blank = zeros(size(nucmax,1), size(nucmax,2));
    L = bwlabel(nucmax(:,:,t));
    for i = 1:size(trackmat,1)
        nucIdx = trackmat(i,t);
        nucPixels = find(L == nucIdx);
        if ~isempty(nucPixels)
            blank(nucPixels) = i;
        end
    end
    trLabel(:,:,t) = blank;
end

end
    
