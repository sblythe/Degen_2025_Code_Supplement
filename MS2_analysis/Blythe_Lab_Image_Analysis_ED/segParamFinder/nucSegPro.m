function nucmask = nucSegPro(nuc4D, parameters)
% 

sizeT = size(nuc4D, 4);

fprintf('Nuclear Segmentation Progress:\n');
fprintf(['\n' repmat('.',1, sizeT) '\n\n']);

SIG1 = parameters.sigma1;
SIG2 = parameters.sigma2;
BWM = parameters.bwMethod;
OSR = parameters.openSphereRad;
LVCR = parameters.lowerVolCutoffRad;
MP = parameters.minPlane;
HM = parameters.hMin;

parfor t = 1:sizeT
    fprintf('\b|\n');
    nuc = nuc4D(:,:,:,t);
    if isnan(SIG2)
        bw = imgaussfilt3(nuc, SIG1);
    else
        smo1 = imgaussfilt3(nuc, SIG1);
        smo2 = imgaussfilt3(nuc, SIG2);
        bw = smo2 - smo1;
    end
    
    if ~isnan(BWM)
        bw = imbinarize(bw, 'Global');
        if ~isnan(OSR)
            bw = imopen(bw, strel('sphere',OSR));
        end
        if ~isnan(LVCR)
            bw = bwareaopen(bw, LVCR^3, 18);
        end
        if ~isnan(MP)
            bw = objSizeFilt(bw, 0, inf, MP, []);
        end
    end
    
    if ~isnan(HM)
        % perform watershed below
        D1 = -bwdist(~bw);
        mask = imextendedmin(D1, HM);
        D2 = imimposemin(D1, mask);
        D2L = watershed(D2);
        bgm = D2L == 0;
        bw(bgm == 1) = 0;
    end
    
    % remove nuclei at border
    filled = bw;
    filler = zeros(size(filled,1), size(filled,2), 1);
    filled = cat(3,filler,filled,filler);
    cleared = imclearborder(filled);
    nucmask(:,:,:,t) = cleared(:,:,(2:(end-1)));
end
disp('done')
