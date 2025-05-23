function bw = applySegmentationFunctions(bw, nucmask, parameters)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Pre-processing functions
processFx = parameters.processFx;
processFx = processFx(~cellfun(@isempty, processFx));
for i = 1:length(processFx)
    fx = processFx{i};
    if nargin(fx) == 1
        bw = fx(bw);
    else
        bw = fx(bw, nucmask);
    end
end
% Binarization functions
binarizeFx = parameters.binarizeFx;
binarizeFx = binarizeFx(~cellfun(@isempty, binarizeFx));
for i = 1:length(binarizeFx)
    fx = binarizeFx{i};
    bw = fx(bw);
end
% Filtering functions
filterFx = parameters.filterFx;
filterFx = filterFx(~cellfun(@isempty, filterFx));
for i = 1:length(filterFx)
    fx = filterFx{i};
    if nargin(fx) == 1
        bw = fx(bw);
    else
        bw = fx(bw, mcpmat);
    end
end


end

