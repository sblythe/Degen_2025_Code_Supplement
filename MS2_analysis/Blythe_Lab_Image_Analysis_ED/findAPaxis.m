function meta = findAPaxis(FullImage, AcqImage, FullMeta, AcqMeta)

% this function will output the metadata for the Full Image with added
% information about the AP positions of the acquired timelapse images.

disp('THIS FUNCTION ASSUMES YOU ARE ANALYZING CURRENT DATA')
disp('IT AUTOMATICALLY ROTATES THE IMAGE')
disp('...')
disp('NEEDS ADDITIONAL CHECKING TO ENSURE CORRECT ORIENTATION')

meta = FullMeta; % initialize the output variable.

% the input images are a full embryo view, and a representative image of
% the acquired timelapse images. Probably best that it be the last acquired
% image. We approximate the difference in spatial resolution between the
% two images by extracting from the metadata the spatial resolution of the
% X dimension (which should be close to the Y dimension as well).

FullRes = FullMeta.microns_per_pixel_X;
AcqRes = AcqMeta.microns_per_pixel_X;

% next we calculate a scaling factor that we will use later to 'shrink' the
% acquired image relative to the full embryo image.

expectedRatio = AcqRes/FullRes;
% ap_zoomFactorRange = (expectedRatio-0.1):0.05:(expectedRatio+0.1);


% this just unpacks the input image data in case it was supplied as a cell
% array instead of a straight-up image.

if iscell(FullImage)
    FullImage = FullImage{:};
end

if iscell(AcqImage)
    AcqImage = AcqImage{:};
end

% the new 'navigator' function doesn't change the angle of the data in two
% ways. All Leica images are rotated 90 degrees relative to the slide
% position. Then on top of that, you can rotate the image manually.
% Navigator provides data that is free of both of these parameters. This
% should be corrected for. 

% imRotationAngle = AcqMeta.RotationAngle;
imRotationAngle = -AcqMeta.RotationAngle;% changed to negative
defaultRotation = 90;
fullrotateadj = defaultRotation + imRotationAngle;

% the acquired image is assigned to the variable 'orig' because we are
% about to shrink it and we don't want to lose track of the original.
FullImage = imrotate(FullImage,fullrotateadj);
% AcqImage = imrotate(AcqImage,imRotationAngle); %added because ROI position was not correctly identified

orig = AcqImage;
scaleFactor = expectedRatio;
AcqImage = imresize(AcqImage,scaleFactor);

[ARows, AColumns] = size(AcqImage);

% Now we are going to measure the correlation between the shrunk acquired
% image and the full image. 
C = normxcorr2(AcqImage, FullImage);

[CRows,CColumns] = size(C);

C = C(floor(ARows/2):(CRows-floor(ARows/2)), floor(AColumns/2):(CColumns-floor(AColumns/2)));

[Max2, MaxRows] = max(C);
[~, MaxColumn] = max(Max2);
MaxRow = MaxRows(MaxColumn);

% This calculates the Row and Column on the Full Size image that the
% acquired image corresponds to. This represents the top left corner of the
% acquired image. 

ShiftRow = MaxRow - round(ARows/2+1);
ShiftColumn = MaxColumn - round(AColumns/2+1);



%Create an overlay to make sure things make sense

ImShifted=uint8(zeros(size(FullImage)));

RowRange = (1:ARows) + ShiftRow;
ColumnRange = (1:AColumns) + ShiftColumn;

ImShifted(RowRange,ColumnRange)=AcqImage;

figure(1) 
ImOverlay= cat(3,mat2gray(FullImage)+mat2gray(ImShifted),mat2gray(FullImage),mat2gray(FullImage));
imshow(ImOverlay)


% Now, we designate the position of the embryo, either manually, or via a
% previously incorporated metadata field entitled 'embryoMask'.

% if ~isfield(FullMeta,'embryoMask')
%     display('Select the embryo outline')
%     embryo = select_image_ROI2(FullImage);
%     
%     else embryo = FullMeta.embryoMask;
% end

display('Select the embryo outline')
embryo = select_image_ROI2(FullImage);
    
% extract the properties of the embryo mask and get the angle.

props = regionprops(embryo,'all');
angle = props.Orientation;

% rotate the embryo mask, calculate a rotation matrix, and calculate the
% positions of the major axis. All of this works because we are in
% principle measuring an ellipsoid, and we are interested in the properties
% of the major axis (AP).

mask_rot = imrotate(embryo, -angle);
rotMatrix = [cosd(angle) sind(angle)
            -sind(angle) cosd(angle)];

cc = bwconncomp(mask_rot);
props = regionprops(cc,'all');

majorAxisBegin = props.Centroid + [props.MajorAxisLength/2,0];
majorAxisEnd = props.Centroid - [props.MajorAxisLength/2,0];
minorAxisBegin = props.Centroid + [0, props.MinorAxisLength/2];
minorAxisEnd = props.Centroid - [0, props.MinorAxisLength/2];

% This function automatically extracts the anterior and posterior-most
% point of the embryo (the extrema) as the poles of the AP axis. This is
% usually accurate.

ext = props.Extrema;
coordP_rot = (ext(3,:)+ext(4,:))/2;
coordA_rot = (ext(7,:)+ext(8,:))/2;

% Now we check the metadata for the full embryo image and see whether we
% need to flip the positions of the AP axis. Note that we are only doing
% this on the positions of the poles. Nothing actually gets flipped except
% for the identifiers.

if FullMeta.flipAP
    temp = coordA_rot;
    coordA_rot = coordP_rot;
    coordP_rot = temp;
end

% coordA and coordP are the coordinates on the rotated image
% We should rotate them back to the coordinates of the original picture
% Remember that rotation was performed about the center of the image

%coordinates of the center of the rotated image
center_rot = 1/2*[size(mask_rot,2) size(mask_rot,1)];
%coordinates of the center of the original image
center = 1/2*[size(embryo,2) size(embryo,1)];

coordA = center + (rotMatrix * (coordA_rot-center_rot)')';
coordP = center + (rotMatrix * (coordP_rot-center_rot)')';


% diagnostic figure

figure(3)
ImOverlayRot= cat(3,mat2gray(imrotate(FullImage, -angle)) + ...
    mat2gray(imrotate(ImShifted, -angle)), ...
    mat2gray(imrotate(FullImage, -angle)), ...
    mat2gray(imrotate(FullImage, -angle)));
imshow(ImOverlayRot)


APAngle = atan((coordP(2)-coordA(2))/(coordP(1)-coordA(1)));
if coordP(1)-coordA(1) <0
    APAngle = APAngle + pi;
end
disp(APAngle)

APLength = sqrt((coordP(2)-coordA(2))^2 + (coordP(1) - coordA(1))^2);

% Take the coordinates of the Full Embryo
% image corresponding to the acquired image, subdivide them by the imaging
% resolution of the acquired image, and -- for each position -- calculate
% the position projected onto the AP axis. In practice, this works by
% choosing a point within the acquired image area, determining the shortest
% distance to the line designating the AP axis. By definition, this
% shortest distance is the 'opposite' side of a right triangle, where the
% hypotenuse is the distance from the chosen point to the anterior pole,
% and the adjacent side is the AP axis itself. With the information (
% opposite and hypotenuse ) we can calculate the angle (theta) and
% therefore, the length of the adjacent side. I am not currently 100% sure
% whether this works for all orientations of the embryo. 

xx = linspace(ShiftColumn, ShiftColumn + AColumns, AcqMeta.SizeX);
yy = linspace(ShiftRow, ShiftRow + ARows, AcqMeta.SizeY);

APMat = zeros(length(yy), length(xx));

for i = 1: length(xx);
    for j = 1 : length(yy);
        d = point_to_line([xx(i) yy(j) 0], [coordA 0], [coordP 0]);
        hyp = sqrt((yy(j) - coordA(2))^2 + (xx(i) - coordA(1))^2);
        APMat(j, i) = hyp*cos(asin(d/hyp)) / APLength;
    end
end

% lets add to the diagnostic plot two lines that will tell us if we are
% doing the right thing. One line from the AP axis to the top left corner
% of the acquired image, and another from the AP axis to the top right
% corner.

topLeft = [ShiftColumn ShiftRow];
topRight = [ShiftColumn + AColumns ShiftRow];
tL_AP = APMat(1,1) * APLength;
tR_AP = APMat(1,size(APMat,2)) * APLength;
tL_x_dist = tL_AP*cos(APAngle);
tL_y_dist = tL_AP*sin(APAngle);
tL_coord = [tL_x_dist + coordA(1) tL_y_dist + coordA(2)];
tR_x_dist = tR_AP*cos(APAngle);
tR_y_dist = tR_AP*sin(APAngle);
tR_coord = [tR_x_dist + coordA(1) tR_y_dist + coordA(2)];


figure(3)
% imagesc(FullImage); axis image
imshow(ImOverlay); axis image
hold on
plot([coordA(1) coordP(1)], [coordA(2) coordP(2)], '-c','linewidth',1.5)
% plot([ShiftColumn ShiftColumn], [0 FullMeta.SizeY], 'm','linewidth',1.5)
% plot([ShiftColumn + AColumns ShiftColumn + AColumns], [0 FullMeta.SizeY], 'm','linewidth',1.5)
plot([topLeft(1) tL_coord(1)], [topLeft(2) tL_coord(2)], 'y','linewidth',1.5)
plot([topRight(1) tR_coord(1)], [topRight(2) tR_coord(2)], 'y','linewidth',1.5)
plot(topLeft(1), topLeft(2), '.y', 'MarkerSize', 15)
plot(topRight(1), topRight(2), '.y', 'MarkerSize', 15)
plot(tL_coord(1), tL_coord(2), 'xy', 'MarkerSize', 10)
plot(tR_coord(1), tR_coord(2), 'xy', 'MarkerSize', 10)

% title('FullEmbryo: APAxis (red), Acquired XLim (magenta), TopCorners to AP (yellow)')


% assign calculated values to the metadata output. 

figure
imagesc(APMat)


meta.coordA = coordA;
meta.coordP = coordP;
meta.rotMatrix = rotMatrix;
meta.center_rot = center_rot;
meta.center = center;
meta.embryoMask = embryo;
meta.majorAxis_rot = [majorAxisBegin; majorAxisEnd];
meta.minorAxis_rot = [minorAxisBegin; minorAxisEnd];
meta.APLength = APLength;
meta.APAngle = APAngle;
meta.ROI_APMatrix = APMat;
meta.ROI_APRange = [min(APMat(:)) max(APMat(:))];



