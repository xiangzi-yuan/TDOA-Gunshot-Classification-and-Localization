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


%%互相关函数
% 绘制fft
% audioToSave的每列代表一个通道的数据
[numSamples, numChannels] = size(audioToSave);
sampleRate = 44100;  

% 初始化数组来存储所有通道的FFT结果
fftResults = zeros(numSamples/2+1, numChannels);
FFTs =zeros(numSamples, numChannels);
for i = 1:numChannels
    % 计算第i个通道的FFT
    y = fft(audioToSave(:, i));
    FFTs(:, i) = y;
    % 只取FFT的前一半，因为FFT结果是对称的
    P2 = abs(y / numSamples);
    P1 = P2(1:numSamples/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    % 将结果存储到结果数组中
    fftResults(:, i) = P1;
end

% fftResults现在包含所有通道的FFT幅度结果
% 每列对应一个通道，行表示不同频率的幅度

figure;
for i = 1:numChannels
    % 对应的频率轴
    f = sampleRate * (0:(numSamples/2)) / numSamples;
    
    % 在子图中绘制FFT结果
    subplot(numChannels/2, 2, i);
    plot(f, fftResults(:, i));
    title(['Channel ', num2str(i)]);
    xlabel('频率 (Hz)');
    ylabel('|P1(f)|');
    xlim([0 24000]); % 显示0到24 kHz的频率，可根据需要调整
end

gccResults = zeros(numSamples, nchoosek(numChannels, 2));
timeDelays = zeros(nchoosek(numChannels, 2), 1);
pairIndex = 1;

% 仅考虑前三个通道进行互相关分析
i=1;
for j = i+1:8
    % 使用已计算的FFT结果
    FFT1 = FFTs(:, i);
    FFT2 = FFTs(:, j);
    % 计算互功率谱密度
    S12 = FFT1 .* conj(FFT2);
    % 应用PHAT权重
    weightingFunction = 1 ./ abs(S12);
    weightedS12 = S12 .* weightingFunction;
    % 计算广义互相关
    gcc = ifft(weightedS12);
    gcc = fftshift(gcc);  % 中心化处理
    % 存储广义互相关结果
    gccResults(:, pairIndex) = gcc;
    % 计算并存储时延
    [~, delayIndex] = max(abs(gcc));
    timeDelays(pairIndex) = (delayIndex - ceil(numSamples / 2)) / sampleRate;
    fprintf('通道 %d 和通道 %d 延迟时间为 %f s.\n', i, j, timeDelays(pairIndex));
    pairIndex = pairIndex + 1;
end



