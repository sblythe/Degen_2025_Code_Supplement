function varargout = segmentationParamFinder(varargin)
% SEGMENTATIONPARAMFINDER MATLAB code for segmentationParamFinder.fig
%      SEGMENTATIONPARAMFINDER, by itself, creates a new SEGMENTATIONPARAMFINDER or raises the existing
%      singleton*.
%
%      H = SEGMENTATIONPARAMFINDER returns the handle to a new SEGMENTATIONPARAMFINDER or the handle to
%      the existing singleton*.
%
%      SEGMENTATIONPARAMFINDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATIONPARAMFINDER.M with the given input arguments.
%
%      SEGMENTATIONPARAMFINDER('Property','Value',...) creates a new SEGMENTATIONPARAMFINDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segmentationParamFinder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segmentationParamFinder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentationParamFinder

% Last Modified by GUIDE v2.5 01-Oct-2020 18:59:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentationParamFinder_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentationParamFinder_OutputFcn, ...
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


% --- Executes just before segmentationParamFinder is made visible.
function segmentationParamFinder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmentationParamFinder (see VARARGIN)

% Initialize starting variables
handles.rawMov = varargin{1};

if ~isempty(varargin{2})
    handles.nucmask = varargin{2};
else
    handles.nucmask = ones(size(handles.movie));
end 

% Set up time slider
handles.currentT = 1;
handles.sizeT = size(handles.rawMov, 4);
handles.strT = sprintf('%d / %d', handles.currentT, handles.sizeT);
set(handles.sliderT, 'Min', 1);
set(handles.sliderT, 'Max', handles.sizeT);
set(handles.textZ, 'String', handles.strT);
tRange = handles.sizeT - 1;
set(handles.sliderT, 'SliderStep', [1/tRange, 5/tRange]);

% Set up z-stack slider
handles.currentZ = 1;
handles.sizeZ = size(handles.rawMov, 3);
handles.strZ = sprintf('%d / %d', handles.currentZ, handles.sizeZ);
set(handles.sliderZ, 'Min', -handles.sizeZ);
set(handles.sliderZ, 'Max', -1);
set(handles.textZ, 'String', handles.strZ);
zRange = handles.sizeZ - 1;
set(handles.sliderZ, 'SliderStep', [1/zRange, 5/zRange]);

% Variables for viewing options
handles.raw = handles.rawMov(:,:,:,handles.currentT);
handles.rawMax = squeeze(max(handles.raw, [], 3));
handles.mask = zeros(size(handles.raw));
handles.maskMax = zeros(size(handles.rawMax));
handles.maskMov = zeros(size(handles.rawMov));
handles.overlay = handles.raw;
handles.overlayMax = handles.rawMax;
handles.rgb = 0;
handles.projected = 0;

handles.image = handles.raw;
handles.imageMax = handles.rawMax;

% Turn on toolbar for axes
set(hObject, 'toolbar', 'figure');

% Display start image
imshow(handles.image(:,:,1), 'Parent', handles.axes1);

% initialize parameters and function handle lists
handles.parameters = struct;
handles.processFx = {};
handles.binarizeFx = {};
handles.filterFx = {};

hObject.WindowStyle = 'Modal';


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmentationParamFinder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segmentationParamFinder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = hObject;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);
% uiresume(handles.figure1);
% Hint: delete(hObject) closes the figure
delete(hObject); 





% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create param list
param = handles.parameters;

obj_handles = findall(handles.figure1.Children, 'Style', 'edit');

for i = 1:length(obj_handles)
    if strcmp(get(obj_handles(i), 'Enable'), 'on')
        fieldname = get(obj_handles(i), 'UserData');
        param.(fieldname) = str2double(get(obj_handles(i), 'String'));
    end
end

param.processFx = handles.processFx;
param.binarizeFx = handles.binarizeFx;
param.filterFx = handles.filterFx;
handles.parameters = param;

disp('Current parameters saved in workspace as ''param'' ');
assignin('base', 'param', handles.parameters);

guidata(hObject, handles);

uiresume(handles.figure1);
delete(handles.figure1);




% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stopRun = 0;
obj_handles = findall(handles.figure1.Children, 'Style', 'edit');
bkgC = [1, 0.67, 0.67];
for i = 1:length(obj_handles)
    if strcmp(get(obj_handles(i), 'Enable'), 'on')
        if isempty(get(obj_handles(i), 'String'))
            set(obj_handles(i), 'BackgroundColor', bkgC)
            stopRun = 1;  
        end
    end
end
if stopRun
    return
end

set(handles.textRunTime, 'String', 'Running...');

bw = im2double(handles.raw);
param = handles.parameters;

timerVal = tic;

% Pre-processing functions
processFx = handles.processFx;
processFx = processFx(~cellfun(@isempty, processFx));
for i = 1:length(processFx)
    fx = processFx{i};
    if nargin(fx) == 1
        bw = fx(bw);
    else
        mask = handles.nucmask(:,:,:,handles.currentT);
        bw = fx(bw,mask);
    end
end
% Binarization functions
binarizeFx = handles.binarizeFx;
binarizeFx = binarizeFx(~cellfun(@isempty, binarizeFx));
for i = 1:length(binarizeFx)
    fx = binarizeFx{i};
    bw = fx(bw);
end
% Filtering functions
filterFx = handles.filterFx;
filterFx = filterFx(~cellfun(@isempty, filterFx));
for i = 1:length(filterFx)
    fx = filterFx{i};
    if nargin(fx) == 1
        bw = fx(bw);
    else
        img = handles.rawMov(:,:,:,handles.currentT);
        bw = fx(bw, img);
    end
end

% timer
segTime = toc(timerVal);
segTime = round(segTime, 2);
segTime100 = round((segTime * 100 / 60), 1);
timeStr = sprintf('Estimated run time %0.2f s / frame, %0.2f min / 100 frames', ...
    segTime, segTime100);

% update mask
handles.mask = bw;
handles.maskMax = squeeze(max(bw, [], 3));
handles.maskMov(:,:,:,handles.currentT) = bw;

% create overlay
set(handles.textRunTime, 'String', 'Creating overlay...');
img = handles.raw;
for z = 1:handles.sizeZ
    bwCirc = imdilate(bw(:,:,z), strel('disk', 3));
    bwCirc = bwmorph(bwCirc, 'remove');
    frame = imoverlay(img(:,:,z), bwCirc, [0,1,0]);
    over(:,:,:,z) = frame;
end
imgMax = handles.rawMax;
bwMax = handles.maskMax;
bwMax = imdilate(bwMax, strel('disk', 3));
circMax = bwmorph(bwMax, 'remove');
overMax = imoverlay(imgMax, circMax, [0,1,0]);

handles.overlay = over;
handles.overlayMax = overMax;

set(handles.textRunTime, 'String', timeStr);

% update image
switch get(handles.uibuttongroup1.SelectedObject, 'Tag')
    case 'togglebuttonRaw'
        handles.image = handles.raw;
        handles.imageMax = handles.rawMax;
        handles.rgb = 0;
    case 'togglebuttonMask'
        handles.image = handles.mask;
        handles.imageMax = handles.maskMax;
        handles.rgb = 0;
    case 'togglebuttonOver'
        handles.image = handles.overlay;
        handles.imageMax = handles.overlayMax;
        handles.rgb = 1;
end
if handles.projected
    imshow(handles.imageMax, 'Parent', handles.axes1);
else
    if handles.rgb
        imshow(handles.image(:,:,:,handles.currentZ), 'Parent', handles.axes1);
    else
        imshow(handles.image(:,:,handles.currentZ), 'Parent', handles.axes1);
    end
end

% done!
guidata(hObject, handles);






% --- Executes on slider movement.
function sliderT_Callback(hObject, eventdata, handles)
% hObject    handle to sliderT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

t = round(get(hObject, 'Value'));
handles.currentT = t;
set(hObject, 'Value', t);
handles.strT = sprintf('%d / %d', handles.currentT, handles.sizeT);
set(handles.textT, 'String', handles.strT);

handles.raw = handles.rawMov(:,:,:,t);
handles.rawMax = squeeze(max(handles.raw, [], 3));
handles.mask = handles.maskMov(:,:,:,t);
handles.maskMax = squeeze(max(handles.mask, [], 3));
handles.overlay = zeros(size(handles.raw, 1), size(handles.raw, 2), 3, size(handles.raw, 3));
handles.overlayMax = zeros(size(handles.raw, 1), size(handles.raw, 2), 3);
handles.rgb = 0;

handles.image = handles.raw;
handles.imageMax = handles.rawMax;

set(handles.togglebuttonRaw, 'Value', 1); % does this call buttongroup selection change?

if handles.projected
    imshow(handles.imageMax, 'Parent', handles.axes1);
else
    imshow(handles.image(:,:,handles.currentZ), 'Parent', handles.axes1);
end


guidata(hObject, handles);

togglebuttonScale_Callback(handles.togglebuttonScale, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function sliderT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

set(hObject, 'Min', 1);
set(hObject, 'Max', 80);
set(hObject, 'SliderStep', [1/29, 5/29]);
set(hObject, 'Value', 1);



% --- Executes on slider movement.
function sliderZ_Callback(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% slider min == 1 and max == -SizeZ so slider starts at top and moves down
z = abs(round(get(hObject, 'Value')));
handles.currentZ = z;
set(hObject, 'Value', -z);
handles.strZ = sprintf('%d / %d', handles.currentZ, handles.sizeZ);
set(handles.textZ, 'String', handles.strZ);
if ~handles.projected
    if handles.rgb
        imshow(handles.image(:,:,:,z), 'Parent', handles.axes1);
    else
        imshow(handles.image(:,:,z), 'Parent', handles.axes1);
    end
end

guidata(hObject, handles);

togglebuttonScale_Callback(handles.togglebuttonScale, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function sliderZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

set(hObject, 'Min', -30);
set(hObject, 'Max', -1);
set(hObject, 'SliderStep', [1/29, 5/29]);
set(hObject, 'Value', -1);


% --- Executes on button press in togglebuttonMax.
function togglebuttonMax_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonMax
handles.projected = get(hObject, 'Value');

if handles.projected 
    set(hObject, 'BackgroundColor', [0.8, 0.8, 0.8])
    imshow(handles.imageMax, 'Parent', handles.axes1);
else 
    set(hObject, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'))
    z = handles.currentZ;
    imshow(handles.image(:,:,z), 'Parent', handles.axes1);
end

guidata(hObject, handles);

togglebuttonScale_Callback(handles.togglebuttonScale, eventdata, handles);



% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue, 'Tag')
    case 'togglebuttonRaw'
        handles.image = handles.raw;
        handles.imageMax = handles.rawMax;
        handles.rgb = 0;
    case 'togglebuttonMask'
        handles.image = handles.mask;
        handles.imageMax = handles.maskMax;
        handles.rgb = 0;
    case 'togglebuttonOver'
        handles.image = handles.overlay;
        handles.imageMax = handles.overlayMax;
        handles.rgb = 1;
end

if handles.projected
    imshow(handles.imageMax, 'Parent', handles.axes1);
else
    if handles.rgb
        imshow(handles.image(:,:,:,handles.currentZ), 'Parent', handles.axes1);
    else
        imshow(handles.image(:,:,handles.currentZ), 'Parent', handles.axes1);
    end
end

guidata(hObject, handles);

togglebuttonScale_Callback(handles.togglebuttonScale, eventdata, handles);



% --- Executes on button press in togglebuttonScale.
function togglebuttonScale_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonScale

I = handles.axes1.Children.CData;

if get(hObject, 'Value')
    if max(I(:)) > min(I(:))
        set(handles.axes1, 'CLim', [min(I(:)), max(I(:))]);
    end
else
    if isa(I, 'uint8')
        set(handles.axes1, 'Clim', [0, 255]);
    elseif isa(I, 'double')
        set(handles.axes1, 'Clim', [0, 1]);
    end
end

guidata(hObject, handles);
    







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkboxSize.
function checkboxSize_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

edit_handles = [handles.editSizeMin, handles.editSizeMax, ...
    handles.editPlane, handles.editExcl];

if get(hObject, 'Value')
    for i = 1:length(edit_handles)
        set(edit_handles(i), 'enable', 'on')
        val(i) = str2double(get(edit_handles(i), 'String'));
    end
    str = sprintf('@(bw)objSizeFilt(bw, %.1f, %.1f, %d, %d)', val(1), val(2), val(3), val(4));
    size = str2func(str);
else
    for i = 1:length(edit_handles)
        set(edit_handles(i), 'BackgroundColor', [0.94, 0.94, 0.94]);
        set(edit_handles(i), 'enable', 'off')
    end
    size = [];
end

handles.filterFx{1} = size;

guidata(hObject, handles);

% --- Executes on button press in checkboxIntTtl.
function checkboxIntTtl_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIntTtl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editIntTtl, 'enable', 'on');
    set(handles.popupmenuIntType, 'enable', 'on');
    minInt = str2double(get(handles.editIntTtl, 'String'));
    contents = cellstr(get(handles.popupmenuIntType, 'String'));
    type = contents{get(handles.popupmenuIntType, 'Value')};
    str = sprintf('@(bw,img)objIntensityFilt(bw,img, %.3f, ''%s'')', minInt, type);
    intTtl = str2func(str);
else
    set(handles.editIntTtl, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editIntTtl, 'enable', 'off');
    set(handles.popupmenuIntType, 'enable', 'off');
    intTtl = [];
end

handles.filterFx{2} = intTtl;

guidata(hObject, handles);


% --- Executes on button press in checkboxUser3.
function checkboxUser3_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUser3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editUser3, 'enable', 'on');
    str = get(handles.editUser3, 'String');
    if ~isempty(str)
        userFx = str2func(str);
    else
        userFx = [];
    end
else
    set(handles.editUser3, 'enable', 'off');
    userFx = [];
end

filterFx{3} = userFx;

guidata(hObject, handles);


function editSizeMin_Callback(hObject, eventdata, handles)
% hObject    handle to editSizeMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editSizeMin, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxSize_Callback(handles.checkboxSize, eventdata, handles);

function editSizeMax_Callback(hObject, eventdata, handles)
% hObject    handle to editSizeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editSizeMax, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxSize_Callback(handles.checkboxSize, eventdata, handles);

function editPlane_Callback(hObject, eventdata, handles)
% hObject    handle to editPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editPlane, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxSize_Callback(handles.checkboxSize, eventdata, handles);

function editExcl_Callback(hObject, eventdata, handles)
% hObject    handle to editExcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editExcl, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxSize_Callback(handles.checkboxSize, eventdata, handles);

function editIntTtl_Callback(hObject, eventdata, handles)
% hObject    handle to editIntTtl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editIntTtl, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxIntTtl_Callback(handles.checkboxIntTtl, eventdata, handles);

% --- Executes on selection change in popupmenuIntType.
function popupmenuIntType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuIntType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checkboxIntTtl_Callback(handles.checkboxIntTtl, eventdata, handles);

function editUser3_Callback(hObject, eventdata, handles)
% hObject    handle to editUser3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editUser3, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxUser3_Callback(handles.checkboxUser3, eventdata, handles);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BINARIZE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bwSwitch(hObject, eventdata, handles)

obj_handles = findall(handles.uipanel2.Children, 'Style', 'checkbox');
obj_handles(obj_handles == hObject) = [];
for i = 1:length(obj_handles)
    set(obj_handles(i), 'Value', 0);
    obj_handles(i).Callback(obj_handles(i), eventdata);
end


% --- Executes on button press in checkboxBwG.
function checkboxBwG_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBwG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    bwSwitch(hObject, eventdata, handles);
    handles.binarizeFx = {};
    binG = @(bw) binarize4D(bw, 'global');
else
    binG = [];
end

handles.binarizeFx{1} = binG;

guidata(hObject, handles);

% --- Executes on button press in checkboxBwA.
function checkboxBwA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBwA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    bwSwitch(hObject, eventdata, handles);
    handles.binarizeFx = {};
    set(handles.editBwA, 'enable', 'on');
    sens = str2double(get(handles.editBwA, 'String'));
    str = sprintf('@(bw)binarize4D(bw, ''adaptive'', ''Sensitivity'', %.2f', sens);
    binA = str2func(str);
else
    set(handles.editBwA, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editBwA, 'enable', 'off');
    binA = [];
end

handles.binarizeFx{2} = binA;

guidata(hObject, handles);

% --- Executes on button press in checkboxBwU.
function checkboxBwU_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBwU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    bwSwitch(hObject, eventdata, handles);
    handles.binarizeFx = {};
    set(handles.editBwU, 'enable', 'on');
    thresh = str2double(get(handles.editBwU, 'String'));
    A = handles.image; 
    if isa(A, 'uint8')
        thresh = thresh / 255;
    end
    str = sprintf('@(bw)binarize4D(bw, %d)', thresh);
    binU = str2func(str);
else
    set(handles.editBwU, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editBwU, 'enable', 'off');
    binU = [];
end

handles.binarizeFx{3} = binU;

guidata(hObject, handles);

% --- Executes on button press in checkboxUser2.
function checkboxUser2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUser2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    bwSwitch(hObject, eventdata, handles);
    handles.binarizeFx = {};
    set(handles.editUser2, 'enable', 'on');
    str = get(handles.editUser2, 'String');
    if ~isempty(str)
        userFx = str2func(str);
    else
        userFx = [];
    end
else
    set(handles.editUser2, 'enable', 'off');
    userFx = [];
end

binarizeFx{4} = userFx;

guidata(hObject, handles);

function editBwA_Callback(hObject, eventdata, handles)
% hObject    handle to editBwA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editBwA, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxBwA_Callback(handles.checkboxBwA, eventdata, handles);

function editBwU_Callback(hObject, eventdata, handles)
% hObject    handle to editBwU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editBwU, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxBwU_Callback(handles.checkboxBwU, eventdata, handles);

function editUser2_Callback(hObject, eventdata, handles)
% hObject    handle to editUser2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editUser2, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxUser2_Callback(handles.checkboxUser3, eventdata, handles);








%%%%%%%%%%%%%%%%%%%%%%%%%%% PRE-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkboxCE.
function checkboxCE_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editCE, 'enable', 'on');
    ceRad = str2double(get(handles.editCE, 'String'));
    str = sprintf('@(bw)parContrastEnhance(bw, %.1f)', ceRad);
    ce = str2func(str);
else
    set(handles.editCE, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editCE, 'enable', 'off');
    ce = [];
end

handles.processFx{1} = ce;

guidata(hObject, handles);


% --- Executes on button press in checkboxDoG.
function checkboxDoG_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDoG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editDoG1, 'enable', 'on');
    set(handles.editDoG2, 'enable', 'on');
    sig1 = str2double(get(handles.editDoG1, 'String'));
    sig2 = str2double(get(handles.editDoG2, 'String'));
    str = sprintf('@(bw)parDoG4D(bw, %.2f, %.2f)', sig1, sig2);
    dog = str2func(str);
else
    set(handles.editDoG1, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editDoG2, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editDoG1, 'enable', 'off');
    set(handles.editDoG2, 'enable', 'off');
    dog = [];
end

handles.processFx{2} = dog;

guidata(hObject, handles);


% --- Executes on button press in checkboxNuc.
function checkboxNuc_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNuc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editNuc, 'enable', 'on');
    dilRad = str2double(get(handles.editNuc, 'String'));
    str = sprintf('@(bw, mask)nucmaskFilt(bw, mask, %d)', dilRad);
    nuc = str2func(str);
else
    set(handles.editNuc, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editNuc, 'enable', 'off');
    nuc = [];
end

handles.processFx{3} = nuc;

guidata(hObject, handles);


% --- Executes on button press in checkboxPoiss.
function checkboxPoiss_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPoiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editPoiss, 'enable', 'on')
    pval = str2double(get(handles.editPoiss, 'String'));
    str = sprintf('@(bw)poissNoiseFilt(bw, %.3f)', pval);
    poiss = str2func(str);
else
    set(handles.editPoiss, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editPoiss, 'enable', 'off')
    poiss = [];
end

handles.processFx{4} = poiss;

guidata(hObject, handles);

% --- Executes on button press in checkboxUser1.
function checkboxUser1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUser1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editUser1, 'enable', 'on');
    str = get(handles.editUser1, 'String');
    if ~isempty(str)
        userFx = str2func(str);
    else
        userFx = [];
    end
else
    set(handles.editUser1, 'enable', 'off');
    userFx = [];
end

processFx{5} = userFx;

guidata(hObject, handles);

function editDoG1_Callback(hObject, eventdata, handles)
% hObject    handle to editDoG1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editDoG1, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxDoG_Callback(handles.checkboxDoG, eventdata, handles);

function editDoG2_Callback(hObject, eventdata, handles)
% hObject    handle to editDoG2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editDoG2, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxDoG_Callback(handles.checkboxDoG, eventdata, handles);

function editNuc_Callback(hObject, eventdata, handles)
% hObject    handle to editNuc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editNuc, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxNuc_Callback(handles.checkboxNuc, eventdata, handles);

function editPoiss_Callback(hObject, eventdata, handles)
% hObject    handle to editPoiss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editPoiss, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxPoiss_Callback(handles.checkboxPoiss, eventdata, handles);

function editCE_Callback(hObject, eventdata, handles)
% hObject    handle to editCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editCE, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxCE_Callback(handles.checkboxCE, eventdata, handles);

function editUser1_Callback(hObject, eventdata, handles)
% hObject    handle to editUser1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editUser1, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxUser3_Callback(handles.checkboxUser1, eventdata, handles);













% --- Executes on button press in pushbuttonROI.
function pushbuttonROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'myRoi')
    delete(handles.myRoi);
end

handles.myRoi = drawline(handles.axes1);

roiCallback = @(hObject,eventdata)segmentationParamFinder('updateRoiPlot', hObject, eventdata,guidata(hObject));
handles.el = addlistener(handles.myRoi, 'ROIMoved', roiCallback);

myMask = createMask(handles.myRoi);
if handles.projected
    img = handles.imageMax;
else 
    img = handles.image(:,:,handles.currentZ);
end
pixels = img(myMask);
plot(handles.axes2, pixels);

guidata(hObject, handles);

uiwait(handles.figure1);


function updateRoiPlot(hObject, eventdata, handles)

myMask = createMask(handles.myRoi);
if handles.projected
    img = handles.imageMax;
else 
    img = handles.image(:,:,handles.currentZ);
end
pixels = img(myMask);
plot(handles.axes2, pixels);

guidata(hObject, handles);
