function [freq, uniq] = elFreq(X)
% ELFREQ Returns frequency of elements in given array

X = X(~isnan(X));
uniq = unique(X);
freq = [];

for i = 1:length(uniq)
    freq(i) = sum(X == uniq(i));
end

end

