# Track Nuclei
## Intro

Tracks nuclei using knnsearch algorithm. Nuclei are tracked based on max projected images (x,y,t). Includes functions for visualizing tracks and calculating nuclear intensity. Currently only tracks nuclei between mitotic divisions. Created in conjuction with Blythe Lab Image Analysis projects. 

MATLAB_R2018b

## Demo

Open 'track\_demo.m' file. Change the file path for 'sample\_data.mat' to match your systems file structure. Run `track_demo` in MATLAB command line. 

(Add images showing expected demo output)

## Basic Use
### Create reference matrix for nuclear tracks 

Required input variables  

- `nucmax`: 3D nuclear mask (x,y,t)


Functions supported by this project rely on a tracking reference guide, stored as the variable *trackmat*. Rows of *trackmat* index individual tracks, while columns index time. Element of *trackmat* represents the indexed position of from a connected components object list.*

(insert image of trackmat)  

*Object list returned bwconnomp( ) on any given frame. Objects in the list are ordered by top - left priority. 2D and 3D object lists do not always align.  

```matlab
trackmat = trackNuclei(nucmax);

% return the track index (row index) of the 7th nucleus at frame 10
t = 10;
myNuc = 7;
trackIdx =  find(trackmat(:, myNuc) == t);

% display an image of myNuc at frame 2
t = 2;
cc = bwconncomp(nucmax(:,:,t));
img = zeros(size(nucmax, 1), size(nucmax, 2));
objIdx = trackmat(myNuc, t);
img(cc.PixelIdxList{objIdx}) = 1;

figure; 
imshow(img);
```

### Filter tracks by duration and object size
Required input variables  

- `nucmax`: 3D nuclear mask (x,y,t)
- `trackmat`

Returns row idx of tracks that meet given parameters.
  
```matlab
% create label matrix based on tracking index (y,x,t)
trLabel = labelTrack(trackmat, nucmax);

% filter
minObjSize = 0;
maxObjSize = 400;
minTrackLife = 100;

validTrackIdx = filterTrack(trackmat, labeltrack, minObjSize, maxObjSize, minTrackLife);

trackmat = trackmat(validTrackIdx, :);
trLabel = labelTrack(trackmat, nucmax);

```

### Play movie with labelled tracks
Required input variables  

- `trLabel`: 3D (x,y,t) tracking label matrix (see above example)

```matlab
% create a movie that colors nuclei by their track
shuffle_cmap = 0;
mov = track2rgb(trLabel, shuffle_cmap);
implay(mov);

```

### Calculate intensity
Required input variables  

- `trLabel`: 3D (x,y,t) tracking label matrix (see above example)
- `nucmask`: 4D nuclear mask
- `intmat` : 4D image matrix used to calculate intensity 

```matlab
trLabel4D = labelTrack4D(trLabel, nucmask);
validTracks = 1:size(trackmat,1)
trackInt = getObjTrackIntensity(trLabel4D, intmat, validTracks)

figure;
imagesc(trackInt)
figure;
plot(trackInt', 'Color', '[0, 0, 1, 0.3])
```


## Function Guide
### Main Functions
**trackNuclei** (getTrackRef) - returns tracking reference matrix (see examples in Basic Use section)  
**filterTrack** - (see Basic Use)  
**getObjTrackIntensity**
**labelTrack** - builds 3D label matrix (x,y,t) s.t. each nucleus in a nuclear mask is labelled with its tracking reference row number   
**track2rgb** - tracking movie

### Supporting Functions
**elFreq** - returns frequency of each element in an array (similar to table() in R)  
**getRowIdx**  
**labelTrack4D**  - required for getObjTrackIntensity()

## Projects

List of projects that use Track Nuclei:

