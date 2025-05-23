% assumes last series imported seperately (overview image)

function output = load_movie(filename, parameters)


output = struct;

output.analysisdate = datetime;

parp = gcp('nocreate');
if isempty(parp)
    parpool(4)
end

% import movie

% use stitcherV2 for loading overviewMetadata and stictcherV3 for skipping series
[allI,allmeta] = parameters.importFunction(filename, ...
    parameters.importSkip, parameters.importIncludeLast);

data = allI(1); 

if parameters.importIncludeLast == 0
    output.meta = allmeta{1};
    output.overmeta = allmeta{2};
    
    overview = allI{2};  
    overIsplit = parameters.channelSplitFunction(overview, output.overmeta); %
else
    output.meta=allmeta;
end

Isplit = parameters.channelSplitFunction(data{1,1}, output.meta); % changed data{1,1} to data
nChan = length(Isplit);

if nChan == 2
    ch1_I = Isplit{1};
    output.channel1mat = parameters.imageArrayingFunction(ch1_I, output.meta);

    ch2_I = Isplit{2};
    output.channel2mat = parameters.imageArrayingFunction(ch2_I, output.meta);
    
    if parameters.importIncludeLast == 0
        overI = overIsplit{1};  % used to be {1}. Change to 2 if accidentally collected the ms2 channel of overview
        overmat = parameters.imageArrayingFunction(overI, output.overmeta);  %

        output.lastmax = max(cat(3, output.channel2mat(:,:,:,end-1)), [], 3);  %

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

    if parameters.importIncludeLast == 0
        overI = overIsplit{1};  %
        overmat = parameters.imageArrayingFunction(overI, output.overmeta);  %

        output.lastmax = max(cat(3, output.channel3mat(:,:,:,output.meta.SizeT)), [], 3);  %

        output.overmax = max(cat(3, overmat), [], 3);  %
    end

end

