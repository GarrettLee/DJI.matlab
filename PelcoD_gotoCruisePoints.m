function  PelcoD_gotoCruisePoints( s, index, add )
%PelcoD_gotoCruisePoints �����ת����Ѳ����
%   s ��MATLAB��serial port object
%   index Ѳ������ţ����ַ�����ʾ
%   add �������ַ�����ַ�����ʾ
if nargin < 3
    add = '00';
end

PelcoD_Stop(s,add);
pause(1.5);
PelcoD_Cmd(s, add, '00', '07', '00', index);
pause(1.5);
end

