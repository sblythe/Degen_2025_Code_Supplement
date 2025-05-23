function roi = select_image_ROI2(image)
% this version doesn't work on inputs that are cell arrays. The other one
% does.

figure
imagesc(image, [min(range(image)), max(range(image))] ); axis image

roi = impoly; 
% position = wait(roi);
roi = createMask(roi);