function varargout = importUI(varargin)
% IMPORTUI MATLAB code for importUI.fig

% Edit the above text to modify the response to help importUI

% Last Modified by GUIDE v2.5 29-Oct-2020 17:06:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importUI_OpeningFcn, ...
                   'gui_OutputFcn',  @importUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    OPEN/CLOSE/OUTPUT     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function importUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for importUI
handles.parameters = struct;

% Initialize Parameters
handles.parameters.nuclearCycle = {'Nuclear Cycle 12'; ...
    'Nuclear Cycle 13'; 'Nuclear Cycle 14'};
handles.parameters.nuclearCycleStart = [NaN; NaN; NaN];
handles.parameters.channelName = {''};
handles.parameters.importIncludeLast = 1;
handles.parameters.flipCheck = 0;
handles.parameters.trackNuclei = 0;

% Option to give file as input
if ~isempty(varargin)
    handles.parameters.filename = varargin{1};
    [path, basename] = fileparts(varargin{1});
    
    set(handles.textFilePath, 'String', varargin{1})
    
    savedir = strcat(path, filesep, basename, '_analysis');
    handles.parameters.saveDir = savedir;

    set(handles.editSaveDir, 'String', path);
end

% Option to load settings from previous parameter file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(varargin) > 1
    handles.lastParam = varargin{2};
    set(handles.checkboxUseLast, 'Value', 1)
    handles.useLast = 1;
else
    handles.lastParam = [];
    handles.useLast = 0;
end

% Update handles structure
guidata(hObject, handles);

checkboxUseLast_Callback(handles.checkboxUseLast, eventdata, handles);

% UIWAIT - set to resume on window close
uiwait(handles.figure1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function figure1_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure1);
% object deleted in OutputFcn


function varargout = importUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.parameters;
varargout{2} = handles.useLast;

% close figure window
delete(hObject);









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%      IMPORT FEATURES     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SAVE DIRECTORY
function editSaveDir_Callback(hObject, eventdata, handles)
str = str2double(get(hObject, 'String'));
handles.parameters.saveDirectory = str;
guidata(hObject, handles);

% GENOTYPE
function editGenotype_Callback(hObject, eventdata, handles)
str = str2double(get(hObject, 'String'));
handles.parameters.genotype = str;
guidata(hObject, handles);

% ORIENTATION
function editOrientation_Callback(hObject, eventdata, handles)
str = str2double(get(hObject, 'String'));
handles.parameters.orientation = str;
guidata(hObject, handles);

% ADDITIONAL COMMENTS
function editAdditional_Callback(hObject, eventdata, handles)
str = str2double(get(hObject, 'String'));
handles.parameters.notes = str;
guidata(hObject, handles);

% EDIT SKIP
function editSkip_Callback(hObject, eventdata, handles)
handles.parameters.importSkip = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% OVERVIEW IMAGE
function checkboxOverview_Callback(hObject, eventdata, handles)
handles.parameters.importIncludeLast = ~get(hObject, 'Value');
guidata(hObject, handles);

% FLIP CHECK
function checkboxFlipCheck_Callback(hObject, eventdata, handles)
handles.parameters.flipCheck = get(hObject, 'Value');
guidata(hObject, handles);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%            TIME          %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NUCLEAR CYCLE LISTBOX
function listboxNC_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns listboxNC 
%   contents as cell array
% contents{get(hObject,'Value')} returns selected item from listboxNC
idx = get(hObject, 'Value');

name = handles.parameters.nuclearCycle{idx};
set(handles.editFeature, 'String', name);

start = num2str(handles.parameters.nuclearCycleStart(idx));
set(handles.editStartFrame, 'String', start);

guidata(hObject, handles);


% START FRAME
function editStartFrame_Callback(hObject, eventdata, handles)
num = str2double(get(hObject, 'String'));
idx = get(handles.listboxNC, 'Value');
handles.parameters.nuclearCycleStart(idx) = num;
guidata(hObject, handles);


% FEATURE NAME
function editFeature_Callback(hObject, eventdata, handles)
name = get(hObject, 'String');
idx = get(handles.listboxNC, 'Value');
handles.parameters.nuclearCycle{idx} = name;
% update listbox
list = handles.parameters.nuclearCycle; 
set(handles.listboxNC, 'String', list);

guidata(hObject, handles);


% ADD FEATURE
function pushbuttonAddFeature_Callback(hObject, eventdata, handles)
idx = get(handles.listboxNC, 'Value');
names = handles.parameters.nuclearCycle;
starts = handles.parameters.nuclearCycleStart;

% add new space to feature names
temp = cell(length(names) + 1, 1);
temp(1:idx) = names(1:idx);
temp{idx+1} = 'New Time Feature';
temp(idx+2:end) = names(idx+1:end);
names = temp;

% add new space to feature starts
temp = NaN(length(starts) + 1, 1);
temp(1:idx) = starts(1:idx);
temp(idx+2:end) = starts(idx+1:end);
starts = temp;

handles.parameters.nuclearCycle = names;
handles.parameters.nuclearCycleStart = starts;

set(handles.listboxNC, 'String', names);
set(handles.listboxNC, 'Value', idx+1);

guidata(hObject, handles);

listboxNC_Callback(handles.listboxNC, eventdata, handles);


% REMOVE FEATURE
function pushbuttonRmvFeature_Callback(hObject, eventdata, handles)
idx = get(handles.listboxNC, 'Value');
names = handles.parameters.nuclearCycle;
starts = handles.parameters.nuclearCycleStart;
list = cellstr(get(handles.listboxNC, 'String'));

names(idx) = [];
starts(idx) = [];
list(idx) = [];

if idx > length(starts)
    idx = idx - 1;
end
set(handles.listboxNC, 'Value', idx);

set(handles.listboxNC, 'String', list);
handles.parameters.nuclearCycle = names;
handles.parameters.nuclearCycleStart = starts;

guidata(hObject, handles);

listboxNC_Callback(handles.listboxNC, eventdata, handles);



















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%          CHANNELS        %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CHANNEL LISTBOX
function listboxChannels_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns listboxChannels 
%   contents as cell array
% contents{get(hObject,'Value')} returns selected item from listboxChannels
idx = get(hObject, 'Value');

str = handles.parameters.channelName{idx};
set(handles.editChannelName, 'String', str);

guidata(hObject, handles);


% NUMBER OF CHANNELS
function editNumChan_Callback(hObject, eventdata, handles)
nChan = str2double(get(hObject, 'String'));
list = {};
for i = 1:nChan
    list{i} = ['Channel', num2str(i)];
end

set(handles.listboxChannels, 'String', list);

handles.parameters.channelName = list;

guidata(hObject, handles);


% CHANNEL NAME
function editChannelName_Callback(hObject, eventdata, handles)
str = get(hObject, 'String');
idx = get(handles.listboxChannels, 'Value');
handles.parameters.channelName{idx} = str;

list = cellstr(get(handles.listboxChannels, 'String'));
list{idx} = str;
set(handles.listboxChannels, 'String', list);

guidata(hObject, handles);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LASER POWER
function editLaserPower_Callback(hObject, eventdata, handles)


% CHANNEL TYPE
function popupmenuChannelType_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns 
%   popupmenuChannelType contents as cell array
% contents{get(hObject,'Value')} returns selected item from 
%   popupmenuChannelType


% SEGMENTATION PARAMETERS
function popupmenuChannelSeg_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns 
%   popupmenuChannelSeg contents as cell array
% contents{get(hObject,'Value')} returns selected item from 
%   popupmenuChannelSeg




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%         SKIP/NEXT        %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SKIP
function pushbuttonSkip_Callback(hObject, eventdata, handles)
handles.parameters = [];
guidata(hObject, handles);

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


% NEXT
function pushbuttonDone_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USE LAST
function checkboxUseLast_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUseLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxUseLast
if get(hObject, 'Value')
    handles.useLast = 1;
    param = handles.lastParam;
    
    set(handles.editHistoneChannel, 'String', param.histoneChannel);
    set(handles.editSkip, 'String', param.importSkip);
    set(handles.checkboxOverview, 'Value', ~param.importIncludeLast);
    set(handles.checkboxFlipCheck, 'Value', param.flipCheck);
    set(handles.checkboxTrack, 'Value', param.trackNuclei);
    set(handles.listboxChannels, 'String', param.channelName);
    set(handles.editNumChan, 'String', length(param.channelName));
    set(handles.listboxNC, 'String', param.nuclearCycle);
    
    handles.parameters.histoneChannel = param.histoneChannel;
    handles.parameters.importSkip = param.importSkip;
    handles.parameters.importIncludeLast = param.importIncludeLast;
    handles.parameters.flipCheck = param.flipCheck;
    handles.parameters.trackNuclei = param.trackNuclei;
    handles.parameters.channelName = param.channelName;
    handles.parameters.nuclearCycle = param.nuclearCycle;
    handles.parameters.nuclearCycleStart = NaN(size(param.nuclearCycle));
else
    handles.useLast = 0;
end

guidata(hObject, handles);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




