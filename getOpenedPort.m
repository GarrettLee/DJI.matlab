function [s] = getOpenedPort(com, baudrate)
%getOpenedPort �õ�һ���Ѿ��򿪵�MATLAB serial port object
%   com ѡ��com�ڣ����ַ�����ʽ��ʾ
%   baudrate ѡ������
ins = instrfind('Port', upper(com));
[m, n] = size(ins);
for i = 1:n
    if strcmp(get(ins(i), 'Status'), 'open')
        fprintf('\n�޿��ô��ڣ����ش�ǰ�Ѿ��򿪵Ĵ���\n');
        s = ins(i);
        s.baudrate = baudrate;
        return ;
    end
end;
s1 = serial(com, 'Baudrate', baudrate );
fopen(s1);
s = s1;