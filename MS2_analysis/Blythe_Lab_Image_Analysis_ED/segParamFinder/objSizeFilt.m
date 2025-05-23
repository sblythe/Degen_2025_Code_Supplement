function [filt] = objSizeFilt(spotmask, minRad, maxRad, minPlane, exclude)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

sizeT = size(spotmask, 4);
filt = zeros(size(spotmask));

disp('filtering spots based on object size')
disp('')
minVol = (minRad^2);
maxVol = maxRad^2; 

minPlane = 1; 

h3 = waitbar(0,'filtering spots based on object size');

for t = 1:sizeT
    X = t/sizeT; waitbar(X);
    clear cc
    cc = bwconncomp(spotmask(:,:,:,t), 6);
    pixels_Index = regionprops(cc, 'PixelIdxList');
    pixels_yxz = regionprops(cc, 'pixellist');
    
    Nobj = cc.NumObjects;
%     % first off, which objects have suboptimal volume?
%     voltest = nan;
%     for v = 1 : Nobj
%         clear vol
%         vol = length(pixels_Index(v).PixelIdxList);
%         voltest = [voltest, vol>=minVol & vol<=maxVol];
%     end
%     voltest = voltest(2:end);
    
    % voltest but using an obj max xy area instead of xyz volume
    voltest = nan;
    for v = 1 : Nobj
        zList = pixels_yxz(v).PixelList(:,3);
        zFreq = countUnique(zList);
        vol = max(zFreq);
        voltest = [voltest, vol>=minVol & vol<=maxVol];
    end
    voltest = voltest(2:end);
    
    % next, which objects are present on more than one z-plane?
    planetest = nan;
    toptest = nan;
    for v = 1 : Nobj
        clear plane
        plane = length(unique(pixels_yxz(v).PixelList(:,3)));
        topper = unique(pixels_yxz(v).PixelList(:,3));
        planetest = [planetest, plane >= minPlane];
        toptest = [toptest, ~any(topper == exclude)];
    end
    planetest = planetest(2:end);
    toptest = toptest(2:end);
        
    % for each of these, I can now do some filtering. 
    keeper = voltest & planetest & toptest;
    keeper = find(keeper);
    
    newbw = zeros(size(spotmask,1), size(spotmask,2), size(spotmask,3));
    for k = 1:length(keeper)
        newspot = pixels_Index(keeper(k)).PixelIdxList;
        newbw(newspot) = 1;
    end
    
    filt(:,:,:,t) = newbw;   
end
close(h3)

end




function [freq, uniq] = countUnique(X)
% Returns frequency of elements in given array

X = X(~isnan(X));
uniq = unique(X);
freq = [];

for i = 1:length(uniq)
    freq(i) = sum(X == uniq(i));
end

end
