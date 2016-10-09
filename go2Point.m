function  go2Point( s, add, dx, dy )
%go2Point �����ת����ĳһ����
%   s ��MATLAB��serial port object
%   add �������ַ�����ַ�����ʾ
%   dx �����ˮƽ��תʱ�䣬����Ϊ��λ��ֵΪ��ʱ��ʱ����ת
%   dy �������ֱ��תʱ�䣬����Ϊ��λ��ֵΪ��ʱ����ת��
    if dx > 0
        dirx = 'right';
    else
        dirx = 'left';
    end
    
    if dy > 0
        diry = 'up';
    else
        diry = 'down';
    end
    
    if abs(dy) > abs(dx)
        period_1 = abs(dx);
        period_2 = abs(dy) - abs(dx);
        dir_l = diry;
    else
        if abs(dy) == abs(dx)
            period_1 = abs(dy);
            period_2 = 0;
            dir_l = dirx;
        else
            period_1 = abs(dy);
            period_2 = abs(dx) - abs(dy);
            dir_l = dirx;
        end
    end
    if period_1 >= 0.2
        addTask2Queue(s, add, @(~,~)PelcoD_Rotate( s, add, dirx, 'ff', diry, 'ff' ), period_1 );
    end
    if period_2 >= 0.2
        addTask2Queue(s, add, @(~,~)PelcoD_Rotate(s,add, dir_l),period_2);
    end

end

