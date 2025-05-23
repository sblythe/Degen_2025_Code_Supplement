% stitcher is a function that takes as input the first-pass import from
% bioformats and stitches multiple series together on the assumption that
% they are all from a single dataset. This assumes that the final stack in
% each stitched dataset is all black and discards them. Note that this is
% currently designed to work on XYZT datasets with one or more channels.
%
% Inputs are:
%
% Filename = the filename of the input dataset.
%
% Skip = default 0, alternatively, any series numbers given here will not
% be included in the stitch. (e.g., [1 2] will omit the first and second
% series in the dataset). At the moment, this function assumes that you
% will skip only initial datasets, not internal ones (e.g., only the second). 
%
% IncludeLast = (optional, default = 0) whether to keep the last series 
% as a separate series.
%
% Exception is that the last series is
% assumed to be separate (e.g., a full embryo overview). This can be
% bypassed by specifying IncludeLast = 1. 

function [stitched, smeta] = stitcherV2(varargin)

filename = varargin{1};

Data = import_stack(filename);
NSeries = size(Data,1);

if length(varargin) == 1 || varargin{2} == 0 || isempty(varargin{2})
    display('No series will be omitted'); pause(1)
    firstset = 1;
    Meta = get_metadataSpecial(filename, 1);
    imageset = firstset : NSeries;
else if varargin{2} ~= 0
        skipper = varargin{2};
        if skipper < 0
            skipper = NSeries;
        end
        display('The specified series will be skipped'); display(skipper);pause(1)
        valid_series = setdiff(1:NSeries, skipper);
        Data = Data(valid_series,:);
        Meta = get_metadataSpecial(filename,1);
        firstset = valid_series(1);
        imageset = valid_series;
    end
end
if length(varargin) == 2 || varargin{3} == 0 || isempty(varargin{3})
    display('Last series will be kept separate'); pause(1)
    IncludeLast = 0;
    imageset = imageset(1:end-1);
else IncludeLast = 1; display('Last series will be stitched in'); pause(1)
end

% we need to determine if the last frame in each stack is black or not. 
blacktest = [];
for i = imageset
    I = Data{imageset(i),1};
    I = I{end,1};
    blacktest(i) = all(all(I == 0));
end

if all(blacktest)
    omit = Meta.SizeC * Meta.SizeZ; % This specifies that the last frame in each stack will be omitted.
    disp('timeseries data appears to end with black frames');
    tadj = 1;
else
    omit = 0; disp('timeseries data does not appear to end with black frames');
    tadj = 0;
end
stitched = {};

% NSeries = size(Data,1);
if IncludeLast
    for i = 1 : size(Data,1)
        s = Data{i,1};
        s = s(1 : size(s,1)-omit,:);
        stitched = [stitched; s];
    end
    output{1} = stitched;
    
    T = [];
    Z = [];
    
    for i = imageset
        m = get_metadataSpecial(filename,i);
        T = [T m.SizeT-tadj];
        Z = [Z m.SizeZ];
    end
    
    if ~all(Z == Meta.SizeZ)
        display('Not all Z-stacks are the same length. Aborting')
        return
    end
    
    stitchedmeta = Meta;
    stitchedmeta.SizeT = sum(T);
    stitchedmeta.SeriesCount = 'stitched';
    stitchedmeta.SeriesIndex = 'NA';
    
    smeta = stitchedmeta;
    smeta = get_bonus_metadata(Data,smeta);
    
    smeta.timestamps = get_seriesTimestamps(Data, smeta, IncludeLast);

end

if ~IncludeLast
    for i = 1 : size(Data,1)-1;
       s = Data{i,1};
       s = s(1 : size(s,1)-omit,:);
       stitched = [stitched; s];
    end
    output{1} = stitched;
    output = [output; Data(size(Data,1),1)];
%    
%     timestamps = [];
%     
%     for i = imageset;
%         ts = get_timestamps(filename,i);
%         starttime = ts.DateTime(find('T' == ts.DateTime)+1:end);
%         starttime = datenum(starttime,'HH:MM:SS');
%         frametimes = starttime + ts.TimePerZStack/(24*60*60);
%         timestamps = [timestamps frametimes];
%     end
%     
    T = [];
    Z = [];
    
    for i = imageset
        m = get_metadataSpecial(filename,i);
        T = [T m.SizeT-tadj];
        Z = [Z m.SizeZ];
    end
    
    if ~all(Z == Meta.SizeZ)
        display('Not all Z-stacks are the same length. Aborting')
        return
    end
    
    stitchedmeta = Meta;
    stitchedmeta.SizeT = sum(T);
    stitchedmeta.SeriesCount = 'stitched';
    stitchedmeta.SeriesIndex = 'NA';
%     stitchedmeta.Timestamps = timestamps;
%     stitchedmeta.TimeIntervals = [0 cumsum(diff(timestamps)*24*60*60)];
    
    lastmeta = get_metadataSpecial(filename, NSeries);
    
    meta = stitchedmeta;
    
    smeta{1} = stitchedmeta;
    smeta{2} = lastmeta;
    smeta{1} = get_bonus_metadata(Data,smeta{1});
%     TS = get_seriesTimestamps(Data, smeta{1}, IncludeLast); % commented
%     2/3/24
%     smeta{1}.timestamps = TS;
        
    
end


stitched = output;


function OMEData = get_metadataSpecial(filename, series)
% get OME Metadata Information using BioFormats Library. The old version
% was deprecated. 
ID = series - 1;

reader = bfGetReader(filename);
omeMeta = reader.getMetadataStore();
[pathstr,name,ext] = fileparts(filename);

OMEData.FilePath = pathstr;
OMEData.Filename = strcat(name, ext);
OMEData.Dimension_Order = char(omeMeta.getPixelsDimensionOrder(ID));

% Number of series inside the complete data set
OMEData.SeriesCount = reader.getSeriesCount();

OMEData.SizeC = omeMeta.getPixelsSizeC(ID).getValue();
OMEData.SizeT = omeMeta.getPixelsSizeT(ID).getValue();
OMEData.SizeZ = omeMeta.getPixelsSizeZ(ID).getValue();
OMEData.SizeX = omeMeta.getPixelsSizeX(ID).getValue();
OMEData.SizeY = omeMeta.getPixelsSizeY(ID).getValue();
OMEData.microns_per_pixel_X = omeMeta.getPixelsPhysicalSizeX(ID).value();
OMEData.microns_per_pixel_X = OMEData.microns_per_pixel_X.doubleValue();
OMEData.microns_per_pixel_Y = omeMeta.getPixelsPhysicalSizeY(ID).value();
OMEData.microns_per_pixel_Y = OMEData.microns_per_pixel_Y.doubleValue();
if OMEData.SizeZ > 1
    OMEData.microns_per_step_Z = omeMeta.getPixelsPhysicalSizeZ(ID).value();
    OMEData.microns_per_step_Z = OMEData.microns_per_step_Z.doubleValue();
end
% OMEData.timeIncrement = double(omeMeta.getPixelsTimeIncrement(ID)); % comment out normally
