clc;clear;
tic;
%  阵元方案一
% nbs = 5;  % 传感器数量
% baseStation = [0,0,0;
%                0,500,0;
%                0,0,500;
%                500,0,0
%                100,100,100];

% 阵元方案二
nbs = 7;  % 传感器数量
d = 250; 
BS1 = [0, 0, 0];
BS2 = [d , 0, d];
BS3 = [-d/2, -sqrt(3)/2 * d , d];
BS4 = [-d/2, sqrt(3)/2 * d , d];
BS5 = [-d ,  0, -d];
BS6 = [d/2, -sqrt(3)/2 * d, -d];
BS7 = [d/2, sqrt(3)/2 * d, -d];
baseStation = [BS1;BS2;BS3;BS4;BS5;BS6;BS7];


% 阵元方案三
% nbs = 8;  % 传感器数量
% baseStation = [0,0,0;
%                0,150,0;
%                150,0,0;
%                150,150,0;
%                0,0,150;
%                150,0,150;
%                150,150,150;
%                0,150,150];


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
shoot;
wn = 0;
% 镗口波定位
d = TDOA;
Muzzleblast_zp = EXP_Chan_3D(nbs,baseStation,wn,d);
fprintf('镗口波定位x = %.4f, y = %.4f,z = %.4f\n',Muzzleblast_zp(1),Muzzleblast_zp(2),Muzzleblast_zp(3));
figure(1);  % 激活图形窗口
hold on;
scatter3(Muzzleblast_zp(1), Muzzleblast_zp(2), Muzzleblast_zp(3), 20, 'r', 'filled', ...
         'MarkerEdgeColor', 'r', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);

Machwave_zp = zeros(size(sensor_times_Machwave,1),3);
% 马赫波定位
for i = 1:size(TDOA_machwave,1)
    d = TDOA_machwave(i,:);
    Machwave_zp(i,:) = EXP_Chan_3D(nbs,baseStation,wn,d);
    if ~isnan(Machwave_zp(i,1)) && ~isnan(Machwave_zp(i,2)) && ~isnan(Machwave_zp(i,3))
        fprintf('马赫波定位轨迹x = %.4f, y = %.4f,z = %.4f\n',Machwave_zp(i,1),Machwave_zp(i,2),Machwave_zp(i,3));
    end
end

figure(1);  % 激活图形窗口
hold on; 

N = size(Machwave_zp, 1);  

for i = 1:N
    x0 = Machwave_zp(i, 1);  % X坐标
    y0 = Machwave_zp(i, 2);  % Y坐标
    z0 = Machwave_zp(i, 3);  % Z坐标
    if ~isnan(x0) && ~isnan(y0) && ~isnan(z0)
        plot3(x0, y0, z0, 'o');    
    end
end


elapsed_time = toc;
disp(['运行时间: ', num2str(elapsed_time), ' 秒']);


