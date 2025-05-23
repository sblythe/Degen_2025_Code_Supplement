function [data] = import_stack(filepath)
% this function uses the bioformats package to import .lif files enclosed in the given file
% see https://www.openmicroscopy.org/site/support/bio-formats5.1/developers/matlab-dev.html

data = bfopen(filepath);

end
