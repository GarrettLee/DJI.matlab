function PelcoD_Stop(s, add )
%PelcoD_Stop 摄像机停止命令
if nargin == 1
    add = '00';
end


n_add  = hex2dec(add);

%等待数据完整发送
% pause(0.11);
check = mod( n_add , 256);
cmd = [255 n_add 0 0 0 0 check];
fwrite(s, cmd);
end

