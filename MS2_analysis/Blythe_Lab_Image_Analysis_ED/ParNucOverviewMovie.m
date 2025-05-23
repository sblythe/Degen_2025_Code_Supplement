function movie = ParNucOverviewMovie(meta, pardata, nucdata, rawnuc)
% this function makes an overview movie of the par segmentation data and the nuclear
% segmentation showing nucs in red outlines and par spots as green dots. 
for t = 1 : meta.SizeT
     nucmax(:,:,t) = max(cat(3, nucdata(:,:,:,t)), [], 3);
     hismax(:,:,t) = max(cat(3, rawnuc(:,:,:,t)), [], 3);
     parmax(:,:,t) = max(cat(3, pardata(:,:,:,t)), [], 3);
end

for t = 1 : meta.SizeT
    over = imoverlay(imadjust(hismax(:,:,t)), bwmorph(nucmax(:,:,t),'remove'), [1 0 0]);
    over2 = imoverlay(over, parmax(:,:,t), [0 1 0]);
    movie(:,:,:,t) = over2;
end

