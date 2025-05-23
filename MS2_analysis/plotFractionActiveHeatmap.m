function plotFractionActiveHeatmap(summaries_all,titleString)

    % Heatmap of fraction active per movie
    binWidth = 0.025;
    allfractions = zeros(length(summaries_all),1/binWidth);
    APRanges = [];
    for i = 1:length(summaries_all)
        filt = filterTracks_v4(summaries_all{i}); % NOTE filt has the AP position tags in the first column
        scaled = bin2D(filt(:,2:end)); % scales matrices by finding the averages in 100 bins
        scaled_tagged = [filt(:,1) scaled];
        fracs_bins_nucs = fractionActiveNuclei(scaled_tagged,binWidth);
        fracs = fracs_bins_nucs(:,1);

        ant_AP = min(filt(:,1));
        post_AP = max(filt(:,1));

        xs = 0:binWidth:1;
        ant_bin = discretize(ant_AP,xs);
        post_bin = discretize(post_AP,xs);    

        fracs(1:(ant_bin-1)) = nan;
        fracs((post_bin+1):end) = nan;

        allfractions(i,:) = fracs';
        APRanges=[APRanges; ant_bin post_bin];
    end
    
    allfractions(allfractions==0) = 0.01;
    allfractions(isnan(allfractions)) = 0;

    tagged = sortrows([APRanges(:,1) allfractions],1,'ascend');
    toplot = tagged(:,2:end);

    % create the colormap. Go from white to cyan.
    lowColor = [0 0 0];
    cyan = [2, 231, 247]./256;
    cmap = [[245, 245, 245]./255; linspace(lowColor(1), cyan(1),256)', linspace(lowColor(2),cyan(2),256)', linspace(lowColor(3),cyan(3),256)'];

    f = figure; 
    imagesc(toplot)
    colormap(cmap)
    caxis([0 max(allfractions(:))]);
    c=colorbar;
    c.Ticks = 0:0.25:1;
    c.FontSize = 7;
    c.Title.String = 'Fraction';
    xlim([8 32])
    xticks(8:4:32)
    xticklabels(20:10:80)
    yticks(0:3:18)
    yticklabels(0:3:18)
    xlabel('AP Position (%)','fontsize',8)
    ylabel('Embryo','fontsize',8)
    title(titleString,'fontsize',8)


    ax = gca;
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,6.5,4.5])
    
    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'fractionActiveHeatmap.tif'),'Resolution',300,'BackgroundColor','white')


end

