
%% TWO NUCLEOSOMES --------------------------------------------------------

close all
clearvars

saveDir = '/Users/eleanordegen/Documents/MATLAB/P2_paper_code/';

% Create the parallel pool
parp = gcp('nocreate');
if isempty(parp)
    parpool(4)
end

% Load the normalized GFP-Bcd dynamics (normTrace)
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/bcdGFP_norm.mat') 

% General parameters
params = struct;
params.origOrig = 9.7;              % mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % origins/kb
params.rate = 5.3;                  % rate of DNA polymerase (kb/min)

% Parameter ranges
KORange = 1:30; 
KNRange = 10:200:3000; 
LRange = 100:100:1000;
framesPerMin = 6;
VmaxRange = 1;

mirny = 2; % two nucleosomes
rep = 0; % r = 1 to incorporate a replication delay
seeds = 1:4;

nMats = cell(1,length(seeds));
EC50Mats = cell(1,length(seeds));
fMaxMats = cell(1,length(seeds));

parfor (i = 1:length(seeds),4)
    [nMat, EC50Mat, fMaxMat] = paramSweep_Mirny(KORange, KNRange, LRange, VmaxRange, normTrace, framesPerMin, mirny, seeds(i),rep);
    nMats{i} = nMat;
    EC50Mats{i} = EC50Mat;
    fMaxMats{i} = fMaxMat;
end

newDir = saveDir + string(datetime) + '_twoNucs_Vmax1_noRep_stabilitySweep';
mkdir(newDir)
save(newDir + '/sweepVariables.mat');

%% ONE NUCLEOSOME ---------------------------------------------------------
close all
clearvars

saveDir = '/Users/eleanordegen/Documents/MATLAB/P2_paper_code/';

% Load the normalized GFP-Bcd dynamics (normTrace)
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/bcdGFP_norm.mat') 

% General parameters
params = struct;
params.origOrig = 9.7;              % mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % origins/kb
params.rate = 5.3;                  % rate of DNA polymerase (kb/min)

% Parameter ranges
KORange = 1:30; 
KNRange = 10:200:3000; 
LRange = 100:100:1000;
framesPerMin = 6;
VmaxRange = 1;

mirny = 1; % one nucleosome
rep = 0; % r = 1 to incorporate a replication delay
seeds = 1:4;

nMats = cell(1,length(seeds));
EC50Mats = cell(1,length(seeds));
fMaxMats = cell(1,length(seeds));
parfor (i = 1:length(seeds),4)
    [nMat, EC50Mat, fMaxMat] = paramSweep_Mirny(KORange, KNRange, LRange, VmaxRange, normTrace, framesPerMin, mirny, seeds(i),rep);
    nMats{i} = nMat;
    EC50Mats{i} = EC50Mat;
    fMaxMats{i} = fMaxMat;
end

newDir = saveDir + string(datetime) + '_oneNuc';
mkdir(newDir)
save(newDir + '/sweepVariables.mat');

%% NO NUCLEOSOMES ---------------------------------------------------------
close all
clearvars

saveDir = '/Users/eleanordegen/Documents/MATLAB/P2_paper_code/';

% Create the parallel pool
parp = gcp('nocreate');
if isempty(parp)
    parpool(4)
end

% Load the normalized GFP-Bcd dynamics (normTrace)
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/bcdGFP_norm.mat') 

% General parameters
params = struct;
params.origOrig = 9.7;              % mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % origins/kb
params.rate = 5.3;                  % rate of DNA polymerase (kb/min)

% params
VmaxRange = 0.01:0.01:1;
KmRange = 0:10:140;
framesPerMin = 6;

definition = 'Michaelis Menten'; % Michaelis or linear

mirny = 0; % zero nucleosomes
rep = 0; % 1 for DNA replication delay
seeds = 1:4;

nMats = cell(1,length(seeds));
EC50Mats = cell(1,length(seeds));
fMaxMats = cell(1,length(seeds));
parfor (i = 1:length(seeds),4)
    [nMat, EC50Mat, fMaxMat] = paramSweep_noNucs(normTrace, framesPerMin, mirny, seeds(i), KmRange, VmaxRange, rep);
    nMats{i} = nMat;
    EC50Mats{i} = EC50Mat;
    fMaxMats{i} = fMaxMat;
end

newDir = saveDir + string(datetime) + '_noNucs_MM';
mkdir(newDir)
save(newDir + '/sweepVariables.mat');

%% HILL EQUATION ----------------------------------------------------------

close all
clearvars

saveDir = '/Users/eleanordegen/Documents/MATLAB/P2_paper_code/';

% Create the parallel pool
parp = gcp('nocreate');
if isempty(parp)
    parpool(4)
end

% Load the normalized GFP-Bcd dynamics (normTrace)
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/bcdGFP_norm.mat') 

% General parameters
params = struct;
params.origOrig = 9.7;              % mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % origins/kb
params.rate = 5.3;                  % rate of DNA polymerase (kb/min)

KOorEC50 = 'EC50';

% params
framesPerMin = 6;
KORange = 10:40; % this is actually the EC50 of the fraction of active nuclei (it's raised to the n in the runSSA algorithm)
VmaxRange = 1;
n_HillRange = 1:10;
rep = 0; % include DNA replication delays with rep = 1

seeds = 1:4;

nMats = cell(1,length(seeds));
EC50Mats = cell(1,length(seeds));
fMaxMats = cell(1,length(seeds));
parfor (i = 1:length(seeds),4)
    [nMat, EC50Mat, fMaxMat] = paramSweep_Hill(KORange, VmaxRange, n_HillRange, normTrace, framesPerMin, seeds(i), rep);
    nMats{i} = nMat;
    EC50Mats{i} = EC50Mat;
    fMaxMats{i} = fMaxMat;
end

newDir = saveDir + string(datetime) + '_Hill';
mkdir(newDir)
save(newDir + '/sweepVariables.mat');

%% UNIFORM BICOID ---------------------------------------------------------
close all
clearvars

saveDir = '/Users/eleanordegen/Documents/MATLAB/P2_paper_code/';

% Load the normalized GFP-Bcd dynamics (normTrace)
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/bcdGFP_norm.mat') 

% General parameters
params = struct;
params.origOrig = 9.7;              % mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % origins/kb
params.rate = 5.3;                  % rate of DNA polymerase (kb/min)

% Parameter ranges
KORange = 1:30; 
KNRange = 10:200:3000; 
LRange = 100:100:1000;
framesPerMin = 6;
VmaxRange = 1;

mirny = 2; % two nucleosomes
seeds = 1:4;
rep = 0; % include DNA replication delays with rep = 1

fracMats = cell(1,length(seeds));
parfor (i = 1:length(seeds),4)
    fracMat = paramSweep_uniform(KORange, KNRange, LRange, VmaxRange, normTrace, framesPerMin, mirny, seeds(i),rep);
    fracMats{i} = fracMat;
end

newDir = saveDir + string(datetime) + '_uniform';
mkdir(newDir)
save(newDir + '/sweepVariables.mat');