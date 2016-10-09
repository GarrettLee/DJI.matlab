function addTask2PLZQueue(s,add, task, period )
%addTask2Queue ����������������������������
%  s ��MATLAB��serial port object
%  task �Ǹ���������ӵ�����Ϊһ�����������������PelcoD��ͷ�ĺ���
%  add �������ַ�����ַ�����ʾ
%  period �������ִ��task��ʱ�䣬����Ϊ��λ������Task��ʲô��period�����һ��ֹͣ����������


% ��Ϊ��PelcoD_Cmd��ÿ������Ҫ�ȴ�0.11�룬���������ﲹ������
period = period + 0.11;

%Ѱ�Ҽ�ʱ���Ƿ��Ѿ������ˣ������û�����ʹ���һ��
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
    t.Tag = 'available';%�����״̬����
 else
     t = timerArray(1);
 end
data = t.UserData;
handles = data{1};
periods = data{2};
handles{length(handles)+1} = task;%�����񱣴�����
periods{length(periods)+1} = period;

t.UserData = {handles, periods};

if ~strcmp(t.Tag, 'busy')
    t.StartDelay = period;
    t.Tag = 'busy';%�����״̬æµ
    start(t);
end
end

%��ʱ��t��ʼ���������Ϸ�����������������
function Start_call_back(t)
    data = t.UserData;
    handles = data{1};
    periods = data{2};
    feval(handles{1});
    
    %��ִ�й�������ɾ����
    handles = handles(2:length(handles));
    periods = periods(2:length(periods));
    data = {handles, periods};
    t.UserData = data;
end

%������period��󣬷���һ��ֹͣ����
function Timer_call_back(t,add,s)
    PelcoD_Stop(s,add);
end

%�˳���ʱ��֮ǰ������������������Ƿ��еȴ�ִ�е�����������еĻ��ͼ���ִ��
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