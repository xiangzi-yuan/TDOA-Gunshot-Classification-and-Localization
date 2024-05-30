%% 把mat文件转成csv文件
clear all;
data = load('matlab.mat');
fields = fieldnames(data);  % 获取所有字段名称
disp(fields);               % 显示字段名称，帮助确定要导出哪些数据
toSave = data.data_gun;
writematrix(toSave, 'output1.csv');  % MATLAB R2019a 或更新的版本推荐使用
