function clearQueue(  )
%clearQueue 清除任务序列中的任务
%   摄像机将在执行完目前的任务后停止
    timerArray = timerfind('Name', 'timer-cam');
    if isempty(timerArray)
        fprintf('没有打开队列，无法清除');
        return;
    else
        data = timerArray(1).UserData;
        handles = data{1};
                                               = data{2};
        handles = {};
        periods = {};
        timerArray(1).UserData = {handles, periods};
    end
end

