function PelcoD_Left(  s, add, speed ,stoptime)
%PelcoD_Left ���������ת��,addΪ��ַ
    if nargin < 4
        stoptime = 0.1;
    end
    if nargin < 3 
        speed = 'ff';
        if nargin < 2
            add = '00';
        end
    end
    %����ֹͣ�����Ϊ����������������ת��ʱ��������ת���������ʹ������
    PelcoD_Stop(s,add);
    PelcoD_Cmd(s, add, '00', '04', speed, speed);
    if nargin >= 4
        t = timer('StartDelay', stoptime);
        t.TimerFcn = @(x,y)PelcoD_Stop(s,add);
        t.StopFcn = @(x,y)delete(t) ;
        t.ErrorFcn = @(x,y)delete(t) ;
        start(t);
    end
end

