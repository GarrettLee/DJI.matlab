function PelcoD_setCruisePoints( s, index, add )
%PelcoD_setCruisePoints 设置摄像机当前位置为巡航点
%   s 是MATLAB的serial port object
%   index 巡航点序号，用字符串表示
%   add 摄像机地址，用字符串表示
if nargin < 3
    add = '00';
end

 PelcoD_Cmd(s, add, '00', '03', '00', index);

end

