function bw = binarize4D(varargin)
%BINARIZE4D takes a 4D matrix and calls imbinarize while looping through T
%   Detailed explanation goes here

img4D = varargin{1};
method = varargin{2};  % 'global', 'adaptive' or numeric threshold 
if strcmp(method, 'adaptive')
    name_val = varargin{3};
    val = varargin{4};
end

bw = zeros(size(img4D));
for t = 1:size(img4D, 4)
    if strcmp(method, 'adaptive')
        bw(:,:,:,t) = imbinarize(img4D(:,:,:,t), method, name_val, val);
    else
        bw(:,:,:,t) = imbinarize(img4D(:,:,:,t), method);
    end
end

end

