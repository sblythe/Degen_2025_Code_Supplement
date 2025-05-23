function [frameTS] = get_seriesTimestamps(data, meta, IncludeLast)
%GET_SERIESTIMESTAMPS Summary of this function goes here
%   Detailed explanation goes here

omeMeta = data{1,4};
nSeries = size(data, 1);
if ~IncludeLast
    nSeries = nSeries - 1;
end

str = omeMeta.getImageAcquisitionDate(0).string();
startTS = datetime(str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss');
for i = 1:nSeries
    s_idx = i -1;
    str = omeMeta.getImageAcquisitionDate(s_idx).string();
    ts = datetime(str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss');
    seriesTS(i) = ts - startTS;
    seriesSizeT(i) = omeMeta.getPixelsSizeT(s_idx).getValue();
end

seriesTSseconds = seconds(seriesTS);
timeInc = meta.timeIncrement;

frameTS = [];
for i = 1:nSeries
    sizeT = seriesSizeT(i);
    ind = 0:timeInc:((sizeT -1) * timeInc);
    frames = ind + seriesTSseconds(i);
    
    frameTS = [frameTS, frames];
end
    