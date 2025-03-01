

% first run FileReading
% so that data_gun, data_explosion ara loaded
% num_gun, num_explosion are defined in FileReading

% -- 前置说明 --

close all; % 关闭所有之前打开的图形界面
FileReading;
% -- 提取枪声部分 --
segments_gun = zeros(num_gun,maxlen_gun); % 初始化存储枪声片段的矩阵
piece_num_gun = 0; % 初始化枪声片段的数量计数器
piece_gun = cell(1,2000); % 初始化用于存储枪声片段的单元数组
for ii = 1:6 % 遍历所有枪声记录
    
    figure(1); % 创建一个新图形窗口或激活编号为1的窗口

    % 在子图中绘制当前枪声信号
    subplot(4,3,ii);
    plot(data_gun(ii,:));xlabel('t / s');title('gun');

    % 短时能量和短时过零率的计算
    N = 300; % 设置窗口宽度
    inc = 100; % 设置帧移
    win = hamming(N); % 创建汉明窗
    [frameout,t,energy,zcr] = enframe(data_gun(ii,:),win,inc); % 使用帧函数计算
    t = t';
    subplot(4,3,6+ii);hold on;plot(energy,'b');title('energy');hold off; % 绘制能量
    figure(11); % 切换到另一个图形窗口
    subplot(4,3,ii);plot(zcr);title('zcr'); % 绘制过零率
    figure(1); % 返回原图形窗口
    
    % 均值滤波处理能量信号
    wnd = 50; % 定义窗口大小
    b = (1/wnd)*ones(1,wnd); % 创建滤波器系数
    a = 1;
    sm = filter(b,a,energy); % 对能量信号应用均值滤波
    subplot(4,3,6+ii);hold on;plot(sm,'k');hold off; % 绘制滤波后的能量信号
    energy = sm; % 更新能量信号为滤波后的结果
    sm_zcr = filter(b,a,zcr); % 对过零率信号也进行均值滤波
    figure(11); % 切换到显示过零率的图形窗口
    subplot(4,3,ii);hold on;plot(sm_zcr,'k');title('zcr');hold off; % 绘制滤波后的过零率
    figure(1); % 返回原图形窗口
    
    % 自适应短时能量阈值分割
    threshold = min(energy)+0.2*(max(energy)-min(energy)); % 计算阈值
    processed_energy = energy; % 复制能量信号
    for i = 1:length(energy)
        processed_energy(i) = 0;
        if energy(i) >= threshold 
            processed_energy(i) = 1; % 根据阈值二值化处理能量信号
        end
    end
    
    % 持续时间分析，过滤短暂噪声
    thr = 30; % 设置最小持续时间阈值
    cnt = 0; % 初始化计数器
    for i = 1:length(processed_energy)
        if processed_energy(i) == 1
            if cnt > 0
                cnt = cnt+1;
            elseif cnt == 0
                cnt = 1;
            end
            if i == length(processed_energy) && cnt < thr
                processed_energy((i-cnt):i) = 0; % 如果最后一段持续时间不足，则清零
            end
        elseif processed_energy(i) == 0 && cnt > 0 && cnt < thr
            processed_energy((i-cnt):i) = 0; % 清零不满足持续时间的片段
            cnt = 0; % 重置计数器
        end
    end
    
    hold on;plot(threshold*ones(size(energy)),'g');hold off; % 绘制阈值线
    subplot(4,3,6+ii);hold on;plot(processed_energy*max(energy),'r');hold off; % 绘制处理后的能量信号
    
    % 片段分割，提取感兴趣的音频片段
    segments = processed_energy.*t; % 用处理后的能量信号过滤时间戳
    min_seg = length(segments);
    max_seg = 0;
    piece_start = 0;
    piece_end = 0;
    for i = 1:length(segments)
        if 0 < segments(i) && segments(i) < min_seg
            min_seg = segments(i); % 找到最早的非零时间戳
        end
        if max_seg < segments(i)
            max_seg = segments(i); % 找到最晚的非零时间戳
        end
        
        if i+1 <= length(segments) && segments(i) == 0 && segments(i+1) > 0
            piece_start = segments(i+1); % 标记片段开始
        end
        if 1 <= i-1 && segments(i-1) > 0 && segments(i) == 0
            piece_end = segments(i-1); % 标记片段结束
            piece_num_gun = piece_num_gun+1; % 更新片段计数
            piece_gun{1,piece_num_gun} = data_gun(ii,piece_start:piece_end); % 保存片段
            figure(2); % 切换到显示片段的图形窗口
            subplot(8,5,piece_num_gun); % 绘制片段波形
            plot(data_gun(ii,piece_start:piece_end));
            title('piece');
            fprintf('piece: %d of gun record %d, from %d to %d\n',piece_num_gun,ii,piece_start,piece_end); % 打印片段信息
            figure(1); % 返回原图形窗口
            subplot(4,3,ii);
            hold on;plot(piece_start:piece_end,data_gun(ii,piece_start:piece_end),'r');hold off; % 在原信号上高亮显示片段
        end
    end
    figure(1); % 确保当前图形窗口为1
end