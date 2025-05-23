function [scaledms2] = bin2D(continms2)

% Bin the movie into 100 frames (this scaling will work with movies that
% are >16.6min with 10 sec frame time)

% continms2 SHOULD NOT have AP position tags in the first column

    % Bin frames
    bins = discretize(1:size(continms2,2),1:size(continms2,2)/101:size(continms2,2));
    
    % Average columns in the same bin
    for i = 1:max(bins)
        scaledms2(:,i) = mean(continms2(:,bins==i),2,'omitnan');
    end

end

