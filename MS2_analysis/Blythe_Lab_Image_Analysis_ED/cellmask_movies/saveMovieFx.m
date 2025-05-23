function mov = saveMovieFx(savedir, mov)

if ~exist(savedir,'dir')
    mkdir(savedir)
end

N = ndims(mov);

if N == 4
    % assume movie n x m x 3 x t
    sizeT = size(mov,4);
    for t = 1:sizeT
        this_frame = mov(:,:,:,t);
        imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
        imwrite(this_frame, imgname, 'tif');
    end
else
    sizeT = size(mov, 3);
    for t = 1:sizeT
        this_frame = mov(:,:,t);
        imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
        imwrite(this_frame, imgname, 'tif');
    end
end


% X = whos('mov');

% if strcmp(X.class, 'double') 
%     sizeT = size(mov, 3);
%     for t = 1:sizeT
%         this_frame = mov(:,:,t);
%         imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
%         imwrite(this_frame, imgname, 'tif');
%     end
% end

% if strcmp(X.class, 'struct') 
%     sizeT = length(mov);
%     for t = 1:sizeT
%         this_frame = F(t).cdata;
%         imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
%         imwrite(this_frame, imgname, 'tif');
%     end
% end
