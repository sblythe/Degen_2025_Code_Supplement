

function [filtered2, poissP, allvol] = filterDOG3(DOG, nucs, meta, minvolrad, maxvolrad, minplane, exclude, pval, intCutOff)
% updated from filterDOG2 to set individual poissP for each T

disp('eliminating pixels outside of nuclear masks')
disp('')
h1 = waitbar(0, 'eliminating pixels outside of nuclear masks');
for t = 1 : meta.SizeT
    X = (t/meta.SizeT); waitbar(X);
    p = DOG(:,:,:,t);
    n = nucs(:,:,:,t);
    p(~n) = 0;
    DOGn(:,:,:,t) = p;
end
close(h1);

disp('calculating poisson p-value to estimate the noise floor')
disp('')
for t = 1:meta.SizeT
    I = double(reshape(DOGn(:,:,:,t), 1, []));
    I = I(I>0);
    poiss = poisspdf([1:max(I)], mean(I));

    if ~isempty(find(poiss<pval,1)) % added this if statement b/c ran into issue of empty vector
        poissP(t) = find(poiss<pval, 1);

        ii = 2;
        while poissP(t) < mean(I)
            temp = find(poiss<pval, ii);
            poissP(t) = temp(ii);
            ii = ii + 1;
        end
    else
        poissP(t)=nan; % added this b/c ran into issue of empty vector
    end
end

disp('eliminating pixels with values below selected poisson p-value')
disp('binarizing the DOG image')
disp('')
DOGnp = zeros(meta.SizeY, meta.SizeX, meta.SizeZ, meta.SizeT);
DOGnpbw = DOGnp;

h2 = waitbar(0, 'binarizing the DOG image');
for t = 1 : meta.SizeT
    X = t/meta.SizeT; waitbar(X);
    p = DOG(:,:,:,t);      %p = DOGn(:,:,:,t) if eliminating spots outside nucleus
    p(p < poissP(t)) = 0;
    DOGnp(:,:,:,t) = p;
    pbw = imopen(p, strel('sphere',1));
    DOGnpbw(:,:,:,t) = imbinarize(pbw);
end
close(h2)

disp('filtering spots based on input criteria')
disp('')
minvol = minvolrad^3 ; % gotta be at least 3 pixels cubed in preliminary tests
maxvol = maxvolrad^3 ; % gotta be at most 8 pixels cubed in preliminary tests
%minplane = 2 ; % gotta be present on at least three planes. no max currently set.
%exclude = 1; % exclude any object that is present in slice 1.

h3 = waitbar(0,'filtering spots based on input criteria');

for t = 1 : meta.SizeT
    X = t/meta.SizeT; waitbar(X);
    clear cc
    cc = bwconncomp(DOGnpbw(:,:,:,t), 26);
    pixels_Index = regionprops(cc, 'PixelIdxList');
    pixels_yxz = regionprops(cc, 'pixellist');
    
    Nobj = cc.NumObjects;
    % first off, which objects have suboptimal volume?
    voltest = nan;
    for v = 1 : Nobj
        clear vol
        vol = length(pixels_Index(v).PixelIdxList);
        voltest = [voltest, vol>=minvol & vol<=maxvol];
    end
    voltest = voltest(2:end);
        
    % next, which objects are present on more than one z-plane?
    planetest = nan;
    toptest = nan;
    for v = 1 : Nobj
        clear plane
        plane = length(unique(pixels_yxz(v).PixelList(:,3)));
        topper = unique(pixels_yxz(v).PixelList(:,3));
        planetest = [planetest, plane >= minplane];
        toptest = [toptest, ~any(topper == exclude)];
    end
    planetest = planetest(2:end);
    toptest = toptest(2:end);
        
    % for each of these, I can now do some filtering. 
    keeper = voltest & planetest & toptest;
    keeper = find(keeper);
    
    newbw = zeros(size(DOGnpbw,1), size(DOGnpbw,2), size(DOGnpbw,3));
    for k = 1 : length(keeper)
        newspot = pixels_Index(keeper(k)).PixelIdxList;
        newbw(newspot) = 1;
    end
    
    filtered(:,:,:,t) = newbw;
    
    % let's calculate some statistics:
    if t == 1
        allvol = nan;
    end
    clear cc
    cc = bwconncomp(newbw);
    px = regionprops(cc, 'Area');
    allvol = [allvol, [px.Area]];
end
close(h3)


disp('eliminating pixels outside of nuclear masks')
disp('')
h1 = waitbar(0, 'eliminating pixels outside of nuclear masks');
for t = 1 : meta.SizeT
    X = (t/meta.SizeT); waitbar(X);
    p = filtered(:,:,:,t);
    n = nucs(:,:,:,t);
    p(~n) = 0;
    filtered(:,:,:,t) = p;
end
close(h1);

disp('additional filtering on total intensity')
disp('')
filtered2 = zeros(size(filtered));
for t = 1:meta.SizeT
    this_img = DOG(:,:,:,t);
    this_filter = filtered(:,:,:,t);
    cc = bwconncomp(this_filter, 26);
    pix_int = [0];
    for j = 1:cc.NumObjects
       pixels = cc.PixelIdxList{j};
       pix_int(j) = sum(this_img(pixels));
       if pix_int < intCutOff
           this_filter(pixels) = 0;
       end
    end   
    filtered2(:,:,:,t) = this_filter;
end



disp('done')