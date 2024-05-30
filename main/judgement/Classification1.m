function result = Classification(audio)
    % audioToSave: 待判断的音频
    % result: 声音种类
    
    % Training;
    % or
    folderPath = 'D:\[GD]\GD\code\myself\Classification'; 
    fileName = 'speaker.mat';
    filePath = fullfile(folderPath, fileName);
    load(filePath);
    fs = 16000; %采样频率
    ncentres = 5;
    Spk_num = 3;
    maxlen = length(audio(:, 1));
    judge = zeros(1,1);
    audio = audio';
    pieces = SegmentExtraction(1, 1, maxlen, audio);
    notEmptyCells = sum(~cellfun(@isempty, pieces));

    shoot = 0;
    num_piece = 0;
    for num = 1:notEmptyCells
        speech = pieces{1, num};
        try
            pre_sph = speech;
            win_type = 'M'; % 汉明窗
            cof_num = 20; % 倒谱系数个数
            frm_len = fs * 0.02; % 帧长：20ms
            fil_num = 20; % 滤波器组个数
            frm_off = fs * 0.01; % 帧移：10ms
            c = melcepst(pre_sph, fs, win_type, cof_num, fil_num, frm_len, frm_off);
            cof = c(:, 1:end-1); % M*D = M*20维矢量, M=10即每个滤波器的输出随10个余弦变换域上的点(广义频率变量)的变化
    
            MLval = zeros(size(cof, 1), Spk_num);
            for b = 1:Spk_num % 说话人循环
                pai = speaker{b}.pai;
                for k = 1:ncentres
                    mu = speaker{b}.mu(k, :);
                    sigma = speaker{b}.sigma(:, :, k);
                    pdf = mvnpdf(cof, mu, sigma);
                    MLval(:, b) = MLval(:, b) + pdf * pai(k); % 计算似然值
                end
            end
            logMLval = log((MLval) + eps);
            sumlog = sum(logMLval, 1);
            [maxsl, idx] = max(sumlog); % 判决，将最大似然值对应的序号idx作为识别结果
            sum(MLval, 1);
            
            if idx == 1
                fprintf('识别出枪声,idx = %d! \n',idx);
                shoot = shoot+1;
                num_piece = num_piece+1;
            else
                fprintf('未识别出枪声,idx = %d! \n',idx);
                num_piece = num_piece+1;
             
            end
            judge(num) = idx;
            catch ME
            fprintf('Error processing data number %d: %s\n', num, ME.message);
            num_piece = num_piece-1;
            continue; % Skip to next iteration
        end
    end
    result = shoot/num_piece