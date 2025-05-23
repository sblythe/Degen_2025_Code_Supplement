function movie = MCP_segmentation_check(meta, MCP_DOG, nucdata, rawMCP)

for t = 1 : meta.SizeT
     nucmax(:,:,t) = max(cat(3, nucdata(:,:,:,t)), [], 3);
     MCP_mask_max(:,:,t) = max(cat(3, MCP_DOG(:,:,:,t)), [], 3);
     MCP_EC_max(:,:,t) = max(cat(3, rawMCP(:,:,:,t)), [], 3);
end

for t = 1 : meta.SizeT
    over = imoverlay(imadjust(MCP_EC_max(:,:,t)), bwmorph(nucmax(:,:,t),'remove'), [1 0 0]);
    over2 = imoverlay(over, MCP_mask_max(:,:,t), [0 1 0]);
    movie(:,:,:,t) = over2;
end
