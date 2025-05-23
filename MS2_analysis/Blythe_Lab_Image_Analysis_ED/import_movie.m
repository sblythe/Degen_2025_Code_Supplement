% assumes last series imported seperately (overview image)

function output = import_movie(parameters)


output = struct;

output.analysisdate = datetime;

parp = gcp('nocreate');
if isempty(parp)
    parpool(2)
end

% import movie

[allI,allmeta] = parameters.importFunction(parameters.filename, ...
    parameters.importSkip, parameters.importIncludeLast);

data = allI(1); 

if parameters.importIncludeLast == 0
    output.meta = allmeta{1};
    output.overmeta = allmeta{2};
    
    Isplit = parameters.channelSplitFunction(data{1,1}, output.meta);
    
    overview = allI{2};  %
    overIsplit = parameters.channelSplitFunction(overview, output.overmeta); %
else
    output.meta = allmeta;
    
    Isplit = parameters.channelSplitFunction(data{1,1}, output.meta);
end

nChan = length(Isplit);

if nChan == 1
    ch1_I = Isplit{1};
    output.channel1mat = parameters.imageArrayingFunction(ch1_I, output.meta);
    
    output.allChannels = output.channel1mat;
end

if nChan == 2
    ch1_I = Isplit{1};
    output.channel1mat = parameters.imageArrayingFunction(ch1_I, output.meta);

    ch2_I = Isplit{2};
    output.channel2mat = parameters.imageArrayingFunction(ch2_I, output.meta);
    
    output.allChannels = cat(5, output.channel1mat, output.channel2mat);
        
    if parameters.importIncludeLast == 0
        overI = overIsplit{1};  %
        overmat = parameters.imageArrayingFunction(overI, output.overmeta);  %
        
        ch = parameters.overviewChannel;
        output.lastmax = max(cat(3, output.allChannels(:,:,:,end,ch)), [], 3);  %

        output.overmax = max(cat(3, overmat), [], 3);  %
    end
end

if nChan == 3
    ch1_I = Isplit{1};
    output.channel1mat = parameters.imageArrayingFunction(ch1_I, output.meta);

    ch2_I = Isplit{2};
    output.channel2mat = parameters.imageArrayingFunction(ch2_I, output.meta);

    ch3_I = Isplit{3};
    output.channel3mat = parameters.imageArrayingFunction(ch3_I, output.meta);
    
    output.allChannels = cat(5, output.channel1mat, output.channel2mat, output.channel3mat);
    
    if parameters.importIncludeLast == 0
        overI = overIsplit{1};  %
        overmat = parameters.imageArrayingFunction(overI, output.overmeta);  %

        ch = parameters.overviewChannel;
        output.lastmax = max(cat(3, output.allChannels(:,:,:,end,ch)), [], 3);  %
        
        output.overmax = max(cat(3, overmat), [], 3);  %
    end
end


