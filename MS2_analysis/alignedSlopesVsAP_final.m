function slopes = alignedSlopesVsAP_final(summary,titleString)

    megasorted = combineFiltMS2(summary);

    % Remove inactive nuclei (no ms2 signal) and the meanAP column (first column)
    ms2mat = megasorted(sum(megasorted(:,2:end)>0,2)>0,2:end);

    % Remove nans 
    ms2mat(isnan(ms2mat)) = 0; 

    alignedMat = zeros(size(ms2mat));
    allstarts = [];
    onsets = [];
    for j = 1:size(ms2mat,1)

        startT = find(ms2mat(j,:),1,'first'); % using >0 so don't find the first "nan"
        onsets = [onsets startT];
        stopT = find(ms2mat(j,:),1,'last');
        lengthMS2 = stopT-startT+1;

        newTrack = zeros(1,size(ms2mat,2)); % this length will be 100 (unless the bin2D function has been changed)
        newTrack(1,1:lengthMS2) = ms2mat(j,startT:stopT);
        alignedMat(j,:) = newTrack;

        allstarts = [allstarts startT]; % keep track of the startT from all movies to determine the delay to add (lowest startT)
    end
    
    timespan = 6; % time interval to find slope over (1 minute)
    AP = megasorted(sum(megasorted(:,2:end)>0,2)>0,1);
    AP_aligned = [AP alignedMat];

    section = alignedMat(:,1:timespan);
    smoothed = movmean(section,5,2); 
    slopes = (smoothed(:,timespan)-smoothed(:,1))/1; % dividing by one minute, the equivalent of timespan = 6

    start_AP = min(megasorted(:,1))*100;
    if start_AP <15
        start_AP=15;
    end
    stop_AP = max(megasorted(:,1))*100;
    if stop_AP>85
        stop_AP=85;
    end
    
    % Bin by AP position
    edges = 0:0.01:1;
    bins = discretize(AP,edges);

    % determine 95% confidence interval to plot the rollingmean over
    % Histogram of spot positions
    AP_bins = 0.2:0.01:0.85;
    Y = discretize(AP,AP_bins);
    slopes_bool = slopes>0;
    spot_positions = [];
    for i = 1:length(AP_bins)
        spot_positions = [spot_positions; AP_bins(i).*ones(sum(slopes_bool(Y==i)),1)];
     
    end
    borderAP = mean(spot_positions,'omitnan')+1.96*std(spot_positions,'omitnan'); 

    f = figure;
    rec = rectangle('position',[start_AP -150 stop_AP-start_AP 600],'FaceColor',[1 1 1],'EdgeColor',[1 1 1]); 
    hold on;
    p = scatter(AP*100,slopes,5,[0 0 0],'o','filled'); % plot the points
    alpha(p,0.06)

    % Calculate rolling average and plot
    slopes_nonan = slopes(~isnan(slopes));
    APs_nonan = AP(~isnan(slopes));

    rollAvg = movmean(slopes_nonan(APs_nonan<=borderAP),100);
    rollSD = movstd(slopes_nonan(APs_nonan<=borderAP),100);
    hold on;
    shadedErrorBar(APs_nonan(APs_nonan<=borderAP)*100,rollAvg,rollSD,[100,149,237]./255,1,0.4) 

    xlim([20 80])
    xticks(20:20:80)
    xticklabels(20:20:80)
    ylim([-150 450]) % in the preprint it's ylim([-100 400])
   
    ylabel('Loading Rate (AU/min)','fontsize',8)
    xlabel('AP Position (%)','fontsize',8)
    title(titleString,'fontsize',8)

    set(gca,'color',[229.5, 229.5, 229.5]./255); 
    set(gcf,'inverthardcopy','off'); 
    ax = gca;
    set(ax,'layer','top')
    set(gcf,'color','w');
    ax.Box = 'off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    ax.YAxis.Exponent = 2;
    set(f,'units','centimeters','position',[50,25,5,4.5])

    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'data_slopes_all.png'),'Resolution',300,'BackgroundColor','white')

end