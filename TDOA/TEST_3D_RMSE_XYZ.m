clc; clear;

% 阵元方案一
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

c = 343200; % 声速
num_experiments = 10; % 蒙特卡洛实验次数

% 设置定位点范围
[x_range, y_range, z_range] = meshgrid(-1000000:200000:1000000, -1000000:200000:1000000, -1000000:200000:1000000);
points = [x_range(:), y_range(:), z_range(:)];

% 预分配误差存储
RMSE = zeros(size(points, 1), 1);
RMSE_chan = zeros(size(points, 1), 1);
zp1_all = zeros(size(points, 1), 3);
zp_all = zeros(size(points, 1), 3);

for idx = 1:size(points, 1)
    MS = points(idx, :);  % 目标位置
    R0 = zeros(1, nbs);
    d = zeros(1, nbs);
    
    for i = 1:nbs
        R0(i) = sqrt((baseStation(i,1) - MS(1))^2 + (baseStation(i,2) - MS(2))^2 + (baseStation(i,3) - MS(3))^2); 
    end
    
    rmse_sum = 0;
    rmse_sum_chan = 0;
    
    for exp = 1:num_experiments
        for j = 1:nbs
            wn = rand;  % 随机误差
            d(j) = (R0(j) - R0(1)) / c + wn;  % 单位: s
        end
        
        zp0 = Chan_3D(nbs, baseStation, wn, d);
        zp1 = zp0(1, :);
        zp = zp0(2, :);
        
        RMSE_current = sqrt(mean((zp1 - MS).^2));  % 最小二乘
        RMSE_current_chan = sqrt(mean((zp - MS).^2));
        rmse_sum = rmse_sum + RMSE_current;
        rmse_sum_chan = rmse_sum_chan + RMSE_current_chan;
    end
    
    RMSE(idx) = rmse_sum / num_experiments;
    RMSE_chan(idx) = rmse_sum_chan / num_experiments;
    zp1_all(idx, :) = zp1;
    zp_all(idx, :) = zp;
end

% 重新调整RMSE的形状以适应网格
RMSE = reshape(RMSE, size(x_range));
RMSE_chan = reshape(RMSE_chan, size(x_range));

% 分别绘制不同z层次的图像
z_levels = unique(z_range(:));
figure;
for k = 1:length(z_levels)
    z_idx = find(z_range(1, 1, :) == z_levels(k));
    subplot(ceil(length(z_levels)/2), 2, k);
    surf(x_range(:,:,z_idx), y_range(:,:,z_idx), RMSE(:,:,z_idx)/10^4);
    hold on;
    surf(x_range(:,:,z_idx), y_range(:,:,z_idx), RMSE_chan(:,:,z_idx)/10^4);
    xlabel('x(m)');
    ylabel('y(m)');
    zlabel('RMSE');
    title(['z = ', num2str(z_levels(k)), ' 的RMSE']);
    colorbar;
    legend('最小二乘法', 'Chan算法');
    hold off;
end
