clc;
maxlen_gun = 0;
maxlen_siren = 0;
maxlen_horn = 0;
num_gun = 5;
for i = 1:num_gun
    file_name = strcat('../train/gun_shot/gun', num2str(i), '.wav');
    fprintf('checking %s...\n', file_name);
    [y1, fs] = audioread(file_name);
    if maxlen_gun < length(y1(:, 1))
        maxlen_gun = length(y1(:, 1));
    end
end

data_gun = zeros(num_gun, maxlen_gun);


% Reading and plotting gun data
for i = 1:num_gun
    file_name = strcat('../train/gun_shot/gun', num2str(i), '.wav');
    fprintf('reading %s...\n', file_name);
    [y1, fs] = audioread(file_name);
    data_gun(i, 1:length(y1(:, 1))) = y1(:, 1)';
    %figure(2); subplot(4, 2, i); plot(data_gun(i, :));
end
pieces_gun = SegmentExtraction(1, 5, maxlen_gun, data_gun);

for i = 1:6
    figure(1);
    subplot(3,2,i);
    data = pieces_gun{1,i};
    N = length(data);  % 获取数据长度
    Fs = 10000;        % 采样频率，根据实际情况修改
    % 计算FFT
    Y = fft(data);
    % 计算单边频谱的幅值（只取一半区间）
    P2 = abs(Y/N);
    P1 = P2(1:floor(N/2+1));
    P1(2:end-1) = 2*P1(2:end-1);  % 除了直流分量外，其余需要乘以2
    % 创建频率轴
    f = Fs*(0:(N/2))/N;
    % 绘制频谱
    plot(f, P1);
    title('频谱');
    xlabel('频率 (Hz)');
    ylabel('|P1(f)|');



    % 设计一个截止频率为1000Hz的低通滤波器
    Fs = 44100; % 采样频率
    d = designfilt('highpassiir', 'FilterOrder', 5, 'HalfPowerFrequency', 1000, 'SampleRate', Fs, 'DesignMethod', 'butter');
    % 绘制时域波形
    y = filter(d, data);
    figure(2);
    subplot(3,2,i);
    plot(y); % 绘制时域波形
    xlabel('样本序号');
    ylabel('幅度');
    title(sprintf('高通滤波信号 %d', i));

    d = designfilt('lowpassiir', 'FilterOrder', 5, 'HalfPowerFrequency', 1000, 'SampleRate', Fs, 'DesignMethod', 'butter');
    % 绘制时域波形
    y = filter(d, data);

    % 创建一个50阶均值滤波器，其系数为1/50
    windowSize = 100; % 均值滤波器的窗口大小
    b = ones(1, windowSize) / windowSize;
    mean_filtered_signal = filter(b, 1, y);
    figure(4);
    subplot(3,2,i);
    plot(y); % 绘制时域波形
    xlabel('样本序号');
    ylabel('幅度');
    title(sprintf('低通滤波信号 %d', i));

    figure(3);
    subplot(3,2,i);
    plot(mean_filtered_signal); % 绘制时域波形
    xlabel('样本序号');
    ylabel('幅度');
    title(sprintf('均值滤波信号 %d', i));
end


