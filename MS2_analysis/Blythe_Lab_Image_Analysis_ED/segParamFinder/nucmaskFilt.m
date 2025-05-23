function [imgfilt] = nucmaskFilt(imgmat, nucmask, dilRad)
%nucmaskFilt eliminate pixels outside nuclear mask, with an option for 
% dilating nucmask prior to filtering

sizeT = size(imgmat, 4);
imgfilt = imgmat;

disp('eliminating pixels outside of nuclear masks')
disp('')

if ~isnan(dilRad)
    se = strel('sphere', dilRad);
    for t = 1:sizeT
        nucmask(:,:,:,t) = imdilate(nucmask(:,:,:,t), se);
    end
end

imgfilt(~nucmask) = 0;

% h1 = waitbar(0, 'eliminating pixels outside of nuclear masks');
% for t = 1:sizeT
%     X = (t/sizeT); waitbar(X);
%     p = imgmat(:,:,:,t);
%     n = nucmask(:,:,:,t);
%     p(~n) = 0;
%     imgfilt(:,:,:,t) = p;
% end
% close(h1);



end

