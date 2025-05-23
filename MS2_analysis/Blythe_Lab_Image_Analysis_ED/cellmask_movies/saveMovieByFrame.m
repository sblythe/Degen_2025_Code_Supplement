
   
% datafile = '/Users/izze/Documents/Projects/Blythe_Lab/parB/presentation_slides/sample movies/190326_1_g1max/';
savedir = '/Users/isabella/Documents/MATLAB/projects/opa_protein_conc/plots/ap_pos/190927_eve';
% movie_folder = 'histone_movie';
% savefile = [savedir];

if ~exist(savedir,'dir')
    mkdir(savedir)
end

mov = F;
X = whos('mov');

if strcmp(X.class, 'double') 
    sizeT = size(mov, 3);
    for t = 1:sizeT
        this_frame = mov(:,:,t);
        imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
        imwrite(this_frame, imgname, 'tif');
    end
end

if strcmp(X.class, 'struct') 
    sizeT = length(mov);
    for t = 1:sizeT
        this_frame = F(t).cdata;
        imgname = [savedir, filesep, 'frame', num2str(t), '.tif'];
        imwrite(this_frame, imgname, 'tif');
    end
end


