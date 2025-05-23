# Blythe Lab Image Analysis

## Intro
The files in this repository provide the basic structure for working on standard embryo imaging projects in lab. Analysis relies primarily on MATLAB files. This guide was created with new coders in mind, and is intended to support readers with a wide range of coding experience. 

In this repository you will find functions for [file import](#import), [AP axis finding](#apFind), [nuclear segmentation](#nucSeg), [spot segmentation](#spotSeg), and [nuclear tracking](#track).

## Set-up

MATLAB can be found on (all?) lab computers. Northwestern provides MATLAB free for current students. Click [here](https://www.it.northwestern.edu/software/matlab/obtain.html) to get MATLAB on your computer. 

This guide covers git simple commands for making changes to the repository. If you are new to git, now would be a good time to familiarize yourself with the basics of command line coding and [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your computer.

To download this repository using git, access the command line for your computer (Terminal for mac users) and navigate to the folder you wish to work in. Enter the command `git clone path/to/repository`. The path to the repository can be found my going to this repository online, pressing the green *Code* button, and copying the given URL. 


## Demo

Retrieve *Imaging/Analysis\_Demo/DEMO\_190911\_ParB\_mcpBFP\_gt10ms2\_2.lif* from Blythe Lab server. This file contains a movie of an embryo between NC12 and early NC14. It has 3 channels. Running code for this demo will load and segment the histone and gt-10 ms2 channels. An overview tilescan is also provided for running AP-axis finding functions.  

To run demo, open the *build\_demo\_parameters.m* file in MATLAB and set parameters.filename and parameters.saveDirectory to the filepaths on your computer. Enter the following code in the MATLAB command line.  

```matlab  
build_demo_parameters.m;
output = parametrized_analysis(parameters, 0);

```

## Suggested Use

If you plan to use this repository solely as a foundation for processing your imaging projects, there are only two files you will need to change - *build\_analysis\_parameters.m* and *parametrized\_analysis.m* . In *build\_analysis\_parameters.m* you will find the code to build a parameters struct that will act as the main source for guiding analysis. This includes variables that define filepaths, function handles, function inputs, ect. The *parametrized\_analysis.m* function takes the parameters you set and applies them to functions used in your analysis.  
The version of these files online act as a guide for creating your own scripts specific to your imaging project. Add or delete sections as you see fit. **Do not save these changes to the lab repository.** Create a copy outside of *Blythe\_Lab\_Image\_Analysis.m* to store files for your own purposes.  

For those inclined towards adding and improving on the the analysis code, follow these steps to appropiately make changes to the repository. 

1. Before making any changes to code, navigate to the repository in your command line and enter `git pull`. This makes sure the files on your computer are up to date with those online. 
2. Create a branch for your changes `git checkout -b your_branch_name` or go to a previously created branch `git checkout your_branch_name`.
3. Add changed files to the staging area `git add filename`.
	* Use `git status` to see which files have been modified and which files have been properly staged.
	* `git add -A` will add all modified files to the staging area.
4. Commit changes `git commit -m"your commit message"`
	* The commit message should be a description of the changes you are making.
5. Update your branch on the remote repository `git push origin your_branch_name`
6. Merge changes with the master branch and "push" to remote repository    

	```
	git checkout master  
	git merge your_branch_name --no-ff
	git push origin master
	```

**Do not merge to the master branch until you are sure the changes you are making will not disrupt workflow of other users.** (Usage guide soon to be updated with commands for forking & pull requests to improve this process).


## Capabilities

### Import <a name="import"></a>
### AP-axis Finding <a name="apFind"></a>
### Nuclear Segmentation <a name="nucSeg"></a>
### Spot Segmentation <a name="spotSeg"></a>
### Nuclear Tracking <a name="track"></a>

## In-progress Updates
* Channel matrices will be stored in a cell array {xyzt}<sub>c</sub> . This eliminates the need for named channel variables that are specific to individual imaging projects. Channels can be processed in a loop and are easily indexed by number instead of variable name.
* allChannels struct array stores output. Fields: rawImage, channelName, mask, segFxList
* segFxList is a cell of function handles specific to segmentation steps for each channel, includes parameters for each fx 






