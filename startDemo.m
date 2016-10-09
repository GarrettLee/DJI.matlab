
clc;clear; close all;
require_cmd = [0, 1, 4, 0, 0, 0, 0, 0, 0, 0];
%% 动态初始化Java的Jar包路径
javaDynamicPathInitail();

%% 例程：通过在MATLAB中调用java的类来实现MATLAB和安卓/Java的TCP/IP通信
% 
cmd = '请求长连接';
serverSocketF = javaObject('java.net.ServerSocket',30004);                   % Java代码 -> ServerSocket ss = new ServerSocket(30000);
try
    socketF = serverSocketF.accept();                                             % Java代码 -> Socket s = ss.accept();
    os = socketF.getOutputStream();                                              % Java代码 -> OutputStream os = s.getOutputStream();
%     hAxes = subplot(1,1,1);
%     hImage = imshow(uint8(rand(320, 640)),'Parent',hAxes);
    inF = socketF.getInputStream;
%     sendCmd(os, 'gimbal down', 1000);
%     while(1)
%         start = clock;
%         bsF = [];
%         bsF = double(bsF);
%         while isempty(bsF)
%             bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
% %                  bsF = org.garrett.javatoolformatlab.SocketUtil.readXBytes(inF, 614400);
%         end
%         fprintf('程序运行时间为：%3.2fs\n\n', etime(clock,start));
%         gray = reshape(bsF, 640, 320)';
%         set(hImage,'CData',uint8(gray));
%         drawnow;
% %         start = clock;
% %         b = reshape(bsF, 3, 204800)';
% %         r = b(:,1);
% %         g = b(:,2);
% %         bb = b(:,3);
% %         r = reshape(r, 640, 320)';
% %         g = reshape(g, 640, 320)';
% %         bb = reshape(bb, 640, 320)';
% %         clear rgb
% %         rgb(:,:,1) = r;
% %         rgb(:,:,2) = g;
% %         rgb(:,:,3) = bb;
% %         rgb = uint8(rgb);
% % %             imshow(rgb);
% %         set(hImage,'CData',rgb);
% %         drawnow;
% %         fprintf('显示图片的时间为：%3.2fs\n\n', etime(clock,start));
%     end
    % Demo for paper "Fast Compressive Tracking,"Kaihua Zhang, Lei Zhang, and Ming-Hsuan Yang
% Submitted to TPAMI. 
% Implemented by Kaihua Zhang, Dept.of Computing, HK PolyU.
% Email: zhkhua@gmail.com
% Date: 11/12/2011
% Revised by Kaihua Zhang, 15/12/2011
% Revised by Kaihua Zhang, 11/7/2012
% Revised by Kaihua Zhang, 26/10/2012
% Revised by Kaihua Zhang, 7/1/2013
rand('state',0);

preframe = [];
%% Select video sequences   
ImgFlag =1%1,david,2,tiger2,3,sylvester,4,twinnings,5,cliffbar...
%% 
% [ImgFileName,initstate] = initCt(ImgFlag);%initial tracker
% %%Set path
% pathName = strcat('.\data\',ImgFileName);
% addpath(pathName,strcat(pathName,'\imgs'));
% fpath = fullfile(strcat(pathName,'\imgs'),'*.png');
% addpath(pathName);
% img_dir = dir(fpath);
% num = length(img_dir);% number of frames
%%
faceDetector = vision.CascadeObjectDetector();
while 1
       bsF = [];
%         org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream([0, 3, 1],os);
%            bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
         
              bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
              
        
        if bsF(1) == 0 && bsF(2) == 3 && bsF(3) == 2
            x = getIntFromByte(bsF(4), bsF(5) , bsF (6));
            y = getIntFromByte(bsF(7), bsF(8) , bsF (9));
            w = getIntFromByte(bsF(10), bsF(11) , bsF (12));
            h = getIntFromByte(bsF(13), bsF(14) , bsF (15));
            break;
        end
    end

start = clock;

while true
    
    bsF = [];
    org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(require_cmd,os);

    while isempty(bsF)
        bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
%                  bsF = org.garrett.javatoolformatlab.SocketUtil.readXBytes(inF, 614400);
    end
    img = uint8(reshape(bsF, 640, 320)');
    imgSize = size(img);
    imgHeight = imgSize(1);
    imgWidth = imgSize(2);
%      [x, y, w, h] = getRectFromMouse();
%     bbox = step(faceDetector, img);
%     [rows, ~] = size(bbox);
%     if rows == 0
%         continue;
%     end
%     x = bbox(1);
%     y = bbox(2);
%     w = bbox(3);
%     h = bbox(4);
    % [x, y, w, h] = getRectFromMouse();
%     while (x <= 0)||(x >= imgWidth)||(y <= 0)||(y>=imgHeight)||(h == 0)||(w == 0)
%         [x, y, w, h] = getRectFromMouse();
%     end
    preframe = img;
    camespx = w / 8;
    camespy = h / 8;
   
    initstate(1) = x;% x axis at the Top left corner
    initstate(2) = y;
    initstate(3) = w;% width of the rectangle
    initstate(4) = h;% height of the rectangle
     initstate = double( initstate);
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
    dximg = uint8(zeros(imgHeight, imgWidth));
    dirt = 'gimbal stop';
    dir = 'null';
    camt = 0;
    rect_handle = [];
    speed = 200;
    all_control = [];
    all_error = [];
    phase = 0;
    for loop_time = 1:1000 
        %% 根据上一循环给出的云台指令改变云台动作
%           sendCmd(os, dirt, speed);
            loop_start = clock;

        org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(require_cmd,os);

        bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
        
        img = reshape(bsF, 640, 320)';
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
        rect = [0, 1, 6, ...
                1, double(bitand(x, 255)), double(bitshift(x,-8)),...
                1, double(bitand(y, 255)), double(bitshift(y,-8)),...
                1, double(bitand(w, 255)), double(bitshift(w,-8)),...
                1, double(bitand(h, 255)), double(bitshift(h,-8))];
        org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(rect,os);
        %% Show the tracking results
%         figure(1);
%         set(hImage,'CData',uint8(img));
%         delete(rect_handle)
%         rect_handle = rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
%         hold on;
%         text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
%         set(gca,'position',[0 0 1 1]); 
%         pause(0.00001); 
%         hold off;
        %% Extract samples 
        posx.sampleImage = sampleImgDet(img,initstate,trparams.init_postrainrad,1);
        negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
        %% Update all the features
        posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
        negx.feature = getFtrVal(iH,negx.sampleImage,ftr); 
        [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters  
%       更新坐标
        centerx = x + w/2;
        centery = y + h/2;
        camt = camt + 1;
        camm = 1;
        if (abs(centerx - imgWidth/2) / camespx) >= (abs(centery - imgHeight/2) / (camespy))
            ax = 'x';
            speed = 200;
        else
            ax = 'y';
            sspeed = 300;
        end
        
        
        ax = 'y'  %因为目前x轴无法调整，所以全部相应y轴
        if strcmp(ax, 'x')
            if abs(centerx - imgWidth/2) / 200 <= 1
                speed = 100
            end
            if abs(centerx - imgWidth/2) / 100 <= 1
                camm = 50;
            end
        elseif strcmp(ax, 'y')
            if abs(centery - imgHeight/2) / (40) <= 1
                speed = 100
            end
            if abs(centery - imgHeight/2) / (20) <= 1
                camm = 50;
            end
        end
        %% 根据对象位置判断下一个云台指令
        dirt = 'gimbal stop';
        if camt >= camm
            if strcmp(ax, 'x')
                if centerx - imgWidth/2 >  camespx
%                     fprintf('在右边');
                     dirt = 'right roll';
                elseif centerx < imgWidth/2 - camespx
%                     fprintf('在左边');
                     dirt = 'left roll';
                end
            else
                if centery - imgHeight/2 <  - camespy
    %                 fprintf('在上边');
                    dirt = 'gimbal up';
                elseif centery > imgHeight/2 + camespy
    %                 fprintf('在下边');
                    dirt = 'gimbal down';
                end
            end
            camt = 0;
        end
        
%       要点！！！不是控制间隔越短越好的！！要保证控制间隔是采样间隔的一定倍数
%       猜想：如果目标追踪速度可以快上很多的话，只要保证控制间隔是采样间隔的十倍，是不是就可以使得控制非常快了呢？
%       大概每隔0.2秒控制一次
        if etime(clock,start) >= 0.6
            phase  = phase + 1;
            start = clock;
            error_y = int32(centery - imgHeight/2);
            character = 1;
            if error_y > 0

            else
                character = 255;
                error_y = int32(-error_y);
            end

            out_y = [0, 1, 5, character, double(bitand(error_y, 255)), double(bitshift(error_y,-8))];
            org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(out_y,os);
            bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);


            if bsF(4) == 255
                chara = -1;
            else 
                chara = 1;
            end
            all_control(phase+1) = (bsF(5) + bsF(6) * 2^8)*chara;
            all_error(phase) = error_y;
            
            error_x = int32(centerx - imgWidth/2);
            character = 1;
            if error_x > 0

            else
                character = 255;
                error_x = int32(-error_x);
            end

            out_x = [0, 1, 7, character, double(bitand(error_x, 255)), double(bitshift(error_x,-8))];
            org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(out_x,os);
            bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
            
        end
%         org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream([0, 3, 1],os);
%         bsF = org.garrett.javatoolformatlab.SocketUtil.readIntFromStream(inF);
%         if bsF(1) == 0 && bsF(2) == 3 && bsF(3) == 2
%             x = getIntFromByte(bsF(4), bsF(5) , bsF (6));
%             y = getIntFromByte(bsF(7), bsF(8) , bsF (9));
%             w = getIntFromByte(bsF(10), bsF(11) , bsF (12));
%             h = getIntFromByte(bsF(13), bsF(14) , bsF (15));
%             break;
%         end
        fprintf('程序运行时间为：%3.2fs\n\n', etime(clock,loop_start));
       if strcmpi(get(gcf,'CurrentCharacter'),'e')
           set(gcf, 'CurrentCharacter', ' ');
           delete(rect_handle)
           break;
       end
    end
    
    figure(3);
    plot(all_control);
%     if strcmpi(get(gcf,'CurrentCharacter'),'e')
%        break;
%     end
    
end
    
catch ME
    fprintf([ME.message]);
    socketF.close();
    serverSocketF.close();                                                       % Java代码 -> ss.close();
end

