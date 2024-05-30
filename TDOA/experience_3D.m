
%  阵元方案一
% nbs = 7;  % 传感器数量
% d = 250;
% m = 200; 
% BS1 = [0, 0, 0];
% BS2 = [d , 0, d];
% BS3 = [-d/2, -sqrt(3)/2 * d , d];
% BS4 = [-d/2, sqrt(3)/2 * d , d];
% BS5 = [-d ,  0, -d];
% BS6 = [d/2, -sqrt(3)/2 * d, -d];
% BS7 = [d/2, sqrt(3)/2 * d, -d];
% baseStation = [BS1;BS2;BS3;BS4;BS5;BS6;BS7];

% 阵元方案二
% nbs = 5;  % 传感器数量
% baseStation = [0,0,0;
%                0,500,0;
%                0,0,500;
%                500,0,0
%                100,100,100];

% 阵元方案三
nbs = 8;  % 传感器数量
baseStation = [0,0,0;  % 1
               150,0,0; % 2
               0,150,0; % 3
               150,150,0; % 4
               0,0,150; % 5
               150,0,150; % 6
               150,150,150; % 7
               0,150,150]; % 8


% 以下为纯仿真中，得到TDOA的部分
% wn = 0; % 噪声强度
% c = 343200; % 声速
% MS = [0, 500 , 100];  %目标位置
% for i = 1: nbs
%     R0(i) = sqrt((baseStation(i,1) - MS(1))^2 + (baseStation(i,2) - MS(2))^2 + (baseStation(i,3) - MS(3))^2); 
% end
% for i = 1: nbs
%     d(i) = (R0(i) - R0(1) + wn * randn(1))/c; 
%     % 模拟时间差
% end
% 以上为纯仿真中，得到TDOA的部分

% 以下为实测TDOA的部分
% shoot;
wn = 0;
% 镗口波定位
d = [0,delaytime(2),delaytime(3),delaytime(4),delaytime(5),delaytime(6),delaytime(7),delaytime(8)];
zp = EXP_Chan_3D(nbs,baseStation,wn,d);
fprintf('x = %.4f, y = %.4f,z = %.4f\n',zp(1),zp(2),zp(3));


