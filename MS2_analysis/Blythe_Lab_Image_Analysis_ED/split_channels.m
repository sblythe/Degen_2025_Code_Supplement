function chansplit = split_channels(I, meta)

NChan = meta.SizeC;
ZFrames = meta.SizeZ;

chansplit = cell(NChan,1);

%I = cat(1,I{:,1});
dimorder = meta.Dimension_Order;

if strcmp(dimorder, 'XYCZT')
    for i = 1 : NChan
        chansplit{i,1} = I(i : NChan : size(I,1),1);
    end
end
    
if strcmp(dimorder, 'XYZCT')
    frameI = 1 : size(I,1);
    frameI = reshape(frameI, ZFrames, length(frameI)/ZFrames);
    for i = 1 : NChan
        chanI = reshape(frameI(:,i:NChan:size(frameI,2)),1,[]);
        chansplit{i,1} = I(chanI,1);
    end
end

if strcmp(dimorder, 'XYZTC')
    for i = 1 : NChan
        chansplit{i,1} = I(i : NChan : size(I,1),1);
    end
end
