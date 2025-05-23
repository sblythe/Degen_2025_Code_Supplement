function varargout = nucSegParamFinder(varargin)
% NUCSEGPARAMFINDER MATLAB code for nucSegParamFinder.fig
%      NUCSEGPARAMFINDER, by itself, creates a new NUCSEGPARAMFINDER or raises the existing
%      singleton*.
%
%      H = NUCSEGPARAMFINDER returns the handle to a new NUCSEGPARAMFINDER or the handle to
%      the existing singleton*.
%
%      NUCSEGPARAMFINDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUCSEGPARAMFINDER.M with the given input arguments.
%
%      NUCSEGPARAMFINDER('Property','Value',...) creates a new NUCSEGPARAMFINDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nucSegParamFinder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nucSegParamFinder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nucSegParamFinder

% Last Modified by GUIDE v2.5 20-Oct-2020 15:55:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nucSegParamFinder_OpeningFcn, ...
                   'gui_OutputFcn',  @nucSegParamFinder_OutputFcn, ...
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


% --- Executes just before nucSegParamFinder is made visible.
function nucSegParamFinder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nucSegParamFinder (see VARARGIN)

% Initialize starting variables
handles.rawMov = varargin{1};

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
handles.parameters.sigma1 = 1;
handles.parameters.sigma2 = NaN;
handles.parameters.bwMethod = NaN;
handles.parameters.openSphereRad = NaN;
handles.parameters.lowerVolCutoffRad = NaN;
handles.parameters.minPlane = NaN;
handles.parameters.hMin = NaN;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nucSegParamFinder wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nucSegParamFinder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% guidata(hObject, handles)

% Get default command line output from handles structure
varargout{1} = handles.parameters;

delete(hObject); 


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);








% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Assigning current parameters to workspace variable ''param''')
assignin('base', 'param', handles.parameters);

guidata(hObject, handles);




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

% SEGMENT
bw = nucSegPro(bw, param);

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
    bwCirc = bwmorph(bw(:,:,z), 'remove');
    frame = imoverlay(img(:,:,z), bwCirc, [1,0,0]);
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

% --- Executes on button press in checkboxOpen.
function checkboxOpen_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editOpen, 'enable', 'on')
    handles.parameters.openSphereRad = str2double(get(handles.editOpen, 'String'));
else
    set(handles.editOpen, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editOpen, 'enable', 'off')
    handles.parameters.openSphereRad = NaN;
end

guidata(hObject, handles);

% --- Executes on button press in checkboxMinSize.
function checkboxMinSize_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editMinSize, 'enable', 'on')
    handles.parameters.lowerVolCutoffRad = str2double(get(handles.editMinSize, 'String'));
else
    set(handles.editMinSize, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editMinSize, 'enable', 'off')
    handles.parameters.lowerVolCutoffRad = NaN;
end

guidata(hObject, handles);

% --- Executes on button press in checkboxPlane.
function checkboxPlane_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editPlane, 'enable', 'on')
    handles.parameters.minPlane = str2double(get(handles.editPlane, 'String'));
else
    set(handles.editPlane, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editPlane, 'enable', 'off')
    handles.parameters.minPlane = NaN;
end

guidata(hObject, handles);

% --- Executes on button press in checkboxWS.
function checkboxWS_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editWS, 'enable', 'on')
    handles.parameters.hMin = str2double(get(handles.editWS, 'String'));
else
    set(handles.editWS, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editWS, 'enable', 'off')
    handles.parameters.hMin = NaN;
end

guidata(hObject, handles);




function editOpen_Callback(hObject, eventdata, handles)
% hObject    handle to editOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editOpen, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxOpen_Callback(handles.checkboxOpen, eventdata, handles);

function editMinSize_Callback(hObject, eventdata, handles)
% hObject    handle to editMinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editMinSize, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxMinSize_Callback(handles.checkboxMinSize, eventdata, handles);

function editPlane_Callback(hObject, eventdata, handles)
% hObject    handle to editPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editPlane, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxPlane_Callback(handles.checkboxPlane, eventdata, handles);

function editWS_Callback(hObject, eventdata, handles)
% hObject    handle to editWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(hObject, 'String'))
    set(handles.editWS, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxWS_Callback(handles.checkboxWS, eventdata, handles);




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
    handles.parameters.bwMethod = 'global';
else
    handles.parameters.bwMethod = NaN;
end

guidata(hObject, handles);

% --- Executes on button press in checkboxBwA.
function checkboxBwA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBwA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    bwSwitch(hObject, eventdata, handles);
    set(handles.editBwA, 'enable', 'on');
    sens = str2double(get(handles.editBwA, 'String'));
    if isempty(sens)
        sens = 0.5;
        set(handles.editBwA, 'String', '0.5');
    end
    handles.parameters.bwMethod = 'adaptive';
    handles.parameters.thresholdSensitivity = sens;
else
    set(handles.editBwA, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editBwA, 'enable', 'off');
    handles.parameters.bwMethod = NaN;
    handles.parameters.thresholdSensitivity = NaN;
end

guidata(hObject, handles);


function editBwA_Callback(hObject, eventdata, handles)
% hObject    handle to editBwA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editBwA, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxBwA_Callback(handles.checkboxBwA, eventdata, handles);










%%%%%%%%%%%%%%%%%%%%%%%%%%% PRE-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkboxGauss.
function checkboxGauss_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editGauss, 'enable', 'on');
    handles.parameters.sigma1 = str2double(get(handles.editGauss, 'String'));
else
    set(handles.editGauss, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editGauss, 'enable', 'off');
    handles.parameters.sigma1 = NaN;
end

guidata(hObject, handles);


% --- Executes on button press in checkboxDoG.
function checkboxDoG_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDoG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject, 'Value')
    set(handles.editDoG1, 'enable', 'on');
    set(handles.editDoG2, 'enable', 'on');
    handles.parameters.sigma1 = str2double(get(handles.editDoG1, 'String'));
    handles.parameters.sigma2 = str2double(get(handles.editDoG2, 'String'));
else
    set(handles.editDoG1, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editDoG2, 'BackgroundColor', [0.94, 0.94, 0.94]);
    set(handles.editDoG1, 'enable', 'off');
    set(handles.editDoG2, 'enable', 'off');
    handles.parameters.sigma1 = NaN;
    handles.parameters.sigma2 = NaN;
end

guidata(hObject, handles);



function editGauss_Callback(hObject, eventdata, handles)
% hObject    handle to editGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(hObject, 'String'))
    set(handles.editGauss, 'BackgroundColor', [0.94, 0.94, 0.94]);
end
checkboxGauss_Callback(handles.checkboxGauss, eventdata, handles);


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
