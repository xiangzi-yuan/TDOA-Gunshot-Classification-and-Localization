clear;
load("audioToSave.mat");
numChannels = 8; % 通道数
sampleRate = 44100; % 采样率
durationSec = 3; % 绘制3秒数据
samplesToPlot = sampleRate * durationSec; % 计算需要绘制的样本数

% 检查audioToSave的长度是否足够
if size(audioToSave, 1) < samplesToPlot
    samplesToPlot = size(audioToSave, 1); % 如果不足3秒，则调整为实际长度
end

% 创建图形并绘制每个通道
figure('Name', 'Audio Channels', 'NumberTitle', 'off');
for i = 1:numChannels
    subplot(numChannels/2, 2, i);
    plot((1:samplesToPlot) / sampleRate, audioToSave(1:samplesToPlot, i));
    xlabel('时间 (s)');
    ylabel('幅度');
    title(['Channel ', num2str(i)]);
    xlim([0 samplesToPlot / sampleRate]); % 限制x轴显示0到3秒
end

% 计算FFT并存储结果
[numSamples, numChannels] = size(audioToSave);
fftResults = zeros(numSamples/2+1, numChannels);
FFTs = zeros(numSamples, numChannels);
for i = 1:numChannels
    y = fft(audioToSave(:, i));
    FFTs(:, i) = y;
    P2 = abs(y / numSamples);
    P1 = P2(1:numSamples/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    fftResults(:, i) = P1;
end

% 初始化时延矩阵
delaytime = zeros(numChannels, numChannels);

% 计算每对通道之间的时延
for i = 1:numChannels
    for j = i+1:numChannels
        FFT1 = FFTs(:, i);
        FFT2 = FFTs(:, j);
        S12 = FFT1 .* conj(FFT2);
        weightingFunction = 1 ./ abs(S12);
        weightedS12 = S12 .* weightingFunction;
        gcc = ifft(weightedS12);
        gcc = fftshift(gcc);

        [~, delayIndex] = max(abs(gcc));
        delaynum = (delayIndex - ceil(numSamples / 2));
        delay = (delayIndex - ceil(numSamples / 2)) / sampleRate;
%         delaytime(i, j) = delay;
%         delaytime(j, i) = -delay;  % 假设时延是相对的，i到j的延迟为正，j到i的延迟为负
        delaytime(i, j) = -delay;
        delaytime(j, i) = delay;  % 假设时延是相对的，i到j的延迟为正，j到i的延迟为负
        fprintf('参考通道 %d, 输入通道 %d 延迟样点数 = %4d   延迟时间 = %5.6f(秒)\n', i, j, delaynum,delay);
    end
end

% 可视化所有基站之间的时延矩阵
figure;
imagesc(delaytime);
colorbar;
title('GCC估计时延矩阵');
xlabel('输入通道');
ylabel('参考通道');
set(gca, 'FontSize', 14); % 调整坐标轴字体大小
set(get(gca, 'title'), 'FontSize', 16); % 调整标题字体大小
set(get(gca, 'xlabel'), 'FontSize', 14); % 调整X轴标签字体大小
set(get(gca, 'ylabel'), 'FontSize', 14); % 调整Y轴标签字体大小
