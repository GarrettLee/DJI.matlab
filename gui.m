function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 25-Sep-2016 23:06:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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





% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% ��������ʼ��
serialInfo = instrhwinfo('serial');
handles.port.String = serialInfo.SerialPorts;
handles.port.Value = 1;

handles.bandrate.String = '9600';
handles.cam_index.String = webcamlist;
handles.cam_index.Value = 1;
for i = 1:length(handles.cam_index.String)
    if strcmp(handles.cam_index.String{i},'GOLDEN.VIEW' )
        handles.cam_index.Value = i;
    end
end

handles.resolution.String;

handles.camObject.index = handles.cam_index.Value;

handles.PLZPort.bandrate = str2double(handles.bandrate.String);
handles.PLZPort.index = handles.port.Value;




%% webcam�����пںͲ�����ʼ��
message = '';
if ~isempty(handles.port.String)
    handles.PLZPort.PLZs = getOpenedPort(handles.port.String{1},handles.PLZPort.bandrate);
    handles.PLZPort.port = handles.port.String{1} ;
else
    handles.CruisePoints.Enable = 'off';
    handles.PLZPort.PLZs = 0;
    message = [message, '�޷��򿪴���'];
end
if ~isempty(handles.cam_index.String)
    handles.camObject.cam = webcam(handles.cam_index.String{handles.cam_index.Value});
%     snapshot(handles.camObject.cam);
%     delete( handles.camObject.cam);
% %     pause(1);
%     handles.camObject.cam = webcam(handles.cam_index.String{handles.cam_index.Value});
else
    handles.camObject.cam = 0;
    message = [message, '���޷�������ͷ'];
end
handles.message.String = message;

% %% ��̨��������ʼ��
% handles.PLZPort.cruisePoint = cell(0,0);
% if ~isempty(handles.port.String)
%     PelcoD_setCruisePoints(handles.PLZPort.PLZs, '0', '0');
%     handles.PLZPort.cruisePoint{1} = 'Home';
%     handles.CruisePoints.String = handles.PLZPort.cruisePoint;
% end
%% ��ʼ���ֱ���
handles.resolution.String = handles.camObject.cam.AvailableResolutions;
resolutionString = regexp(handles.resolution.String(1), 'x', 'split');
minResolution = str2double(resolutionString{1});
minResIndex = 1;
for i = 1:length(handles.resolution.String)
    resolutionString = regexp(handles.resolution.String(i), 'x', 'split');
    if str2double(resolutionString{1}) < minResolution
        minResolution = str2double(resolutionString{1});
        minResIndex = i;
    end
end
handles.resolution.Value = minResIndex;
handles.camObject.Resolution = str2double(regexp(handles.resolution.String{minResIndex}, 'x', 'split'));
handles.camObject.cam.Resolution = handles.resolution.String{minResIndex};

%% ��ʼ��Axes1
hImage = imshow(uint8(rand(handles.camObject.Resolution(2), handles.camObject.Resolution(1))),'Parent',handles.axes1);
handles.hImage = hImage;

% handles.state_ptr = libpointer('doublePtr',trace_state)

%% ��ʼ����ʱ��ABC
handles.Timers.timerDisplay = [];
handles.Timers.timerTrace = [];
handles.Timers.timerDetect = [];
%% ��ʼ��һЩ��־����
handles.flags.continueTracking = true;
handles.flags.buttonDown = false;
handles.flags.targetSet = false;
handles.flags.getRectFromMouse = false;
%% ���ø��ٺͽ�������������
handles.start_tracking.Enable = 'off';
handles.stop_tracking.Enable = 'off';

%% ��
handles.target = [];
handles.rect_handle = [];

handles.faceDetecter = vision.CascadeObjectDetector();
handles.tracker.size = [];
handles.tracker.camespx = 0;
handles.tracker.camespy = 0;

%% �����ڴ�
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_tracking.
function start_tracking_Callback(hObject, eventdata, handles)
% set(handles.state_ptr, 'value', 0);
% addTask2Queue(@(~)beginTracking(handles.state_ptr), 0.1);
stop(handles.Timers.timerDisplay);
% handles.start_tracking.Interruptible = 'off';
handles.message.String = '������������������Ŀ��'; 
guidata(hObject, handles);

handles.start_preview.Enable = 'off';
handles.stop_tracking.Enable = 'on';
handles.start_tracking.Enable = 'off';

handles.flags.continueTracking = true;

handles.Timers.timerTrace = timer('Name', 'timer_trace','ExecutionMode', 'fixedSpacing', 'Period', 0.01 );
handles.Timers.timerDetect = timer('Name', 'timer_detect', 'ExecutionMode', 'fixedSpacing', 'Period', 0.001 );
handles.Timers.timerDetect.StartFcn = @(~,~)timerB_start(hObject);
handles.Timers.timerDetect.TimerFcn = @(~,~)timerB_running(hObject);
% handles.Timers.timerDetect.TimerFcn = @(~,~)pause(0.001);
handles.Timers.timerDetect.StopFcn = @(~,~)timerB_stop(hObject);
handles.Timers.timerDetect.ErrorFcn = @(~,~)timerB_Error(hObject);
set (handles.Timers.timerTrace, 'UserData', false);

guidata(hObject, handles);
handles.Timers.timerTrace.StartFcn = @(~,~)timerC_start(handles.Timers.timerTrace, hObject);
handles.Timers.timerTrace.TimerFcn = @(~,~)timerC_running(hObject);
handles.Timers.timerTrace.StopFcn = @(~,~)timerC_stop(hObject);
handles.Timers.timerTrace.ErrorFcn = @(~,~)delete(handles.Timers.timerTrace);
set (handles.Timers.timerTrace, 'UserData', false);
start(handles.Timers.timerTrace);



% hObject    handle to start_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in start_preview.
function start_preview_Callback(hObject, eventdata, handles)
% hObject    handle to start_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.start_preview.Enable = 'off';
handles.start_tracking.Enable = 'on';
handles.stop_tracking.Enable = 'on';

%��������ExecutionModeΪfixedSpacing����֤ÿ��ִ�ж�ʱ��֮�����㹻�ļ��������ʱ���᳤��ռ��CPU�������������޷�ִ��
handles.Timers.timerDisplay = timer('Name', 'timer_display','ExecutionMode', 'fixedSpacing', 'Period', 0.01 );
handles.Timers.timerDisplay.TimerFcn = @(~,~)timerA_running(handles);
handles.Timers.timerDisplay.stopFcn = @(~,~)fprintf('����\n');
handles.Timers.timerDisplay.ErrorFcn = @(~,~)delete(handles.Timers.timerDisplay);

start(handles.Timers.timerDisplay);
guidata(handles.figure1, handles);
%% �����ڴ�


% --- Executes on button press in stop_tracking.
function stop_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to stop_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PelcoD_Stop(handles.PLZPort.PLZs);
stopTimer(handles.Timers.timerDisplay);
stopTimer(handles.Timers.timerDetect);
stopTimer(handles.Timers.timerTrace);
handles.flags.continueTracking = false;
guidata(hObject, handles);
start(handles.Timers.timerDisplay);
% start_preview_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function start_tracking_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setting_comfirm.
function setting_comfirm_Callback(hObject, eventdata, handles)
% hObject    handle to setting_comfirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% ֹͣ��ʱ��
stopTimer(handles.Timers.timerDisplay);
stopTimer(handles.Timers.timerDetect);
stopTimer(handles.Timers.timerTrace);
handles.flags.continueTracking = false;

%% ���ð���Ȩ��
handles.start_preview.Enable = 'on';
handles.start_tracking.Enable = 'off';
handles.stop_tracking.Enable = 'off';
%% ���´���
if handles.PLZPort.index ~= handles.port.Value || handles.PLZPort.bandrate ~= str2double(handles.bandrate.String)
    handles.PLZPort.index = handles.port.Value;
    handles.PLZPort.bandrate = str2double(handles.bandrate.String);
    delete(handles.PLZPort.PLZs)
    handles.PLZPort.PLZs = getOpenedPort(handles.port.String{handles.port.Value}, handles.PLZPort.bandrate);
end

%% �������
if handles.camObject.index ~= handles.cam_index.Value || ~strcmp(handles.camObject.cam.Resolution,handles.resolution.String{handles.resolution.Value})
    handles.camObject.index = handles.cam_index.Value;
    handles.camObject.Resolution = str2double(regexp(handles.resolution.String{handles.resolution.Value}, 'x', 'split'));
    delete( handles.camObject.cam);
    pause(0.5);
%     handles.camObject.cam = webcam(handles.cam_index.String{handles.cam_index.Value});
%     delete( handles.camObject.cam);
%     pause(0.5);
    handles.camObject.cam = webcam(handles.cam_index.String{handles.cam_index.Value});
    handles.camObject.cam.Resolution = handles.resolution.String{handles.resolution.Value};
    delete(handles.hImage);
    hImage = imshow(uint8(rand(handles.camObject.Resolution(2), handles.camObject.Resolution(1))),'Parent',handles.axes1);
    handles.hImage = hImage;
    
end
%% �����ڴ�
guidata(hObject, handles);
function cam_index_Callback(hObject, eventdata, handles)
% hObject    handle to cam_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam_index as text
%        str2double(get(hObject,'String')) returns contents of cam_index as a double


% --- Executes during object creation, after setting all properties.
function cam_index_CreateFcn(hObject, ~, handles)
% hObject    handle to cam_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in resolution.
function resolution_Callback(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns resolution contents as cell array
%        contents{get(hObject,'Value')} returns selected item from resolution


% --- Executes during object creation, after setting all properties.
function resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function port_Callback(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of port as text
%        str2double(get(hObject,'String')) returns contents of port as a double


% --- Executes during object creation, after setting all properties.
function port_CreateFcn(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bandrate_Callback(hObject, eventdata, handles)
% hObject    handle to bandrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bandrate as text
%        str2double(get(hObject,'String')) returns contents of bandrate as a double


% --- Executes during object creation, after setting all properties.
function bandrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in from_mouse.
function from_mouse_Callback(hObject, eventdata, handles)
% hObject    handle to from_mouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of from_mouse


% --- Executes when selected object is changed in initial_type.
function initial_type_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in initial_type 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% guidata(hObject, handles);

% --------------------------------------------------------------------
function initial_type_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to initial_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.Timers.timerTrace)
    if isvalid(handles.Timers.timerTrace)
        % Before exiting, if the timer is running, stop it.
        if handles.Timers.timerTrace.UserData == true
            handles.flags.getRectFromMouse = handles.Timers.timerTrace.UserData ;
            handles.Timers.timerTrace.UserData = false;
        end
    end
end
% guidata(hObject);
if handles.flags.getRectFromMouse
    handles.message.String = '�϶����ѡȡĿ��';
    if(strcmp(get(gcf,'SelectionType'),'normal'))%�ж���갴�µ����ͣ�mormalΪ���  
        handles.flags.buttonDown=true;  
        start_pos = get(handles.axes1,'CurrentPoint');%��ȡ������������λ��  
        handles.target(1) = start_pos(1,1);
        handles.target(2) = start_pos(1,2);
        
    end  
end
guidata(hObject, handles);
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearTimer(handles.Timers.timerDisplay);
clearTimer(handles.Timers.timerTrace);
clearTimer(handles.Timers.timerDetect);

PelcoD_Stop(handles.PLZPort.PLZs);

name  = handles.cam_index.String{handles.cam_index.Value};
if handles.PLZPort.PLZs ~= 0
    delete(handles.PLZPort.PLZs);
end
if handles.camObject.cam ~= 0
    delete( handles.camObject.cam);
end
pause(0.5);
handles.camObject.cam = webcam(name);
delete(handles.camObject.cam);
pause(1);
%% �����ڴ�
guidata(hObject, handles);
% Hint: delete(hObject) closes the figure
delete(hObject);


function clearTimer(timer)
if ~isempty(timer)
    if isvalid(timer)
        % Before exiting, if the timer is running, stop it.
        if strcmp(get(timer, 'Running'), 'on')
            stop(timer);
        end
        % Destroy timer
        delete(timer);
    end
end

function stopTimer(timer)
if ~isempty(timer)
    % Before exiting, if the timer is running, stop it.
    if strcmp(get(timer, 'Running'), 'on')
        stop(timer);
        
    end
end


% --- Executes during object deletion, before destroying properties.
function axes1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function prepareTimerTrace()


% --- Executes on selection change in cam_index.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to cam_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cam_index contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cam_index


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x = timerA_running(handles)
if isvalid(handles.camObject.cam)
     img = snapshot(handles.camObject.cam);
     set(handles.hImage, 'CData', uint8(img)); %XData��YData������ʾ�Ĵ�С
%      drawnow;
%      fprintf('ssss');
end

function x = timerB_start(hObject)
handles = guidata(hObject);
if  isvalid(handles.camObject.cam)
    img = snapshot(handles.camObject.cam);
    set(handles.hImage,'CData',uint8(img));
    handles.tracker.size = size(img);
    w = handles.target(3);
    h = handles.target(4);
    img = rgb2gray(img);
    [imHeight, imWidth] = size(img);
%     handles.tracker.camespx = (imWidth/ 2) * w / ( 8 * ( imHeight + imWidth ));
%     handles.tracker.camespy = (imHeight / 2) * h / ( 8 * ( imHeight + imWidth ));
    handles.tracker.camespx = w / 6;
    handles.tracker.camespy = h / 6;
    
    initstate = handles.target;
    if length(size(img))==3
        img = rgb2gray(img);
    end
    img = double(img);
 
    handles.tracker.trparams.init_negnumtrain = 50;%number of trained negative samples
    handles.tracker.trparams.init_postrainrad = 4;%radical scope of positive samples
    handles.tracker.trparams.initstate = initstate;% object position [x y width height]
    handles.tracker.trparams.srchwinsz = 25;% size of search window
    %-------------------------
    %% Classifier parameters
    handles.tracker.clfparams.width = handles.tracker.trparams.initstate(3);
    handles.tracker.clfparams.height= handles.tracker.trparams.initstate(4);
    % feature parameters
    % number of rectangle from 2 to 4.
    handles.tracker.ftrparams.minNumRect =2;
    handles.tracker.ftrparams.maxNumRect =4;
    M = 100;% number of all weaker classifiers, i.e,feature pool
    %-------------------------
    handles.tracker.posx.mu = zeros(M,1);% mean of positive features
    handles.tracker.negx.mu = zeros(M,1);
    handles.tracker.posx.sig= ones(M,1);% variance of positive features
    handles.tracker.negx.sig= ones(M,1);

    handles.tracker.lRate = 0.85;% Learning rate parameter
    %% Compute feature template
    [handles.tracker.ftr.px,handles.tracker.ftr.py,handles.tracker.ftr.pw,handles.tracker.ftr.ph,handles.tracker.ftr.pwt] = HaarFtr(handles.tracker.clfparams,handles.tracker.ftrparams,M);
    %% Compute sample templates
    handles.tracker.posx.sampleImage = sampleImgDet(img,initstate,handles.tracker.trparams.init_postrainrad,1);
    handles.tracker.negx.sampleImage = sampleImg(img,initstate,1.5*handles.tracker.trparams.srchwinsz,4+handles.tracker.trparams.init_postrainrad,handles.tracker.trparams.init_negnumtrain);
    %% Feature extraction
    iH = integral(img);%Compute integral image
    handles.tracker.posx.feature = getFtrVal(iH,handles.tracker.posx.sampleImage,handles.tracker.ftr);
    handles.tracker.negx.feature = getFtrVal(iH,handles.tracker.negx.sampleImage,handles.tracker.ftr);
    [handles.tracker.posx.mu,handles.tracker.posx.sig,handles.tracker.negx.mu,handles.tracker.negx.sig] = classiferUpdate(handles.tracker.posx,handles.tracker.negx,handles.tracker.posx.mu,handles.tracker.posx.sig,handles.tracker.negx.mu,handles.tracker.negx.sig,handles.tracker.lRate);% update distribution parameters
    handles.tracker.time = clock;
    handles.tracker.frames = 0;
    handles.tracker.dirt = 'stop';
    handles.tracker.dir = 'stop';
    handles.tracker.camt = 0;
    handles.start_tracking.Enable = 'off';
    guidata(hObject, handles);
    handles.Timers.timerDetect.UserData = true;
end

function x = timerB_running(hObject)
    
    handles = guidata(hObject);
    if (~handles.Timers.timerDetect.UserData)
        return;
    end
    
        %% ������һѭ����������ָ̨��ı���̨����
        if strcmp(handles.tracker.dirt, 'stop')
            PelcoD_Stop(handles.PLZPort.PLZs);
            img = snapshot(handles.camObject.cam);
            handles.tracker.dir = handles.tracker.dirt;
        elseif ~strcmp(handles.tracker.dirt, handles.tracker.dir)
            handles.tracker.dir = handles.tracker.dirt;
            PelcoD_Stop(handles.PLZPort.PLZs);
            img = snapshot(handles.camObject.cam);
            pause(0.05);
            PelcoD_Rotate(handles.PLZPort.PLZs, '00',handles.tracker.dir);
        else
            PelcoD_Stop(handles.PLZPort.PLZs);
            img = snapshot(handles.camObject.cam);
            PelcoD_Rotate(handles.PLZPort.PLZs, '00',handles.tracker.dir);
        end
        imgSr = img;% imgSr is used for showing tracking results.

        if length(size(img))==3
            img = rgb2gray(img);
        end
        img = double(img); 
        iH = integral(img);%Compute integral image
        %% Coarse detection
        step_n = 4; % coarse search step
        detectx.sampleImage = sampleImgDet(img,handles.target,handles.tracker.trparams.srchwinsz,step_n);    
        detectx.feature = getFtrVal(iH,detectx.sampleImage,handles.tracker.ftr);
        r = ratioClassifier(handles.tracker.posx,handles.tracker.negx,detectx.feature);% compute the classifier for all samples
        clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
        [c,index] = max(clf);
        x = detectx.sampleImage.sx(index);
        y = detectx.sampleImage.sy(index);
        w = detectx.sampleImage.sw(index);
        h = detectx.sampleImage.sh(index);
        handles.target = [x y w h];
        %% Fine detection
        step_n = 1;
        detectx.sampleImage = sampleImgDet(img,handles.target,10,step_n);    
        detectx.feature = getFtrVal(iH,detectx.sampleImage,handles.tracker.ftr);
        r = ratioClassifier(handles.tracker.posx,handles.tracker.negx,detectx.feature);% compute the classifier for all samples
        clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
        [c,index] = max(clf);
        x = detectx.sampleImage.sx(index);
        y = detectx.sampleImage.sy(index);
        w = detectx.sampleImage.sw(index);
        h = detectx.sampleImage.sh(index);
        handles.target = [x y w h];
        %% Show the tracking results
%         figure(3);
        set(handles.hImage,'CData',uint8(imgSr));
        
        set (handles.rect_handle, 'Position',handles.target,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);        
        
        %% Extract samples 
        handles.tracker.posx.sampleImage = sampleImgDet(img,handles.target,handles.tracker.trparams.init_postrainrad,1);
        handles.tracker.negx.sampleImage = sampleImg(img,handles.target,1.5*handles.tracker.trparams.srchwinsz,4+handles.tracker.trparams.init_postrainrad,handles.tracker.trparams.init_negnumtrain);
        %% Update all the features
        handles.tracker.posx.feature = getFtrVal(iH,handles.tracker.posx.sampleImage,handles.tracker.ftr);
        handles.tracker.negx.feature = getFtrVal(iH,handles.tracker.negx.sampleImage,handles.tracker.ftr); 
        [handles.tracker.posx.mu,handles.tracker.posx.sig,handles.tracker.negx.mu,handles.tracker.negx.sig] = classiferUpdate(handles.tracker.posx,handles.tracker.negx,handles.tracker.posx.mu,handles.tracker.posx.sig,handles.tracker.negx.mu,handles.tracker.negx.sig,handles.tracker.lRate);% update distribution parameters  
        %% ���²���
        centerx = x + w/2;
        centery = y + h/2;
        camt = handles.tracker.camt + 1;
        camm = 1;
        imgHeight = handles.tracker.size(1);
        imgWidth = handles.tracker.size(2);
        camespy = handles.tracker.camespy;
        camespx = handles.tracker.camespx;
        if (abs(centerx - imgWidth/2) / camespx) >= (abs(centery - imgHeight/2) / (camespy))
            ax = 'x';
        else
            ax = 'y';
        end
        if strcmp(ax, 'x')
            if abs(centerx - imgWidth/2) / 60 <= 1
                camm = 3;
            end
            if abs(centerx - imgWidth/2) / 50 <= 1
                camm = 5;
            end
        elseif strcmp(ax, 'y')
            if abs(centery - imgHeight/2) / (50) <= 1
                camm = 3;
            end
            if abs(centery - imgHeight/2) / (30) <= 1
                camm = 5;
            end
        end
        %% ���ݶ���λ���ж���һ����ָ̨��
        handles.tracker.dirt = 'stop';
        if camt >= camm
            if strcmp(ax, 'x')
                if centerx - imgWidth/2 >  camespx
    %                 fprintf('���ұ�');
                    handles.tracker.dirt = 'left';
                elseif centerx < imgWidth/2 - camespx
    %                 fprintf('�����');
                    handles.tracker.dirt = 'right';
                end
            else
                if centery - imgHeight/2 <  - camespy
    %                 fprintf('���ϱ�');
                    handles.tracker.dirt = 'up';
                elseif centery > imgHeight/2 + camespy
    %                 fprintf('���±�');
                    handles.tracker.dirt = 'down';
                end
            end
            handles.tracker.camt = 0;
        end
        if etime(clock, handles.tracker.time)>=1
             handles.tracker.time = clock;
            handles.message.String = ['ÿ��֡����', num2str(handles.tracker.frames)];
            handles.tracker.frames = 0;
        end
        handles.tracker.frames = handles.tracker.frames + 1;
        handles.tracker.camt = handles.tracker.camt + 1;
     guidata(hObject, handles);

function x = timerB_stop(hObject)
handles = guidata(hObject);    
delete(handles.rect_handle);
handles.start_tracking.Enable = 'on';
guidata(hObject, handles);
PelcoD_Stop(handles.PLZPort.PLZs);

function x = timerB_Error(hObject)
handles = guidata(hObject);
PelcoD_Stop(handles.PLZPort.PLZs);


function x = timerC_start(timers,hObject)
     handles = guidata(hObject);
    if strcmp(handles.initial_type.SelectedObject.Tag, 'from_mouse')
%         handles.flags.getRectFromMouse = true;
        timers.UserData = true;
%         handles.message.String = '�������ѡ��Ŀ��';
    end
   
%     guidata(hObject, handles);
    
function x = timerC_running(hObject)
 handles = guidata(hObject);
if isvalid(handles.camObject.cam)
    img = snapshot(handles.camObject.cam);
    set(handles.hImage, 'CData', uint8(img)); %XData��YData������ʾ�Ĵ�С
    if strcmp(handles.initial_type.SelectedObject.Tag, 'detect_face')
        bbox = step(handles.faceDetecter, img);
        [h, w] =  size(bbox);
        if ~isempty(bbox)
            if h == 1 && w == 4
                handles.target = bbox;
                handles.flags.targetSet = true;
                if isempty(handles.rect_handle)
                    handles.rect_handle = rectangle('Position',handles.target,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);   
                else
                    if ~isvalid(handles.rect_handle)
                        handles.rect_handle = rectangle('Position',handles.target,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);   
                    else
                        set( handles.rect_handle,'Position',handles.target, 'Parent', handles.axes1);
                    end
                end
                handles.message.String = '��׽������';
                guidata(hObject, handles);
            end
        end
    end
    if handles.flags.targetSet == true
        stop(handles.Timers.timerTrace);
        handles.flags.targetSet = false;
        guidata(hObject, handles);
    end
    
end

function x = timerC_stop(hObject)
handles = guidata(hObject);
if handles.flags.continueTracking == true
    start(handles.Timers.timerDetect);
end

% --- Executes during object creation, after setting all properties.
function start_preview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if     handles.flags.buttonDown  && handles.flags.getRectFromMouse
    handles.message.String = '�ں��ʵ�λ��ֹͣ���';
    pos = get(handles.axes1, 'CurrentPoint');%��ȡ��ǰλ��  
    x1 = min(handles.target(1), pos(1,1));
    x2 = max(handles.target(1), pos(1,1));
    y1 = min(handles.target(2), pos(1,2));
    y2 = max(handles.target(2), pos(1,2));
    rect = [x1,y1, x2 - x1, y2 - y1];
    if isempty(handles.rect_handle)
        handles.rect_handle = rectangle('Position',rect,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);   
    else
        if ~isvalid(handles.rect_handle)
            handles.rect_handle = rectangle('Position',rect,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);   
        else
            set( handles.rect_handle,'Position',rect, 'Parent', handles.axes1);
        end
    end
    guidata(hObject, handles);
end  



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.flags.buttonDown && handles.flags.getRectFromMouse
    handles.flags.buttonDown = false;
    pos = get(handles.axes1, 'CurrentPoint');
    x1 = min(handles.target(1), pos(1,1));
    x2 = max(handles.target(1), pos(1,1));
    y1 = min(handles.target(2), pos(1,2));
    y2 = max(handles.target(2), pos(1,2));
    handles.target = round([x1,y1, x2 - x1, y2 - y1]);
    if (handles.target(3) > 5 && handles.target(4) > 5) && handles.target(1) > 0 && handles.target(2) > 0  &&...
        handles.target(1) + handles.target(3) < handles.hImage.XData(2) && ...
        handles.target(2) + handles.target(4) < handles.hImage.YData(2)
        if isempty(handles.rect_handle)
           handles.rect_handle = rectangle('Position',handles.target,'LineWidth',4,'EdgeColor','r', 'Parent', handles.axes1);   
        else
           set( handles.rect_handle,'Position',handles.target, 'Parent', handles.axes1);
        end
       
        handles.flags.targetSet = true;
        handles.flags.getRectFromMouse = false;
        handles.message.String = '����';
    else
        if ~isempty(handles.rect_handle)
           delete(handles.rect_handle);
           handles.rect_handle = [];
        end
        handles.message.String = 'Ŀ��̫С,���ػ�';
    end
    guidata(hObject, handles);
end


% % --- Executes on button press in goto.
% function goto_Callback(hObject, eventdata, handles)
% % hObject    handle to goto (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of goto
% %% ֹͣ��ʱ��
% stopTimer(handles.Timers.timerDisplay);
% stopTimer(handles.Timers.timerDetect);
% stopTimer(handles.Timers.timerTrace);
% handles.flags.continueTracking = false;
% 
% %% ���ð���Ȩ��
% handles.start_preview.Enable = 'on';
% handles.start_tracking.Enable = 'off';
% handles.stop_tracking.Enable = 'off';
% 
% PelcoD_gotoCruisePoints( handles.PLZPort.PLZs, num2str(handles.CruisePoints.Value), '0');
% pause(3);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearTimer(handles.Timers.timerDisplay);
clearTimer(handles.Timers.timerTrace);
clearTimer(handles.Timers.timerDetect);

PelcoD_Stop(handles.PLZPort.PLZs);

name  = handles.cam_index.String{handles.cam_index.Value};
if handles.PLZPort.PLZs ~= 0
    delete(handles.PLZPort.PLZs);
end
if handles.camObject.cam ~= 0
    delete( handles.camObject.cam);
end
pause(0.5);
handles.camObject.cam = webcam(name);
delete(handles.camObject.cam);
pause(1);
%% �����ڴ�
guidata(hObject, handles);
delete(hObject);
Runtracker;
