function [AP_avg_SD APs ontimes] = onsetVsAP_sampled_final(summaries,titleString) 

    close all

    % Plot the onsets with even coverage across AP. 
    framesPerMin = 6; 

    megasorted = combineFiltMS2(summaries);

    start_AP = min(megasorted(:,1))*100;
    if start_AP < 15
        start_AP = 15;
    end
    stop_AP = max(megasorted(:,1))*100;
    if stop_AP > 85
        stop_AP = 85;
    end


    rng(3) % Random seed for the paper

    % Bin megasorted
    bins = discretize(megasorted(:,1),0:0.01:1);

    sampledMega = [];
    counts = [];
    avgAPs = [];
    for i = 1:max(bins)
        possibilities = find(bins==i);
        if length(possibilities) >= 20 

            % Generate random indices
            indices = randperm(length(possibilities),20); 
            chosen = possibilities(indices);
            sampledMega = [sampledMega; megasorted(chosen,:)];
        else
            sampledMega = [sampledMega; megasorted(possibilities,:)];
        end

        counts = [counts; sum(bins==i)];
        avgAPs = [avgAPs; nanmean(megasorted(bins==i,1))];

    end

    % Order by AP position
    sampledMega = sortrows(sampledMega,1,'ascend');

    % Find onset times and remove nans
    [meanAP_ontimes_maxms2] = sortOnTimesByAP(sampledMega);
    ontimes = meanAP_ontimes_maxms2(:,2);
    APs = meanAP_ontimes_maxms2(:,1);
    ontimes_nonan = ontimes(~isnan(ontimes));
    meanAP_nonan = meanAP_ontimes_maxms2(~isnan(ontimes),1);

    on_AP_nonan = [ontimes_nonan meanAP_nonan];

    % determine 95% or 98% confidence interval to plot the rollingmean over
    % Histogram of spot positions
    AP_bins = 0.2:0.01:0.8;
    Y = discretize(meanAP_nonan,AP_bins);
    onsets_bool = ontimes_nonan>0;
    spot_positions = [];
    for i = 1:length(AP_bins)
        spot_positions = [spot_positions; AP_bins(i).*ones(sum(onsets_bool(Y==i)),1)];
    end
    
    borderAP = mean(spot_positions)+1.96*std(spot_positions); % border position to use for future plotting. Use 1.96 for paper!!
  
    f=figure;
    rec=rectangle('position',[start_AP 0 stop_AP-start_AP 18],'FaceColor',[1 1 1],'EdgeColor',[1 1 1]); 
    hold on;

    p=scatter(APs*100,ontimes./framesPerMin,5,'k','o','filled'); % plot the point
    alpha(p,0.1)
    hold on;

    rollAvg = movmean(ontimes_nonan(meanAP_nonan<=borderAP),50,'omitnan')./framesPerMin;
    rollSD = movstd(ontimes_nonan(meanAP_nonan<=borderAP),50,'omitnan')./framesPerMin;
    plotAP = meanAP_nonan(meanAP_nonan<=borderAP)*100;
    AP_avg_SD = [plotAP rollAvg rollSD];

    hold on;
    shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) 
    alpha(p,0.1)
    ylabel('Onset Time (min)','fontsize',8)
    xlabel('AP Position (%)','fontsize',8)
    title(titleString,'fontsize',8)
    
    xlim([20 80])
    xticks(20:10:80)
    xticklabels(20:10:80)
    ylim([0 15])
    set(gca,'color',[229.5, 229.5, 229.5]./255); 
    set(gcf,'inverthardcopy','off'); 
    ax=gca;
    set(ax,'layer','top')
    set(gcf,'color','w');
    ax.Box='off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,5,4.5])

    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'sampledOnsets.tif'),'Resolution',300,'BackgroundColor','white')

end