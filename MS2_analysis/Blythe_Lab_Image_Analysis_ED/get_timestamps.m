function seriesTs = get_timestamps(filename, series)
% get OME timestamp data using BioFormats Library

ID = series - 1; % series (img) index

reader = bfGetReader(filename);
omeMeta = reader.getMetadataStore();

s = omeMeta.getPixelsTimeIncrement(ID);

OMEData.Dimension_Order = char(omeMeta.getPixelsDimensionOrder(ID));
c = omeMeta.getPixelsSizeC(ID).getValue();
t = omeMeta.getPixelsSizeT(ID).getValue();
z = omeMeta.getPixelsSizeZ(ID).getValue();

% create time series index - plane id for each time point
% sets idx on channel 1 -> assumes each channel is captured simultaneously 
planeID = zeros(1, t);
planeInc = z * c;  

% set plane id halfway through stack
startPlane = floor((z - 1) * c / 2);  

% set plane id at end of stack
startPlane = (z - 1) * c;

% set plane id at start of stack
startPlane = 0;

planeID = startPlane:planeInc:((c*z*t) -1);
seriesTs = [];
for p = planeID
    deltaT = omeMeta.getPlaneDeltaT(ID, p).value().doubleValue();
    seriesTs(end+1) = deltaT;
end

