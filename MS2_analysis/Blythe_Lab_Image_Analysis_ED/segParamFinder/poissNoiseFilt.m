function [npImg] = poissNoiseFilt(imgmat, pval)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sizeT = size(imgmat, 4);

if ~class(imgmat, 'double')
    imgmat = im2double(imgmat);
end

disp('calculating poisson p-value to estimate the noise floor')
disp('')
I = reshape(imgmat, 1, []);
I = I(I>0);
poiss = poisspdf([1:max(I)], mean(I));

poissP = find(poiss<pval, 1);
if isempty(poissP)
    poissP = 0;
    disp('No pixels less than given pval')
end

disp('eliminating pixels with values below selected poisson p-value')
% disp('binarizing the DOG image')
disp('')
npImg = zeros(size(imgmat));
% DOGnpbw = DOGnp;

h2 = waitbar(0, 'binarizing the DOG image');
for t = 1 : sizeT
    X = t/sizeT; waitbar(X);
    
    p = imgmat(:,:,:,t);
    p(p < poissP) = 0;
    npImg(:,:,:,t) = p;
    
%     pbw = imopen(p, strel('sphere',1));  %% morphological opening, optional?   
%     DOGnpbw(:,:,:,t) = imbinarize(pbw);
end
close(h2)
end

