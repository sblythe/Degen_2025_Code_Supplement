function parDOG = parDoG4D(par4D, sig1, sig2)
% This function will take a 4D dataset and calculate the 3D difference of
% gaussians for each timepoint t. Optimized on 5/29/18 with sig1 = 2, and
% sig2 = 4.

sizeT = size(par4D, 4);
coeff = 1; % ????

h1 = waitbar(0, 'performing DoG filtering on input');
for t = 1 : sizeT
   X = t/sizeT; waitbar(X);
   pargauss1 = imgaussfilt3(par4D(:,:,:,t).*coeff,sig1);
   pargauss2 = imgaussfilt3(par4D(:,:,:,t).*coeff,sig2);
   parDOG(:,:,:,t) = pargauss1 - pargauss2; 
end
close(h1);