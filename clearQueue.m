function clearQueue(  )
%clearQueue ������������е�����
%   ���������ִ����Ŀǰ�������ֹͣ
    timerArray = timerfind('Name', 'timer-cam');
    if isempty(timerArray)
        fprintf('û�д򿪶��У��޷����');
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

