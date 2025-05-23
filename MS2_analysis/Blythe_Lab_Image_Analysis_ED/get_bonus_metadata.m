function [meta] = get_bonus_metadata(data,meta)

rawmeta = data{1,2};

obj = rawmeta.get('Image|ATLConfocalSettingDefinition|ObjectiveName');
pinhole = rawmeta.get('Image|ATLConfocalSettingDefinition|PinholeAiry');
frameacc = rawmeta.get('Image|ATLConfocalSettingDefinition|FrameAccumulation');
frameavg = rawmeta.get('Image|ATLConfocalSettingDefinition|FrameAverage');
lineacc = rawmeta.get('Image|ATLConfocalSettingDefinition|Line_Accumulation');
lineavg = rawmeta.get('Image|ATLConfocalSettingDefinition|LineAverage');
scanspeed = rawmeta.get('Image|ATLConfocalSettingDefinition|ScanSpeed');
NA = rawmeta.get('Image|ATLConfocalSettingDefinition|NumericalAperture');
mag = rawmeta.get('Image|ATLConfocalSettingDefinition|Magnification');
zoom = rawmeta.get('Image|ATLConfocalSettingDefinition|Zoom');
scandir = rawmeta.get('Image|ATLConfocalSettingDefinition|ScanDirectionXName');
imm = rawmeta.get('Image|ATLConfocalSettingDefinition|Immersion');
rotation = rawmeta.get('Image|ATLConfocalSettingDefinition|RotatorAngle');
timeinc = rawmeta.get('Image|ATLConfocalSettingDefinition|CycleTime');

meta.Objective = obj;
meta.Pinhole = str2double(pinhole);
meta.FrameAccumulation = str2double(frameacc);
meta.FrameAveraging = str2double(frameavg);
meta.LineAccumulation = str2double(lineacc);
meta.LineAveraging = str2double(lineavg);
meta.ScanSpeed = str2double(scanspeed);
meta.Magnification = mag;
meta.NumericAperture = NA;
meta.Zoom = str2double(zoom);
meta.ScanDirection = scandir;
meta.Immersion = imm;
meta.RotationAngle = str2double(rotation);
meta.timeIncrement = str2double(timeinc);