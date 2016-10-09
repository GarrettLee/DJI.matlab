function [ImgFileName,initstate] = initCt(ImgFlag)
% ImgFileName is the file name storing the video sequences. 
% initstate = [x y w h]; x is the left top x axis, y is the left top y axis
% of the rectangle; w is the width of the rectangle and h is height of the
% rectangle
% Author: Kaihua Zhang
% Email: zhkhua@gmail.com
% Revised date: 10/12/2011

switch ImgFlag
    case 1
        ImgFileName = 'david'
        initstate = [120 55 75 95];
    case 2
        ImgFileName = 'tiger2'
        initstate = [16,30,34,39];
    case 3
        ImgFileName = 'sylv'
        initstate = [121,58,51,50];
    case 4
        ImgFileName = 'twinings'
        initstate = [126,165,73,53];
    case 5
        ImgFileName = 'cliffbar'
        initstate = [138,120,38,59];
    case 6
        ImgFileName = 'faceocc2'
        initstate = [112,49,92,116]; 
    case 7
        ImgFileName = 'tiger1'
        initstate = [116,44,38,42];
    case 8
        ImgFileName = 'dollar'
        initstate = [142,62,62,98];  
    case 9
         ImgFileName = 'panda'%1000
         initstate = [52,95,29,39]; 
    case 10
        ImgFileName = 'animal'% 
        initstate = [300 5 100 70];
    case 11 % very good 
        ImgFileName = 'shaking1'%
        initstate = [225 135 60 70];
    case 12
        ImgFileName = 'shaking2'
        initstate = [272,54,89,108];
    case 13
        ImgFileName = 'biker'
        initstate = [365,72,39,39];
    case 14
        ImgFileName = 'darkcar'
        initstate = [80,126,32,28];
    case 15
        ImgFileName = 'football'
        initstate = [305,100,40,40];
    case 16
        ImgFileName = 'skating1'
        initstate = [162,170,35,100];
    case 17
        ImgFileName = 'bolt'
        initstate  = [269 75 34 64]; 
    case 18
        ImgFileName = 'goat'
        initstate = [56 109 75 42];
    case 19
        ImgFileName = 'pedestrian'
        initstate = [134 160 12 30];
    case 20
        ImgFileName = 'chasing'
        initstate = [100 143 47 43];
    %-------------------------------
%     case 21
%         ImgFileName = 'biker2'
%         initstate = [14 154 67 151];
%     case 22
%         ImgFileName = 'singer'
%         initstate = [65 65 70 270];
end