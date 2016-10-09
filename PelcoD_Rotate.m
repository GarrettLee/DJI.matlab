function PelcoD_Rotate( s, add, direction1, speed1, direction2, speed2 )
%PelcoD_Rotate ��������ݲ���ת��
%   s ��MATLAB��serial port object
%   add �������ַ�����ַ�����ʾ
%   direction1 ����1������Ϊ'up'��'down'
%   speed1 direction1�����ϵ�ת���ٶȣ�Ӳ����֧�֣�
%   direction2 ����2������Ϊ'left'��'right'
%   speed2 direction2�����ϵ�ת���ٶȣ�Ӳ����֧�֣�

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

