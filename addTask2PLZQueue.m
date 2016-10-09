function addTask2PLZQueue(s,add, task, period )
%addTask2Queue 给在摄像机的任务队列中增加任务
%  s 是MATLAB的serial port object
%  task 是给摄像机增加的任务，为一个函数句柄，可以是PelcoD开头的函数
%  add 摄像机地址，用字符串表示
%  period 是摄像机执行task的时间，以秒为单位，无论Task是什么，period秒后发送一个停止命令给摄像机


% 因为在PelcoD_Cmd中每次任务都要等待0.11秒，所以在这里补偿回来
period = period + 0.11;

%寻找计时器是否已经创建了，如果还没创建就创建一个
timerArray = timerfind('Name', 'timer-cam');
if isempty(timerArray)
    t = timer('Name','timer-cam','TasksToExecute',1,'Period',0.001,'BusyMode','queue');
    t1 = {};
    t2 = {};
    t.UserData ={ t1, t2};
    t.TimerFcn = @(~,~)Timer_call_back(t,add,s);
    t.StartFcn = @(~,~)Start_call_back(t);
    t.StopFcn = @(~,~)Stop_call_back3(t);
    t.ErrorFcn = @(~,~)delete(t);
    t.Tag = 'available';%摄像机状态空闲
 else
     t = timerArray(1);
 end
data = t.UserData;
handles = data{1};
periods = data{2};
handles{length(handles)+1} = task;%把任务保存起来
periods{length(periods)+1} = period;

t.UserData = {handles, periods};

if ~strcmp(t.Tag, 'busy')
    t.StartDelay = period;
    t.Tag = 'busy';%摄像机状态忙碌
    start(t);
end
end

%定时器t开始工作，马上发送任务命令给摄像机
function Start_call_back(t)
    data = t.UserData;
    handles = data{1};
    periods = data{2};
    feval(handles{1});
    
    %把执行过的任务删除掉
    handles = handles(2:length(handles));
    periods = periods(2:length(periods));
    data = {handles, periods};
    t.UserData = data;
end

%经过了period秒后，发送一个停止命令
function Timer_call_back(t,add,s)
    PelcoD_Stop(s,add);
end

%退出定时器之前，检查是任务序列中是否还有等待执行的任务，如果还有的话就继续执行
function Stop_call_back3(t)
    data = t.UserData;
    handles = data{1};
    periods = data{2};
    if(~isempty(handles))
        t.StartDelay =periods{1};
        start(t);
    else
        t.Tag = 'available';
    end
end