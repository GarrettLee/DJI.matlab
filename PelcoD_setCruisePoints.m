function PelcoD_setCruisePoints( s, index, add )
%PelcoD_setCruisePoints �����������ǰλ��ΪѲ����
%   s ��MATLAB��serial port object
%   index Ѳ������ţ����ַ�����ʾ
%   add �������ַ�����ַ�����ʾ
if nargin < 3
    add = '00';
end

 PelcoD_Cmd(s, add, '00', '03', '00', index);

end

