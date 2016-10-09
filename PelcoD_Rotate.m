function PelcoD_Rotate( s, add, direction1, speed1, direction2, speed2 )
%PelcoD_Rotate 摄像机根据参数转动
%   s 是MATLAB的serial port object
%   add 摄像机地址，用字符串表示
%   direction1 方向1，可以为'up'，'down'
%   speed1 direction1方向上的转动速度（硬件不支持）
%   direction2 方向2，可以为'left'，'right'
%   speed2 direction2方向上的转动速度（硬件不支持）

if nargin == 3
    speed1 = 'ff';
end
PelcoD_Stop(s,add);
switch lower(direction1)
    case 'left'
        PelcoD_Cmd(s, add, '00', '04', speed1, '00');
    case 'right'
        PelcoD_Cmd(s, add, '00', '02', speed1, '00');
    case 'up'
        PelcoD_Cmd(s, add, '00', '08', '00', speed1);
    case 'down'
        PelcoD_Cmd(s, add, '00', '10', '00', speed1);
end
if nargin == 6
    switch lower(direction2)
        case 'left'
            PelcoD_Cmd(s, add, '00', '04', speed2, '00');
        case 'right'
            PelcoD_Cmd(s, add, '00', '02', speed2, '00');
        case 'up'
            PelcoD_Cmd(s, add, '00', '08', '00', speed2);
        case 'down'
            PelcoD_Cmd(s, add, '00', '10', '00', speed2);
    end
end
end

