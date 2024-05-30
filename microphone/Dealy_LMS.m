% 基于LMS的自适应时延估计
load('audioToSave.mat');
% 提取第一个通道作为参考信号
s1 = (audioToSave(:,1))'; % 第一个通道
fs = 44100;            % 采样频率从代码1中获得
t = (0:length(s1)-1)/fs; % 时间向量

% 初始化自适应滤波器参数
N = 50;
delta = 0.001;
M = length(s1);
y = zeros(1,M); %输出初始化
e = zeros(1,M);
hh = zeros(M, 2*N+1);
numChannels = size(audioToSave, 2);
delaytime = zeros(1, numChannels);
% 处理每个通道
for channelIndex = 2:size(audioToSave, 2) % 遍历除第一通道之外的所有通道
    x = (audioToSave(:,channelIndex))'; % 当前通道作为输入信号
    h = zeros(1, 2*N+1);
    % 当信号误差存在时，h会不断增大使得误差越来越小，当误差最小时h最大
    for n = N:M-N-1
        x1 = x(n-N+1:n+N+1);
        y(n) = h*x1';               % 计算n时刻的输出
        e(n) = s1(n) - y(n);        % 计算n时刻的误差
        h = h + delta * e(n) * x1;  % 调整滤波器的系数
        hh(n,:) = h;
    end
    
    % 计算延迟
    [Hmax, Hloc] = max(hh, [], 2);
    [HHM, HHL] = max(Hmax);
    delay = (Hloc(HHL)-N-1);  % 延迟的样点数
    delaytime(channelIndex) = delay / fs;   % 计算出延迟的时间
    fprintf('通道 %d 延迟样点数 = %4d   延迟时间 = %5.6f(秒)\n', channelIndex, delay, delaytime(channelIndex));
end

figure(1);
subplot(311);
plot(t, s1, 'r', t, x, 'b');
legend('参考信号', '输入信号'); grid;
title('s信号经过一段延时后的信号');
subplot(312);
plot(t, s1, 'r', t, y, 'b'); 
legend('参考信号', '输出信号'); grid;
title('经自适应滤波器处理后的信号');
subplot(313);
plot(t, e); grid;
title('误差信号');

figure(2);
plot(hh(HHL,:));
title('最大相关时的滤波器系数');
