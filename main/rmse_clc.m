% 真实坐标
true_coords = [
    0, 0, 0;
    150, 0, 0;
    0, 150, 0;
    0, 0, 150;
    150, 150, 0;
    0, 150, 150;
    150, 0, 150;
    150, 150, 150
];

% 预测坐标
pred_coords = [
    3.77, 3.01, 2.70;
    160.20, -22.4, -8.47;
    20.22, 155.99, 6.00;
    18.28, 7.82, 140.47;
    156.46, 151.93, 12.5;
    18.62, 132.37, 147.45;
    157.50, -7.01, 157.42;
    145.81, 144.06, 165.70
];

% 计算每个点的误差
errors = sqrt(sum((pred_coords - true_coords).^2, 2));

% 计算均方根误差（RMSE）
rmse = sqrt(mean(errors.^2));

% 显示结果
disp('每个点的误差:');
disp(errors);

disp('均方根误差 (RMSE):');
disp(rmse);

% 将结果保存到表格中
rmse_table = array2table([true_coords, pred_coords, errors], ...
    'VariableNames', {'True_X', 'True_Y', 'True_Z', 'Pred_X', 'Pred_Y', 'Pred_Z', 'Error'});

% 保存表格到文件
writetable(rmse_table, 'rmse_results.csv');

% 显示表格
disp('结果表格:');
disp(rmse_table);
