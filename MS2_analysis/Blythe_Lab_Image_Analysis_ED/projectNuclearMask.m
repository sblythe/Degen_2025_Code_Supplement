function nucmax = projectNuclearMask(nucmask, hMin)

nucmax = squeeze(max(nucmask, [], 3));

for t = 1:size(nucmax,3)
    bw = nucmax(:,:,t);
    D1 = -bwdist(~bw);
    mask = imextendedmin(D1,hMin);  
    D2 = imimposemin(D1, mask);
    D2L = watershed(D2);
    bgm = D2L == 0;
    bw(bgm == 1) = 0;
    nucmax(:,:,t) = bw;
end 


