% 基于LMS的自适应时延估计
load('audioToSave.mat');
fs = 44100;            % 采样频率从代码1中获得

% 初始化自适应滤波器参数
N = 50;
delta = 0.001;
numChannels = size(audioToSave, 2);
delaytime = zeros(numChannels, numChannels); % 所有基站之间的时延矩阵

% 外层循环，每个通道作为参考信号
for refChannelIndex = 1:numChannels
    s1 = (audioToSave(:,refChannelIndex))'; % 第refChannelIndex个通道作为参考信号
    M = length(s1);
    t = (0:length(s1)-1)/fs; % 时间向量
    
    % 处理每个通道
    for channelIndex = 1:numChannels % 内层循环遍历所有通道
        if channelIndex ~= refChannelIndex % 避免自身与自身比较
            x = (audioToSave(:,channelIndex))'; % 当前通道作为输入信号
            h = zeros(1, 2*N+1);
            y = zeros(1,M); % 输出初始化
            e = zeros(1,M);
            hh = zeros(M, 2*N+1);
            
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
            delaytime(refChannelIndex, channelIndex) = delay / fs;   % 计算出延迟的时间
            fprintf('参考通道 %d, 输入通道 %d 延迟样点数 = %4d   延迟时间 = %5.6f(秒)\n', refChannelIndex, channelIndex, delay, delaytime(refChannelIndex, channelIndex));
        end
    end
end

figure;
imagesc(delaytime);

colorbar;
title('LMS估计时延矩阵');
xlabel('输入通道');
ylabel('参考通道');
set(gca, 'FontSize', 14); % 调整坐标轴字体大小
set(get(gca, 'title'), 'FontSize', 16); % 调整标题字体大小
set(get(gca, 'xlabel'), 'FontSize', 14); % 调整X轴标签字体大小
set(get(gca, 'ylabel'), 'FontSize', 14); % 调整Y轴标签字体大小
