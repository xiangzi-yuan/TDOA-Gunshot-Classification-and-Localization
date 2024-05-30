% %% 前置工作
FileReading; close all;
% % 取得fs等诸多变量存储在工作区
% 
% % 声音类型标识符：1-枪声，2-警笛声，3-喇叭声
% stype_gun = 1;
% stype_siren = 2;
% stype_car_horn = 3;
% num_samples = 40;  % 下边行数的第二个参数
% % 提取枪声片段
% pieces_gun = SegmentExtraction(stype_gun, 90, maxlen_gun, data_gun);
% 
% % 提取警笛声片段
% pieces_siren = SegmentExtraction(stype_siren, 45, maxlen_siren, data_siren);
% 
% % 提取孩童噪声片段
% pieces_car_horn = SegmentExtraction(stype_car_horn, 75, maxlen_car_horn, data_car_horn);
% save('pieces_gun.mat', 'pieces_gun', '-v7.3');
% save('pieces_siren.mat', 'pieces_siren', '-v7.3');
% save('pieces_car_horn.mat', 'pieces_car_horn', '-v7.3');


%% 训练过程
load pieces_gun.mat;
load pieces_car_horn.mat;
load pieces_siren.mat;
Spk_num = 3; % 声音种类
Tra_start = 1;

Tra_end = 80; % 训练集数量
ncentres = 5; % 均值向量个数

speaker = cell(1, Spk_num);
for i = 1:Spk_num
    speaker{i} = struct('pai', [], 'mu', [], 'sigma', []);
end

cnt = 0;
cof = [];
for spker_cyc = 1:Spk_num
    tag1 = 1;
    tag2 = 1;
    for sph_cyc = Tra_start:Tra_end
        try
            if spker_cyc == 1
                speech = pieces_gun{1,sph_cyc};
            elseif spker_cyc == 2
                speech = pieces_siren{1,sph_cyc};
            elseif spker_cyc == 3
                speech = pieces_car_horn{1,sph_cyc};
            end
            cnt = cnt + 1;
            pre_sph = speech;
            win_type = 'M'; % 窗函数
            cof_num = 20;    
            frm_len = fs*0.02; % 帧长
            fil_num = 20;
            frm_off = fs*0.01; % 帧移
            c = melcepst(pre_sph, fs, win_type, cof_num, fil_num, frm_len, frm_off); %mfcc特征提取
%             c = c(2:14,:);
            cf = c(:,1:end-1)'; %将包含MFCC特征的矩阵中的每一帧的能量系数去掉，并转置矩阵以便后续处理
            tag2 = tag1 + size(cf,2);
            cof(:,tag1:tag2-1) = cf;
            tag1 = tag2;
% 论文演示用
%                  if spker_cyc == 1 && sph_cyc <= 6
%                         figure(101);
%                         subplot(3,2,sph_cyc);plot(c);title('枪声MFCC');
%                  elseif spker_cyc == 2 && sph_cyc >= 30 && sph_cyc <= 35
%                       figure(102);
%                       subplot(3,2,sph_cyc-29);plot(c);title('警笛声MFCC');
%                  elseif spker_cyc == 3 && sph_cyc <= 6
%                       figure(103);
%                       subplot(3,2,sph_cyc);plot(c);title('爆炸声MFCC');
%                  end
% 以上仅供论文演示          

        catch ME
            fprintf('%d,%d,Skipping data due to error: %s\n', spker_cyc,sph_cyc,ME.message);
        
            continue; % 跳过当前循环的剩余部分，继续下一个循环
        end
    end
    
    kiter = 5;
    emiter = 30;
    max_ncentres = 20;
% K-means 聚类 肘部图    
%     % 假设最大的聚类数目为maxK
%     maxK = 10;            % 考虑的最大聚类数目
%     wss = zeros(1, maxK); % 初始化WSS存储数组
%     
%     % 循环不同的聚类数目以计算WSS
%     for k = 1:maxK
%         [centres, ~, sumd] = k_means(cof', k, kiter);
%         wss(k) = sum(sumd); % 记录每个K值的WSS
%     end
%     
%     % 绘制K与WSS的关系图
%     figure;
%     plot(1:maxK, wss, '-o');
%     xlabel('K');
%     ylabel('WSS');
%     grid on;
%   % 以上仅供论文演示
    mix = gmm_init(ncentres,cof',kiter,'full');
    [mix, post, errlog] = gmm_em(mix,cof',emiter);
    speaker{spker_cyc}.pai = mix.priors;
    speaker{spker_cyc}.mu = mix.centres;
    speaker{spker_cyc}.sigma = mix.covars;

    clear cof mix;
end

save('speaker.mat', 'speaker', '-v7.3');
