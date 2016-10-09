function PelcoD_Cmd(s, add, commandcode1, commandcode2, datacode1, datacode2)
%add和speed均用十六进制字符串输入
n_add  = hex2dec(add);
n_commandcode1 = hex2dec(commandcode1);
n_commandcode2 = hex2dec(commandcode2);
n_datacode1 = hex2dec(datacode1);
n_datacode2 = hex2dec(datacode2);

%等待数据完整发送
% pause(0.2);
check = mod( n_add + n_commandcode1 + n_commandcode2 + n_datacode1 + n_datacode2 , 256);
cmd = [255 n_add n_commandcode1 n_commandcode2 n_datacode1 n_datacode2 check];
fwrite(s, cmd);