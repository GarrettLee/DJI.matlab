function [s] = getOpenedPort(com, baudrate)
%getOpenedPort 得到一个已经打开的MATLAB serial port object
%   com 选择com口，用字符串形式表示
%   baudrate 选择波特率
ins = instrfind('Port', upper(com));
[m, n] = size(ins);
for i = 1:n
    if strcmp(get(ins(i), 'Status'), 'open')
        fprintf('\n无可用串口，返回此前已经打开的串口\n');
        s = ins(i);
        s.baudrate = baudrate;
        return ;
    end
end;
s1 = serial(com, 'Baudrate', baudrate );
fopen(s1);
s = s1;