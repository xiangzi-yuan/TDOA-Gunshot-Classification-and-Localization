function piece = SegmentExtraction(stype, num_sound, maxlen_sound, data)
%stype:声音类型决定阈值;num_sound:声音数量，音量最大长度
    if stype == 1 || stype == 2
        factor = 0.2;
    else
        factor = 0.25;
    end
    segments = zeros(num_sound, maxlen_sound);
    piece_num = 0;
    piece = cell(1, 2000);
    for j = 1:num_sound

        % 计算短时能量和短时过零率
        N = 500; % 窗口宽度
        inc = 150; %设置帧移
        win = hamming(N); %创建汉明窗
        [frameout, t, energy, zcr] = enframe(data(j, :), win, inc); % 使用帧函数计算
        t = t';

        %% 均值滤波
        wnd = 50;
        b = (1/wnd)*ones(1, wnd); % 滤波器系数
        a = 1;
        sm = filter(b, a, energy); %对能量信号均值滤波
        
        energy = sm;
        sm_zcr = filter(b, a, zcr);

        %% 自适应短时能量阈值分割
        threshold = min(energy) + factor * (max(energy) - min(energy));
        processed_energy = energy;
        for i = 1:length(energy)
            processed_energy(i) = 0;
            if energy(i) >= threshold
                processed_energy(i) = 1;
            end
        end

        %% 持续时间分析，过滤短噪声
        thrtime = 30;
        cnt = 0;
        for i = 1:length(processed_energy)
            if processed_energy(i) == 1
                cnt = cnt + 1;
                if i == length(processed_energy) && cnt < thrtime
                    processed_energy((i - cnt + 1):i) = 0; % 修正边界条件的处理
                end
            elseif processed_energy(i) == 0 && cnt > 0 && cnt < thrtime
                processed_energy((i - cnt):(i - 1)) = 0;
                cnt = 0;
            end
        end

        %%片段分割
        segments = processed_energy .* t;
        piece_start = 0;
        piece_end = 0;
        for i = 1:length(segments)
            if i+1 <= length(segments) && segments(i) == 0 && segments(i+1) > 0
                piece_start = segments(i+1);
            end
            if 1 <= i-1 && segments(i-1) > 0 && segments(i) == 0
                piece_end = segments(i-1);
                % 确保提取的片段长度大于1以避免只有单个数据点的片段
                if piece_end > piece_start
                    piece_num = piece_num + 1;
                    piece{1, piece_num} = data(j, piece_start:piece_end);
                    fprintf('piece: from %d to %d\n', piece_start, piece_end);
                end
            end
        end
    end
end
