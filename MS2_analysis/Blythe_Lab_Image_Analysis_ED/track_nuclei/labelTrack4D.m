function ltrack4D = labelTrack4D(ltrack3D, nucmask)
% LABELTRACK4D Assigns labels from max projected tracks to their higher
% dimensional counterpart. 4D labels required for calculation object
% intensity accurately
%        LTRACK3D : 3D (y,x,t) track labelled matrix (see labelTrack())
%        NUCMASK : 4D (y,x,z,t) nuclear mask

ltrack4D = zeros(size(nucmask));
sizeT = size(nucmask, 4);
for t = 1:sizeT
    
    % find centroids with respect to (y,x,z), remove z dimension
    cc = bwconncomp(nucmask(:,:,:,t));
    props = regionprops(cc, 'Centroid');
    cent = cat(1, props.Centroid);
    cent = round(cent(:, 1:2));
    
    % using xy-centroids from nucmask, find the value at that position in
    % the 3D track label matrix
    L = ltrack3D(:,:,t);
    stack = zeros(size(nucmask(:,:,:,t))); 
    for i = 1:cc.NumObjects
        objValue = L(cent(i,2), cent(i,1));
        pixels = cc.PixelIdxList{i};
        stack(pixels) = objValue;
    end
    ltrack4D(:,:,:,t) = stack;
end
    
end

