function [  ] = sendCmd( s, type, val )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    cmd = [ 0, 1, 3, 1, 0, 0, 0, 1, 0, 0];
    cmd = uint8(cmd);
    switch type
		case 'down'
			cmd(4) = 1;
			cmd(8) = bitand(val, 255);
			fprintf('��');
		case 'up'
			cmd(4) = 1;
			cmd(8) = bitand(val, 255);
			fprintf('��');
		case 'left roll'
			cmd(4) = 4;
			cmd(5) = 255;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('����');
		case 'right roll'
			cmd(4) = 4;
			cmd(5) = 1;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('����');
		case 'forward'
			cmd(4) = 2;
			cmd(5) = 1;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('��');
		case 'backward'
			cmd(4) = 2;
			cmd(5) = 255;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('��');
		case 'left'
			cmd(4) = 3;
			cmd(5) = 255;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('��');
		case 'right'
			cmd(4) = 3;
			cmd(5) = 1;
			cmd(6) = bitand(val, 255);
			cmd(7) = bitshift(val,-8);
			fprintf('��');
		case 'gimbal up'
			cmd(4) = 5;
			cmd(5) = 2555;
			cmd(9) = bitand(val, 255);
			cmd(10) = bitshift(val,-8);
			fprintf('��̨����');
		case 'gimbal down'
			cmd(4) = 5;
			cmd(5) = 1;
			cmd(9) = bitand(val, 255);
			cmd(10) = bitshift(val,-8);
			fprintf('��̨����');
		case 'gimbal stop'
			cmd(4) = 5;
			cmd(5) = 1;
			cmd(9) = 0;
			cmd(10) = 0;
			fprintf('��ֹ̨ͣ');
    end
    org.garrett.javatoolformatlab.SocketUtil.wrightBytes2Stream(cmd,s);

end

