function PelcoD_deleteCruisePoints( s, index, add )
%PelcoD_deleteCruisePoints ɾ��Ѳ����
%   s ��MATLAB��serial port object
%   index Ѳ������ţ����ַ�����ʾ
%   add �������ַ�����ַ�����ʾ
if nargin < 3
    add = '00';
end

PelcoD_Cmd(s, add, '00', '05', '00', index);

end

