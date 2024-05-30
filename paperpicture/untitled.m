% 设定采样频率
Fs = 10000;  % 采样频率10 kHz

% 高通滤波器
d = designfilt('lowpassiir', 'FilterOrder', 5, 'HalfPowerFrequency', 300, 'SampleRate', Fs, 'DesignMethod', 'butter');

% 测试信号（含低频和高频成分）
t = 0:1/Fs:1-1/Fs;  % 生成时间向量
x = sin(2*pi*100*t) + 0.5*sin(2*pi*1500*t);  % 低频300 Hz和高频1500 Hz

% 应用高通滤波器
y = filter(d, x);

% 计算频谱
X = abs(fft(x));
Y = abs(fft(y));
f = Fs*(0:(length(t)/2))/length(t);  % 频率向量

% 绘制时域波形
figure;
subplot(2,1,1);
plot(t, x);
title('Original Signal in Time Domain');
xlabel('Time (seconds)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, y);
title('Filtered Signal in Time Domain');
xlabel('Time (seconds)');
ylabel('Amplitude');

% 绘制频谱
figure;
subplot(2,1,1);
plot(f, X(1:length(f)));
title('Spectrum of Original Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(f, Y(1:length(f)));
title('Spectrum of Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
