function [plotAP, rollAvg, rollSD] = onTimeVsAP_final(summaries,titleString) 

    close all
    
    megasorted = combineFiltMS2(summaries);
    
    % Remove the rows with nan onset times from meanAP, ontimes, and
    % maxms2 vectorson
    [meanAP_ontimes_maxms2] = sortOnTimesByAP(megasorted);
    ontimes = meanAP_ontimes_maxms2(:,2);
    ontimes_nonan = ontimes(~isnan(ontimes));
    APs = meanAP_ontimes_maxms2(:,1);
    meanAP_nonan = APs(~isnan(ontimes));

    start_AP = min(megasorted(:,1))*100;
    if start_AP <15
        start_AP = 15;
    end
    stop_AP = max(megasorted(:,1))*100;
    if stop_AP > 85
        stop_AP = 85;
    end

    framesPerMin = 6;

    f = figure;
    rec = rectangle('position',[start_AP 0 stop_AP-start_AP 18],'FaceColor',[1 1 1],'EdgeColor',[1 1 1]); 
    hold on;

    % determine 95% confidence interval to plot the rolling mean over
    % Histogram of spot positions
    AP_bins = 0.2:0.01:0.8;
    Y = discretize(meanAP_nonan,AP_bins);
    onsets_bool = ontimes_nonan > 0;
    spot_positions = [];
    for i = 1:length(AP_bins)
        spot_positions = [spot_positions; AP_bins(i).*ones(sum(onsets_bool(Y==i)),1)];
    end
    
    borderAP = mean(spot_positions)+1.96*std(spot_positions); % border position to use for future plotting. Use 1.96 for paper!!

    
    p = scatter(meanAP_nonan*100,ontimes_nonan./framesPerMin,5,'k','o','filled'); % plot the point

    % Calculate rolling average and plot
    rollAvg = movmean(ontimes_nonan(meanAP_nonan<=borderAP),100)./framesPerMin;
    rollSD = movstd(ontimes_nonan(meanAP_nonan<=borderAP),100)./framesPerMin;
    plotAP = meanAP_nonan(meanAP_nonan<=borderAP)*100;


    hold on;
    shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) 

    alpha(p,0.06)
    ylabel('Onset Time (min)','fontsize',8)
    xlabel('AP Position (%)','fontsize',8)
    title(titleString,'fontsize',8)
    
    xlim([20 80])
    xticks(20:20:80)
    xticklabels(20:20:80)
    ylim([0 15])
    set(gca,'color',[229.5, 229.5, 229.5]./255); 
    set(gcf,'inverthardcopy','off'); 
    ax = gca;
    set(ax,'layer','top')
    set(gcf,'color','w');
    ax.Box='off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,5,4.5])

    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'data_onsets_all.tif'),'Resolution',300,'BackgroundColor','white')')

end