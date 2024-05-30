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
figure(1);
for i = 1:6
    subplot(3,2,i);
    data = pieces_gun{1,i};
    windowSize = 40;
    % 创建一个均值滤波器，其系数为1/windowSize
    b = ones(1, windowSize) / windowSize;
    filtered_signal = filter(b, 1, data);

    Fs = 44100; 

    l = floor(length(filtered_signal));  % 使用floor确保l为整数
    filtered_signal = abs(fft(filtered_signal)/l);
    P1 = filtered_signal(1:floor(l/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
%     plot(P1);
%     plot(filtered_signal); % 绘制时域波形
    % 设计一个截止频率为1000Hz的低通滤波器
    [b, a] = butter(6, 200/(Fs/2), 'low');
    % 应用滤波器
    filtered_signal = filter(b, a, data);

    l = floor(length(filtered_signal));  % 使用floor确保l为整数
    t = linspace(0, l/Fs, l); % 生成时间向量
    % text(2000,0.4 , '马赫波', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'black');
    % text(6000, 0.3, '爆轰波', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'black');
end

