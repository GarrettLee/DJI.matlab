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

% Last Modified by GUIDE v2.5 24-Sep-2016 22:22:13

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

%% 设置面板初始化
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
%% webcam、串行口和参数初始化
message = '';
if ~isempty(handles.port.String)
    handles.PLZPort.PLZs = getOpenedPort(handles.port.String{1},handles.PLZPort.bandrate);
    handles.PLZPort.port = handles.port.String{1} ;
else
    handles.PLZPort.PLZs = 0;
    message = [message, '无法打开串口'];
end
if ~isempty(handles.cam_index.String)
    handles.camObject.cam = webcam(handles.cam_index.String{handles.cam_index.Value});
else
    handles.camObject.cam = 0;
    message = [message, '、无法打开摄像头'];
end
handles.message.String = message;
%% 初始化分辨率
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

%% 初始化Axes1
hImage = imshow(uint8(rand(handles.camObject.Resolution(2), handles.camObject.Resolution(1))),'Parent',handles.axes1);
handles.hImage = hImage;

% handles.state_ptr = libpointer('doublePtr',trace_state)

%% 初始化定时器ABC
handles.Timers.timerDisplay = [];
handles.Timers.timerTrace = [];
handles.Timers.timerDetect = [];
%% 初始化一些标志变量
handles.flags.continueTracking = true;
handles.flags.buttonDown = false;
handles.flags.targetSet = false;
handles.flags.getRectFromMouse = false;
%% 设置跟踪和结束按键不可用
handles.start_tracking.Enable = 'off';
handles.stop_tracking.Enable = 'off';

%% 框
handles.target = [];
handles.rect_handle = [];

handles.faceDetecter = vision.CascadeObjectDetector();
%% 更新内存
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
handles.start_tracking.Interruptible = 'off';
guidata(hObject, handles);

handles.start_preview.Enable = 'off';
handles.stop_tracking.Enable = 'on';

handles.Timers.timerTrace = timer('Name', 'timer_trace','ExecutionMode', 'fixedSpacing', 'Period', 0.01 );
guidata(hObject, handles);
handles.Timers.timerTrace.StartFcn = @(~,~)timerC_start(hObject);
handles.Timers.timerTrace.TimerFcn = @(~,~)timerC_running(hObject);
handles.Timers.timerTrace.ErrorFcn = @(~,~)delete(handles.Timers.timerTrace);
set (handles.Timers.timerTrace, 'UserData', false);
start(handles.Timers.timerTrace);

% 
% global trace_state
% cam = handles.cam_index;
% hImageDetect = handles.hImage;
% PLZs = handles.PLZs;
% camt = 0;
% dir = 'stop';
% dirt = 'stop';
% faceDetector = vision.CascadeObjectDetector();
% trace_state = true;
% while trace_state
%     img = snapshot(cam);
%     set(hImageDetect,'CData',uint8(img));
%     imgSize = size(img);
%     imgHeight = imgSize(1);
%     imgWidth = imgSize(2);
%     bbox = step(faceDetector, img);
%     [rows, ~] = size(bbox);
%     if rows == 0
%         continue;
%     end
%     x = bbox(1);
%     y = bbox(2);
%     w = bbox(3);
%     h = bbox(4);
%     % [x, y, w, h] = getRectFromMouse();
% %     while (x <= 0)||(x >= imgWidth)||(y <= 0)||(y>=imgHeight)||(h == 0)||(w == 0)
% %         [x, y, w, h] = getRectFromMouse();
% %     end
%     img = rgb2gray(img);
% %     preframe = img;
%     camespx = w / 8;
%     camespy = h / 8;
%     % x = initstate(1);% x axis at the Top left corner
%     % y = initstate(2);
%     % w = initstate(3);% width of the rectangle
%     % h = initstate(4);% height of the rectangle
%     initstate(1) = x;% x axis at the Top left corner
%     initstate(2) = y;
%     initstate(3) = w;% width of the rectangle
%     initstate(4) = h;% height of the rectangle
%     centerx = x + w/2;
%     centery = y + h/2;
%     %---------------------------
%     % img = imread(img_dir(1).name);
%     if length(size(img))==3
%         img = rgb2gray(img);
%     end
%     img = double(img);
%     %% 改变亮度
%     % grayscale = 0;
%     % for i = x: x+w
%     %     for j = y: y+h
%     %         grayscale = double(img(i,j)) + grayscale;
%     %     end
%     % end
%     % grayscale = grayscale / (w*h);
%     %% 
%     trparams.init_negnumtrain = 50;%number of trained negative samples
%     trparams.init_postrainrad = 4;%radical scope of positive samples
%     trparams.initstate = initstate;% object position [x y width height]
%     trparams.srchwinsz = 25;% size of search window
%     %-------------------------
%     %% Classifier parameters
%     clfparams.width = trparams.initstate(3);
%     clfparams.height= trparams.initstate(4);
%     % feature parameters
%     % number of rectangle from 2 to 4.
%     ftrparams.minNumRect =2;
%     ftrparams.maxNumRect =4;
%     M = 100;% number of all weaker classifiers, i.e,feature pool
%     %-------------------------
%     posx.mu = zeros(M,1);% mean of positive features
%     negx.mu = zeros(M,1);
%     posx.sig= ones(M,1);% variance of positive features
%     negx.sig= ones(M,1);
% 
%     lRate = 0.85;% Learning rate parameter
%     %% Compute feature template
%     [ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);
%     %% Compute sample templates
%     posx.sampleImage = sampleImgDet(img,initstate,trparams.init_postrainrad,1);
%     negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
%     %% Feature extraction
%     iH = integral(img);%Compute integral image
%     posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
%     negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
%     [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
%     %% 开始计时
%     start = clock;
%     %% Begin tracking
% %     dximg = uint8(zeros(imgHeight, imgWidth));
%     rect_handle = [];
%     text_handle = [];
%     frameTime = 1;
%     while trace_state
%         timee = etime(clock,start);
%     %     fprintf('程序运行时间为：%3.2fs\n\n', etime(clock,start));
%         start = clock;
%         %% 根据上一循环给出的云台指令改变云台动作
%         if strcmp(dirt, 'stop')
%             PelcoD_Stop(PLZs);
%             img = snapshot(cam);
%             dir = dirt;
%         elseif ~strcmp(dirt, dir)
%             fprintf([dir,'!=',dirt]);
%             dir = dirt;
%             PelcoD_Stop(PLZs);
%             img = snapshot(cam);
%             pause(0.05);
%             PelcoD_Rotate(PLZs, '00',dir);
%         else
%             PelcoD_Stop(PLZs);
%             img = snapshot(cam);
%             PelcoD_Rotate(PLZs, '00',dir);
%         end
%         imgSr = img;% imgSr is used for showing tracking results.
% 
%         if length(size(img))==3
%             img = rgb2gray(img);
%         end
% %         figure(2);
% %         dximg = (dximg + preframe - img)/2;
% %         imshow(dximg);
% %         preframe = img;
% %         if mean(mean(dximg)) < 1
% %             PelcoD_gotoCruisePoints( PLZs, '00', '00' );
% %             pause(5);
% %             break;
% %         end
% %         fprintf([num2str(mean(mean(dximg))), '\n']);
%         img = double(img); 
%         iH = integral(img);%Compute integral image
%         %% Coarse detection
%         step_n = 4; % coarse search step
%         detectx.sampleImage = sampleImgDet(img,initstate,trparams.srchwinsz,step_n);    
%         detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
%         r = ratioClassifier(posx,negx,detectx.feature);% compute the classifier for all samples
%         clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
%         [c,index] = max(clf);
%         x = detectx.sampleImage.sx(index);
%         y = detectx.sampleImage.sy(index);
%         w = detectx.sampleImage.sw(index);
%         h = detectx.sampleImage.sh(index);
%         initstate = [x y w h];
%         %% Fine detection
%         step_n = 1;
%         detectx.sampleImage = sampleImgDet(img,initstate,10,step_n);    
%         detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
%         r = ratioClassifier(posx,negx,detectx.feature);% compute the classifier for all samples
%         clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
%         [c,index] = max(clf);
%         x = detectx.sampleImage.sx(index);
%         y = detectx.sampleImage.sy(index);
%         w = detectx.sampleImage.sw(index);
%         h = detectx.sampleImage.sh(index);
%         initstate = [x y w h];
%         %% Show the tracking results
% %         figure(3);
%         set(hImageDetect,'CData',uint8(imgSr));
%         delete(rect_handle);
%         delete(text_handle);
%         rect_handle = rectangle('Position',initstate * 2,'LineWidth',4,'EdgeColor','r');        
%         text_handle = text(5, 18, strcat('#',num2str(frameTime)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
%         frameTime = frameTime + 1;
% %          
% %         pause(0.00001); 
% %         hold off;
%         %% Extract samples 
%         posx.sampleImage = sampleImgDet(img,initstate,trparams.init_postrainrad,1);
%         negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
%         %% Update all the features
%         posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
%         negx.feature = getFtrVal(iH,negx.sampleImage,ftr); 
%         [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters  
%         %% 更新参数
%         centerx = x + w/2;
%         centery = y + h/2;
%         camt = camt + 1;
%         camm = 1;
%         if (abs(centerx - imgWidth/2) / camespx) >= (abs(centery - imgHeight/2) / (camespy))
%             ax = 'x';
%         else
%             ax = 'y';
%         end
%         if strcmp(ax, 'x')
%             if abs(centerx - imgWidth/2) / 50 <= 1
%                 camm = 3;
%             end
%             if abs(centerx - imgWidth/2) / 30 <= 1
%                 camm = 5;
%             end
%         elseif strcmp(ax, 'y')
%             if abs(centery - imgHeight/2) / (40) <= 1
%                 camm = 3;
%             end
%             if abs(centery - imgHeight/2) / (20) <= 1
%                 camm = 5;
%             end
%         end
%         %% 根据对象位置判断下一个云台指令
%         dirt = 'stop';
%         if camt >= camm
%             if strcmp(ax, 'x')
%                 if centerx - imgWidth/2 >  camespx
%     %                 fprintf('在右边');
%                     dirt = 'left';
%                 elseif centerx < imgWidth/2 - camespx
%     %                 fprintf('在左边');
%                     dirt = 'right';
%                 end
%             else
%                 if centery - imgHeight/2 <  - camespy
%     %                 fprintf('在上边');
%                     dirt = 'up';
%                 elseif centery > imgHeight/2 + camespy
%     %                 fprintf('在下边');
%                     dirt = 'down';
%                 end
%             end
%             camt = 0;
%         end
%         
%     end
%     delete(rect_handle);
%     delete(text_handle);
%     PelcoD_Stop(PLZs);
% %     delete(PLZs)
%    
% end

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

%必须设置ExecutionMode为fixedSpacing，保证每次执行定时器之间有足够的间隔，否则定时器会长期占用CPU导致其他程序无法执行
handles.Timers.timerDisplay = timer('Name', 'timer_display','ExecutionMode', 'fixedSpacing', 'Period', 0.01 );
handles.Timers.timerDisplay.TimerFcn = @(~,~)timerA_running(handles);
handles.Timers.timerDisplay.ErrorFcn = @(~,~)delete(handles.Timers.timerDisplay);

start(handles.Timers.timerDisplay);
guidata(handles.figure1, handles);
%% 更新内存


% --- Executes on button press in stop_tracking.
function stop_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to stop_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trace_state
trace_state = false;


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
%% 停止定时器
stopTimer(handles.Timers.timerDisplay);
stopTimer(handles.Timers.timerDetect);
stopTimer(handles.Timers.timerTrace);
handles.flags.continueTracking = false;

%% 设置按键权限
handles.start_preview.Enable = 'on';
handles.start_tracking.Enable = 'off';
handles.stop_tracking.Enable = 'off';
%% 更新串口
if handles.PLZPort.index ~= handles.port.Value || handles.PLZPort.bandrate ~= str2double(handles.bandrate.String)
    handles.PLZPort.index = handles.port.Value;
    handles.PLZPort.bandrate = str2double(handles.bandrate.String);
    delete(handles.PLZPort.PLZs)
    handles.PLZPort.PLZs = getOpenedPort(handles.port.String{handles.port.Value}, handles.PLZPort.bandrate);
end

%% 更新相机
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
%% 更新内存
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
            handles.getRectFromMouse = handles.Timers.timerTrace.UserData ;
            handles.Timers.timerTrace.UserData = false;
        end
    end
end
% guidata(hObject);
if handles.flags.getRectFromMouse
    handles.message.String = '拖动鼠标选取目标';
    if(strcmp(get(gcf,'SelectionType'),'normal'))%判断鼠标按下的类型，mormal为左键  
        handles.flags.buttonDown=true;  
        start_pos = get(handles.axes1,'CurrentPoint');%获取坐标轴上鼠标的位置  
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
%% 更新内存
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
     set(handles.hImage, 'CData', uint8(img)); %XData、YData设置显示的大小
%      drawnow;
%      fprintf('ssss');
end


function x = timerC_start(hObject)
    handles = guidata(hObject);
    if strcmp(handles.initial_type.SelectedObject.Tag, 'from_mouse')
%         handles.flags.getRectFromMouse = true;
        handles.Timers.timerTrace.UserData = true;
        handles.message.String = '请用鼠标选定目标';
    end
   
    guidata(hObject, handles);
    
function x = timerC_running(hObject)
 handles = guidata(hObject);
if isvalid(handles.camObject.cam)
    img = snapshot(handles.camObject.cam);
    set(handles.hImage, 'CData', uint8(img)); %XData、YData设置显示的大小
    if strcmp(handles.initial_type.SelectedObject.Tag, 'detect_face')
        bbox = step(handles.faceDetecter, img);
        if ~isempty(bbox)
            handles.target = bbox;
            handles.flags.targetSet = true;
        end
    end
    if handles.flags.targetSet == true
        stop(handles.Timers.timerTrace);
    end
%     guidata(hObject, handles);
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
if     handles.flags.buttonDown == true  && handles.flags.getRectFromMouse
    handles.message.String = '在合适的位置停止鼠标';
    pos = get(handles.axes1, 'CurrentPoint');%获取当前位置  
    x1 = min(handles.target(1), pos(1,1));
    x2 = max(handles.target(1), pos(1,1));
    y1 = min(handles.target(2), pos(1,2));
    y2 = max(handles.target(2), pos(1,2));
    rect = [x1,y1, x2 - x1, y2 - y1];
    if isempty(handles.rect_handle)
        handles.rect_handle = rectangle('Position',rect,'LineWidth',4,'EdgeColor','r');   
    else
        set( handles.rect_handle,'Position',rect);
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
    handles.target = [x1,y1, x2 - x1, y2 - y1];
    if (handles.target(3) > 5 && handles.target(4) > 5) && handles.target(1) > 0 && handles.target(2) > 0  &&...
        handles.target(1) + handles.target(3) < handles.hImage.XData(2) && ...
        handles.target(2) + handles.target(4) < handles.hImage.YData(2)
        if isempty(handles.rect_handle)
           handles.rect_handle = rectangle('Position',handles.target,'LineWidth',4,'EdgeColor','r');   
        else
           set( handles.rect_handle,'Position',handles.target);
        end
       
        handles.flags.targetSet = true;
        handles.flags.getRectFromMouse = false;
        handles.message.String = '就绪';
    else
        if ~isempty(handles.rect_handle)
           delete(handles.rect_handle);
           handles.rect_handle = [];
        end
        handles.message.String = '目标太小,请重画';
    end
    guidata(hObject, handles);
end
