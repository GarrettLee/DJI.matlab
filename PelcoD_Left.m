function PelcoD_Left(  s, add, speed ,stoptime)
%PelcoD_Left 摄像机想左转动,add为地址
    if nargin < 4
        stoptime = 0.1;
    end
    if nargin < 3 
        speed = 'ff';
        if nargin < 2
            add = '00';
        end
    end
    %发送停止命令，因为如果摄像机正在向右转动时发送向左转动的命令会使它出错
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

