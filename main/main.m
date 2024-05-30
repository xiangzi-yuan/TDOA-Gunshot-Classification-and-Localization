clear all; clc; close all;
addpath('../microphone/');
addpath('../Classification/')
addpath('../TDOA/');

xyz_data = zeros(10, 3); % 预分配存储xyz数据的矩阵

for l = 1:1
    wave;         % 麦克风接收音频
    Dealy_LMS;    % 延时估计 
    % Training;  % 训练枪声识别模型
    result = Classification(audioToSave); % 判断枪声类型
    fprintf('有%.2f的概率是枪声! \n',result)

    experience_3D;    % 三维声源定位
    
    zp = zp';
    xyz_data(l, :) = zp(1:3); % 存储当前的 zp 数据
end

% 保存结果到文件
save('xyz_data.mat', 'xyz_data');
