function [meanAP_ontimes_maxms2] = sortOnTimesByAP(taggedsortedms2)

    % Sort "on times" by AP position (taggedsortedms2 is a filtered matrix
    % with mean AP positions in the first column)
    
    % Onset times are reported in number of frames. 
    
    sortedms2 = taggedsortedms2(:,2:end);
    sortedms2(isnan(sortedms2)) = 0;
    on_point = zeros(size(sortedms2,1),1);
    allmaxes = [];
    AP = [];
    for j  =1:size(sortedms2,1)
        nonzero = find(sortedms2(j,:),1,'first');
        maxms2 = max(sortedms2(j,:),[],'omitnan');
        if nonzero > 0
            on_point(j) = nonzero;
            allmaxes = [allmaxes;maxms2];
        else
            on_point(j)=nan;
            allmaxes = [allmaxes;nan]; % set max as nan if there is no ms2 in that row
        end

        AP = [AP;taggedsortedms2(j,1)];
    end

    meanAP_ontimes_maxms2 = [AP on_point allmaxes];
    
end
