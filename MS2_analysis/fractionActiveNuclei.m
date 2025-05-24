function fractions_bins_nucs=fractionActiveNuclei(ms2mat,binWidth)

% Find the fraction of active nuclei in bins along the AP axis
% The first column of ms2mat holds the mean AP position of the nucleus in
% each row
% binWidth specifies the fraction of the AP axis that each bin covers

% Could also re-write this function using the discretize function.

    ms2mat(isnan(ms2mat)) = 0;
    APBins = 0:binWidth:1;
    fractions_bins_nucs=zeros(length(APBins)-1,3);
    for i = 2:length(APBins)
        ofinterest = ms2mat(ms2mat(:,1)<APBins(i) & ms2mat(:,1)>=APBins(i-1),2:end);
        if ~isempty(ofinterest)
            fractionActive = length(find(sum(ofinterest>0,2)))/size(ofinterest,1);
            fractions_bins_nucs(i-1,:) = [fractionActive APBins(i-1) size(ofinterest,1)];
        else
            fractions_bins_nucs(i-1,:) = [nan APBins(i-1) 0]; % if there are no nuclei in the range, set the fraction to nan
        end
    end
    

end