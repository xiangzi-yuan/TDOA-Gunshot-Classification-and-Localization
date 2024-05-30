clc; clear;

% 阵元方案一
nbs = 7;  % 传感器数量
d = 250;
m = 20000; 
BS1 = [0, 0, 0];
BS2 = [d , 0, d];
BS3 = [-d/2, -sqrt(3)/2 * d , d];
BS4 = [-d/2, sqrt(3)/2 * d , d];
BS5 = [-d ,  0, -d];
BS6 = [d/2, -sqrt(3)/2 * d, -d];
BS7 = [d/2, sqrt(3)/2 * d, -d];
baseStation = [BS1;BS2;BS3;BS4;BS5;BS6;BS7];

% 阵元方案二
% nbs = 5;  % 传感器数量
% baseStation = [0,0,0;
%                0,500,0;
%                0,0,500;
%                500,0,0
%                100,100,100];

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

c = 343200; % 声速
MS = [50000, 55000 , 10000];  %目标位置
class = 24; % 从-20到+3，共24个等级
num_experiments = 1000; % 蒙特卡洛实验次数
RMSE_chan = zeros(class, 1); % 存储每个噪声数量级的平均RMSE
RMSE = zeros(class, 1); % 存储每个噪声数量级的平均RMSE
d = zeros(1,nbs);
R0 = zeros(1,nbs);
zp1 = zeros(class,3);
zp = zeros(class,3);

for i = 1: nbs
    R0(i) = sqrt((baseStation(i,1) - MS(1))^2 + (baseStation(i,2) - MS(2))^2 + (baseStation(i,3) - MS(3))^2); 
end

for i = 1:class
    k = -20 + (i-1); % 从-20到+3，每次增加1
    % 以下为纯仿真中，得到TDOA的部分
    magnitude = 2^(k);
    rmse_sum = 0; % 最小二乘法累加每次实验的RMSE
    rmse_sum_chan = 0; % 用于累加每次实验的RMSE
    for exp = 1:num_experiments
        for j = 1: nbs
            wn = magnitude * randn;
            d(j) = (R0(j) - R0(1))/c + wn ;  % 单位: s
            % 模拟时间差
        end
        zp0 = Chan_3D(nbs,baseStation,wn,d);
        zp1(i,1) = zp0(1,1);
        zp1(i,2) = zp0(1,2);
        zp1(i,3) = zp0(1,3);
        zp(i,1) = zp0(2,1);
        zp(i,2) = zp0(2,2);
        zp(i,3) = zp0(2,3);
    
        RMSE_current = sqrt(mean((zp1(i, :) - MS).^2));  % 最小二乘
        RMSE_current_chan = sqrt(mean((zp(i, :) - MS).^2));
        rmse_sum_chan = rmse_sum_chan + RMSE_current_chan;
        rmse_sum = rmse_sum + RMSE_current;
    end
    RMSE_chan(i) = rmse_sum_chan / num_experiments;
    RMSE(i) = rmse_sum / num_experiments;
end

% 绘制误差数量级i与RMSE的图
figure;

plot(-20:3, RMSE_chan/10^6,'k');
hold on
plot(-20:3, RMSE/10^6,'m');
xlabel('噪声数量级 i');
ylabel('平均RMSE(mm)');
title('噪声数量级与平均RMSE的关系');
legend('Chan算法估计', '最小二乘法估计');
grid on;

disp('RMSE:');
disp(sum(RMSE_chan)/class);
disp(sum(RMSE)/class);
