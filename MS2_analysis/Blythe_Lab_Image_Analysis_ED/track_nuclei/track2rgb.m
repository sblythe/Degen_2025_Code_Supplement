function rgbmat = track2rgb(mat, shuffle, custom_cmap)

% TRACK2RGB assigns color value to nuclei based on track labelled matrix
%        MAT : 3D (y,x,t) matrix of track labelled nuclear masks (see labelTrack())
%        SHUFFLE : logical; if 1 cmap color order is shuffled
%        CUSTOM_CMAP (optional) : default cmap jet
%
% created: 04/27/20
% last updated: 04/28/20

sizeT = size(mat, 3);

numlabels = max(mat(:));

if ~exist('custom_cmap')
    cmap = jet(numlabels);
else
    cmap = custom_cmap;
end

% shuffle cmap
if shuffle == 1    
    stream = RandStream('swb2712','seed',0);
    index = randperm(stream,numlabels);
    cmap = cmap(index,:,:);
else
    cmap = cmap(1:numlabels,:,:);
end

% objects labelled with NaN are given a numeric value (1 + max)
% last value in cmap is set to grey for NaN objects
if(sum(isnan(mat(:))) > 0)
    greytrack = 1;
    mat(isnan(mat)) = numlabels + 1;
    cmap(end+1,:) = [0.2,0.2,0.2];
end

% build rgb matrix
rgbmat = uint8(zeros(size(mat,1), size(mat,2), 3, size(mat,4)));
for t = 1:sizeT 
    frame = mat(:,:,t);
    rgbframe = label2rgb(frame, cmap, [0,0,0]);
    rgbmat(:,:,:,t) = rgbframe;
end



end