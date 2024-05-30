% 导入两个麦克风的音频数据
[y_0,Fs] = audioread('音轨-0.wav'); 
[y_1] = audioread('音轨-1.wav');

fprintf('采样频率：%d\n ······\n', Fs);

% 取出两段音频前2048个采样点，并作互相关处理，绘制曲线。
A = y_0(1:2048);
B = y_1(1:2048);

[value,delay] = xcorr(A,B);

subplot(1,2,1);
plot(delay, value);

D = zeros(1,926); 

% 以2048个点为一帧，计算互相关得到的时延，绘制出两段音频的时延变化。
for a = 1:2048:size(y_0,1)-2048
    A = y_0(a:a+2048);
    B = y_1(a:a+2048);
    [value,delay]=xcorr(A,B);
    value_max_idx = find(value==max(value));
    D1 = delay(value_max_idx);
    D((a-1)/2048+1) = D1;
end

subplot(1,2,2);
plot(D);
