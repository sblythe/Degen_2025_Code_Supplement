function megasorted = combineFiltMS2(summaries)

    % Combine the matrices
    megams2 = [];
    for i = 1:length(summaries)
        filt = filterTracks_v4(summaries{i}); % NOTE filt has the AP position tags in the first column
        megams2 = [megams2;filt];
     end

    % Sort rows by the average AP position of the nuclei
    megasorted = sortrows(megams2,1,'ascend'); % this matrix contains the mean AP positions in the first column
end