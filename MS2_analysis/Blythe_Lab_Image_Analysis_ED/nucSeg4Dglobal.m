function nucmask = nucSeg4Dglobal(nuc4D, parameters)
% this function has been optimized as of 6/24/18. It currently runs well
% using the following input parameters: smoothSigma = 3; openSphereRad = 7;
% lowerVolCutoffRad = 15. It may need to have the variable for minima
% extension (default = 5, hard coded) made into a variable if too many or
% too few objects are separated. The optimization dataset did not include
% nuclear cycles 11 or 12, just 13-14. 

sizeT = size(nuc4D, 4);

disp('Updated with watershed, may not be compatible with older datasets')
fprintf('Nuclear Segmentation Progress:\n');
fprintf(['\n' repmat('.',1, sizeT) '\n\n']);

SS = parameters.smoothSigma;
OSR = parameters.openSphereRad;
LVCR = parameters.lowerVolCutoffRad;
HM = parameters.hMin;

parfor t = 1:sizeT
    fprintf('\b|\n');
    smo(:,:,:,t) = imgaussfilt3(nuc4D(:,:,:,t), SS);
    BWa(:,:,:,t) = imbinarize(smo(:,:,:,t), 'Global');
    BWb(:,:,:,t) = imopen(BWa(:,:,:,t), strel('sphere',OSR));
    bw = bwareaopen(BWb(:,:,:,t), LVCR^3, 18);
    % perform watershed below
    D1 = -bwdist(~bw);
    mask = imextendedmin(D1, HM);
    D2 = imimposemin(D1, mask);
    D2L = watershed(D2);
    bgm = D2L == 0;
    bw(bgm == 1) = 0;
    
    filled = bw;
    filler = zeros(size(filled,1), size(filled,2), 1);
    filled = cat(3,filler,filled,filler);
    cleared = imclearborder(filled);
    nucmask(:,:,:,t) = cleared(:,:,(2:(end-1)));
end
disp('done')
