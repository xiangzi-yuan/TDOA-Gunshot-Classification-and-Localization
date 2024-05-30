% 时间向量
t = 0:0.01:2;
% 初始化信号数组
signal = zeros(size(t));

% 定位马赫波到达的大约时间
[~, idx1] = min(abs(t-0.5));
% 假设的一次函数参数
a = -0.2;  % 斜率
b = 1;      % 截距

% 生成一次函数对应的数组
x = (idx1-8:idx1+8);            
linear_array = a * (x - 46) + b;  % 计算一次函数的值

% 将一次函数值赋给信号数组的对应位置
signal(idx1-8:idx1+8) = linear_array;

% 定位爆轰波到达的大约时间
[~, idx2] = min(abs(t-1.5));
% 创建爆轰波（先上升后平滑下降）
signal(idx2-1:idx2+10) = [0, 1, 0.8, 0.6, 0.4, 0.2, 0.0, -0.05, -0.10, -0.12, -0.06, 0];

% 绘制信号图
figure;
plot(t, signal, 'b', 'LineWidth', 1);
xlabel('时间 (s)');
ylabel('振幅');
title('枪声波形：马赫波与爆轰波');
grid on;

% 隐藏坐标轴和标题
axis off;
title('');

% 在波形上方增加文字注释
text(0.5,1.7 , '马赫波', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'black');
text(1.5, 1, '爆轰波', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'black');
