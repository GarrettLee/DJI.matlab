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

% Last Modified by GUIDE v2.5 22-Sep-2016 10:15:55

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
%% webcam、串行口和参数初始化

PLZs = getOpenedPort('com7',9600);
handles.cam=webcam(2);
handles.cam.Resolution = '320x240';
hImage = imshow(uint8(rand(480, 640)),'Parent',handles.axes1);
handles.hImage = hImage;
handles.PLZs = PLZs;
state = 0;
handles.state_ptr = libpointer('doublePtr',state)
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

hImageDetect = handle.hImage;
faceDetector = vision.CascadeObjectDetector();
while true
    img = snapshot(cam);
    set(hImageDetect,'CData',uint8(img));
    imgSize = size(img);
    imgHeight = imgSize(1);
    imgWidth = imgSize(2);
    bbox = step(faceDetector, img);
    [rows, ~] = size(bbox);
    if rows == 0
        continue;
    end
    x = bbox(1);
    y = bbox(2);
    w = bbox(3);
    h = bbox(4);
    % [x, y, w, h] = getRectFromMouse();
%     while (x <= 0)||(x >= imgWidth)||(y <= 0)||(y>=imgHeight)||(h == 0)||(w == 0)
%         [x, y, w, h] = getRectFromMouse();
%     end
    img = rgb2gray(img);
%     preframe = img;
    camespx = w / 8;
    camespy = h / 8;
    % x = initstate(1);% x axis at the Top left corner
    % y = initstate(2);
    % w = initstate(3);% width of the rectangle
    % h = initstate(4);% height of the rectangle
    initstate(1) = x;% x axis at the Top left corner
    initstate(2) = y;
    initstate(3) = w;% width of the rectangle
    initstate(4) = h;% height of the rectangle
    centerx = x + w/2;
    centery = y + h/2;
    %---------------------------
    % img = imread(img_dir(1).name);
    if length(size(img))==3
        img = rgb2gray(img);
    end
    img = double(img);
    %% 改变亮度
    % grayscale = 0;
    % for i = x: x+w
    %     for j = y: y+h
    %         grayscale = double(img(i,j)) + grayscale;
    %     end
    % end
    % grayscale = grayscale / (w*h);
    %% 
    trparams.init_negnumtrain = 50;%number of trained negative samples
    trparams.init_postrainrad = 4;%radical scope of positive samples
    trparams.initstate = initstate;% object position [x y width height]
    trparams.srchwinsz = 25;% size of search window
    %-------------------------
    %% Classifier parameters
    clfparams.width = trparams.initstate(3);
    clfparams.height= trparams.initstate(4);
    % feature parameters
    % number of rectangle from 2 to 4.
    ftrparams.minNumRect =2;
    ftrparams.maxNumRect =4;
    M = 100;% number of all weaker classifiers, i.e,feature pool
    %-------------------------
    posx.mu = zeros(M,1);% mean of positive features
    negx.mu = zeros(M,1);
    posx.sig= ones(M,1);% variance of positive features
    negx.sig= ones(M,1);

    lRate = 0.85;% Learning rate parameter
    %% Compute feature template
    [ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);
    %% Compute sample templates
    posx.sampleImage = sampleImgDet(img,initstate,trparams.init_postrainrad,1);
    negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
    %% Feature extraction
    iH = integral(img);%Compute integral image
    posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
    negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
    [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
    %% 开始计时
    start = clock;
    %% Begin tracking
%     dximg = uint8(zeros(imgHeight, imgWidth));
    rect_handle = [];
    text_handle = [];
    frameTime = 1;
    while 1
        timee = etime(clock,start);
    %     fprintf('程序运行时间为：%3.2fs\n\n', etime(clock,start));
        start = clock;
        %% 根据上一循环给出的云台指令改变云台动作
        if strcmp(dirt, 'stop')
            PelcoD_Stop(PLZs);
            img = snapshot(cam);
            dir = dirt;
        elseif ~strcmp(dirt, dir)
            fprintf([dir,'!=',dirt]);
            dir = dirt;
            PelcoD_Stop(PLZs);
            img = snapshot(cam);
            pause(0.05);
            PelcoD_Rotate(PLZs, '00',dir);
        else
            PelcoD_Stop(PLZs);
            img = snapshot(cam);
            PelcoD_Rotate(PLZs, '00',dir);
        end
        imgSr = img;% imgSr is used for showing tracking results.

        if length(size(img))==3
            img = rgb2gray(img);
        end
%         figure(2);
%         dximg = (dximg + preframe - img)/2;
%         imshow(dximg);
%         preframe = img;
%         if mean(mean(dximg)) < 1
%             PelcoD_gotoCruisePoints( PLZs, '00', '00' );
%             pause(5);
%             break;
%         end
%         fprintf([num2str(mean(mean(dximg))), '\n']);
        img = double(img); 
        iH = integral(img);%Compute integral image
        %% Coarse detection
        step_n = 4; % coarse search step
        detectx.sampleImage = sampleImgDet(img,initstate,trparams.srchwinsz,step_n);    
        detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
        r = ratioClassifier(posx,negx,detectx.feature);% compute the classifier for all samples
        clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
        [c,index] = max(clf);
        x = detectx.sampleImage.sx(index);
        y = detectx.sampleImage.sy(index);
        w = detectx.sampleImage.sw(index);
        h = detectx.sampleImage.sh(index);
        initstate = [x y w h];
        %% Fine detection
        step_n = 1;
        detectx.sampleImage = sampleImgDet(img,initstate,10,step_n);    
        detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
        r = ratioClassifier(posx,negx,detectx.feature);% compute the classifier for all samples
        clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
        [c,index] = max(clf);
        x = detectx.sampleImage.sx(index);
        y = detectx.sampleImage.sy(index);
        w = detectx.sampleImage.sw(index);
        h = detectx.sampleImage.sh(index);
        initstate = [x y w h];
        %% Show the tracking results
%         figure(3);
        set(hImageDetect,'CData',uint8(imgSr));
        delete(rect_handle);
        delete(text_handle);
        rect_handle = rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');        
        text_handle = text(5, 18, strcat('#',num2str(frameTime)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
        frameTime = frameTime + 1;
%          
%         pause(0.00001); 
%         hold off;
        %% Extract samples 
        posx.sampleImage = sampleImgDet(img,initstate,trparams.init_postrainrad,1);
        negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
        %% Update all the features
        posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
        negx.feature = getFtrVal(iH,negx.sampleImage,ftr); 
        [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters  
        %% 更新参数
        centerx = x + w/2;
        centery = y + h/2;
        camt = camt + 1;
        camm = 1;
        if (abs(centerx - imgWidth/2) / camespx) >= (abs(centery - imgHeight/2) / (camespy))
            ax = 'x';
        else
            ax = 'y';
        end
        if strcmp(ax, 'x')
            if abs(centerx - imgWidth/2) / 50 <= 1
                camm = 3;
            end
            if abs(centerx - imgWidth/2) / 30 <= 1
                camm = 5;
            end
        elseif strcmp(ax, 'y')
            if abs(centery - imgHeight/2) / (40) <= 1
                camm = 3;
            end
            if abs(centery - imgHeight/2) / (20) <= 1
                camm = 5;
            end
        end
        %% 根据对象位置判断下一个云台指令
        dirt = 'stop';
        if camt >= camm
            if strcmp(ax, 'x')
                if centerx - imgWidth/2 >  camespx
    %                 fprintf('在右边');
                    dirt = 'left';
                elseif centerx < imgWidth/2 - camespx
    %                 fprintf('在左边');
                    dirt = 'right';
                end
            else
                if centery - imgHeight/2 <  - camespy
    %                 fprintf('在上边');
                    dirt = 'up';
                elseif centery > imgHeight/2 + camespy
    %                 fprintf('在下边');
                    dirt = 'down';
                end
            end
            camt = 0;
        end
       if strcmpi(get(gcf,'CurrentCharacter'),'n')
           break;
       end
    end
   PelcoD_Stop(PLZs);
   if strcmpi(get(gcf,'CurrentCharacter'),'e')
      break;
   end
    
end

% set(handles.state_ptr, 'value', 0);
% addTask2Queue(@(~)beginTracking(handles.state_ptr), 0.1);

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cam = handles.cam;
hImage = handles.hImage;
set(handles.state_ptr, 'value', 1);
fprintf('aaa\n');
 while(true)
     img = snapshot(cam);
     set(hImage, 'CData', uint8(img), 'CDataMapping', 'scaled', 'XData', [ 1, 640], 'YData', [1, 480]); %XData、YData设置显示的大小
     pause(0.1);
 end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
while 1
    
end


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function beginTracking(state_ptr)
    while 1
        fprintf('aaa\n');
        pause(0.1);
        if get(state_ptr,'value') == 1
            break;
        end
    end
