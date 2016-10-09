 s = getOpenedPort('com4',9600);
 addTask2PLZQueue(s, '00',@(~,~)PelcoD_gotoCruisePoints(s,'01','00'), 1);
