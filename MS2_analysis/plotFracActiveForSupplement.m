function AP_meanFrac_SD = plotFracActiveForSupplement(summaries,titleString)

    binWidth = 0.025;
    AP_meanFrac_SD = fracActiveInBins(summaries, binWidth);

    megasorted = combineFiltMS2(summaries);
    
    start_AP = min(megasorted(:,1))*100;
    if start_AP <15
        start_AP=15;
    end
    stop_AP = max(megasorted(:,1))*100;
    if stop_AP>85
        stop_AP=85;
    end

    f = figure;
    shadedErrorBar(AP_meanFrac_SD(:,1).*100,AP_meanFrac_SD(:,2),AP_meanFrac_SD(:,3),[0 0.8 0.8],1,0.2) % corn flower blue: 100,149,237
    ylabel('Fraction','fontsize',8)
    xlabel('AP Position (%)','fontsize',8)
    title(titleString,'fontsize',8)
    xlim([20 80])
    xticks(20:10:80)
    xticklabels(20:10:80)
    ylim([0 1.1])
    ax = gca;
    ax.Box = 'off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,5,4.5])
  

    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'meanFracAcrossMovs.tif'),'Resolution',300,'BackgroundColor','white')

    function AP_meanFrac_SD = fracActiveInBins(summaries, binWidth)
    
        APs = 0:binWidth:1;
    
        allFractions = [];
        for i = 1:length(summaries)
            
            filt = filterTracks_v4(summaries{i}); % AP positions in first column
            sorted = sortrows(filt,1,'ascend');
            bins = discretize(sorted(:,1),APs);
    
            fractions = nan(length(APs),1);
            for j = 1:length(APs)
                if sum(bins==j)>0
                    frac = length(find(sum(sorted(bins==j,2:end)>0,2)))/sum(bins==j);
                    fractions(j) = frac;
                else
                    fractions(j) = nan;
                end
            end
    
            allFractions = [allFractions fractions];
        
        end
    
        AP_meanFrac_SD = [APs' mean(allFractions,2,'omitnan') std(allFractions,0,2,'omitnan')];

    end

end