clc; clear;
keepRunning = true;
% 创建一个audioDeviceReader对象
deviceReader = audioDeviceReader;

% 获取可用的音频输入设备
devices = getAudioDevices(deviceReader);

% 找到指定的设备并设置
targetDeviceName = '麦克风阵列 (英特尔® 智音技术)';
idx = find(strcmp(devices, targetDeviceName));
if ~isempty(idx)
    deviceReader.Device = devices{idx};
    % 设置SamplesPerFrame和SampleRate，根据实际情况调整
    deviceReader.SamplesPerFrame = 1024;
    deviceReader.SampleRate = 44100;
    deviceReader.NumChannels = 2;
else
    error('指定的设备未找到！');
end

threshold = 0.05; % 设定的阈值

% 初始化缓冲区以存储1秒的音频数据
bufferSize1Sec = deviceReader.SampleRate; % 1秒音频数据的样本数
audioBuffer1Sec = zeros(bufferSize1Sec, deviceReader.NumChannels);
collectingData = []; % 用于收集超过阈值后的数据
isCollecting = false;
samplesToCollect = 5 * deviceReader.SampleRate; % 超过阈值后需要收集2秒的样本数


% 准备实时绘图
figure(21);
for i = 1:1
    subplot(1, 1, i);
    plots(i) = plot(0, 'LineWidth',1);
    title(['Channel ', num2str(i)]);
    ylim([-1, 1]); % 根据实际信号强度调整
end

while keepRunning
    audioData = deviceReader();
    
    % 更新每个通道的波形
    for i = 1:1
        set(plots(i), 'YData', audioData(:, i));
        set(plots(i), 'XData', 1:length(audioData(:, i)));
    end
    drawnow; % 立即更新图形窗口
        % 更新滑动窗口缓冲区（移除最旧的数据，添加最新的数据）
    audioBuffer1Sec = [audioBuffer1Sec(size(audioData, 1)+1:end, :); audioData];
    
    if ~isCollecting
        % 这里继续更新滑动窗口缓冲区
        audioBuffer1Sec = [audioBuffer1Sec(size(audioData, 1)+1:end, :); audioData];
        
        if max(abs(audioData(:))) > threshold
            % 超过阈值，开始收集后续的2秒数据
            collectingData = audioData;
            isCollecting = true;
            fprintf('WARNING!!')
            % 重要：复制当前缓冲区用于保存，确保事件发生前1秒数据不会丢失
            preEventBuffer = audioBuffer1Sec;
        end
    else
        % 在收集数据期间，不更新滑动窗口缓冲区，以保留事件发生前的数据
        collectingData = [collectingData; audioData];
        if size(collectingData, 1) >= samplesToCollect
            % 组合前1秒和后2秒的数据，并保存
            audioToSave = [preEventBuffer; collectingData];
            filename = sprintf('Audio_%s.wav', datestr(now, 'yyyymmddTHHMMSS'));
            audiowrite(filename, audioToSave, deviceReader.SampleRate);
            keepRunning = false;
            disp(['Audio recorded and saved to ', filename]);
            save('audioToSave.mat','audioToSave');
            % 重置收集状态和清除用于保存的缓冲区
            isCollecting = false;
            collectingData = [];
            close (21);
        end
    end
end
