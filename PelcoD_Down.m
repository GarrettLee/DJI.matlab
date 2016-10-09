function PelcoD_Down(  s, add, speed ,stoptime)
%PelcoD_Down 摄像机向下转动
    if nargin < 3 
        speed = 'ff';
        if nargin < 2
            add = '00';
        end
    end
    PelcoD_Stop(s,add);
    PelcoD_Cmd(s, add, '00', '10', '00', speed);
    if nargin >= 4
        t = timer('StartDelay', stoptime);
        t.TimerFcn = @(x,y)PelcoD_Stop(s,add);
        t.StopFcn = @(x,y)delete(t) ;
        t.ErrorFcn = @(x,y)delete(t) ;
        start(t);
    end
end