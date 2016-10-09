function  PelcoD_gotoCruisePoints( s, index, add )
%PelcoD_gotoCruisePoints 摄像机转动到巡航点
%   s 是MATLAB的serial port object
%   index 巡航点序号，用字符串表示
%   add 摄像机地址，用字符串表示
if nargin < 3
    add = '00';
end

PelcoD_Stop(s,add);
pause(1.5);
PelcoD_Cmd(s, add, '00', '07', '00', index);
pause(1.5);
end

