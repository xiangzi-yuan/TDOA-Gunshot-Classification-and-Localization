% 清理工作区
clear; clc;

% 加载数据
load('pieces_siren.mat')
load('pieces_car_horn.mat')
load('pieces_gun.mat')

% 初始化参数
wright = zeros(1,3);
fs = 16000;
Spk_num = 3;
ncentres = 5;
Tra_end = 1; % 训练结束索引

% 定义标签
labels = {'gun', 'siren', 'car_horn'};
trueLabels = [];
predLabels = [];

% 选择判断语音
s1 = sum(~cellfun(@isempty, pieces_gun));
s2 = sum(~cellfun(@isempty, pieces_siren));
s3 = sum(~cellfun(@isempty, pieces_car_horn));
s = [s1, s2, s3];

for j = 1:3
    for num = Tra_end:s(j)
        people = j;
        spk_cyc = [people, num];
        if spk_cyc(1) == 1
            speech = pieces_gun{1, num};
            pflag = 1;
        elseif spk_cyc(1) == 2
            speech = pieces_siren{1, num};
            pflag = 2;
        elseif spk_cyc(1) == 3
            speech = pieces_car_horn{1, num};
            pflag = 3;
        end
        
        try
            pre_sph = speech;
            win_type = 'M'; % 汉明窗
            cof_num = 20; % 倒谱系数个数
            frm_len = fs * 0.02; % 帧长：20ms
            fil_num = 20; % 滤波器组个数
            frm_off = fs * 0.01; % 帧移：10ms
            c = melcepst(pre_sph, fs, win_type, cof_num, fil_num, frm_len, frm_off);
            cof = c(:, 1:end-1); 
            
            MLval = zeros(size(cof, 1), Spk_num);
            for b = 1:Spk_num 
                pai = speaker{b}.pai;
                for k = 1:ncentres
                    mu = speaker{b}.mu(k, :);
                    sigma = speaker{b}.sigma(:, :, k);
                    pdf = mvnpdf(cof, mu, sigma);
                    MLval(:, b) = MLval(:, b) + pdf * pai(k); 
                end
            end
            
            logMLval = log((MLval) + eps);
            sumlog = sum(logMLval, 1);
            [maxsl, idx] = max(sumlog); 
            
            trueLabels = [trueLabels; pflag];
            predLabels = [predLabels; idx];
            
            if idx == pflag
                wright(j) = wright(j) + 1;
            end
        catch ME
            s(j) = s(j) - 1;
            continue; 
        end
    end
    goal = wright(j) / (s(j) - Tra_end);
    if j == 1
        fprintf('讲话人%d ,正确率%.3f\n', j, goal);
    end
end

% 构建混淆矩阵并显示
trueLabelsGun = trueLabels(trueLabels == 1);
predLabelsGun = predLabels(trueLabels == 1);
confMat = confusionmat(trueLabelsGun, predLabelsGun);

% 绘制混淆矩阵
figure;
heatmap(labels, labels, confMat);
title('混淆矩阵');
xlabel('预测类');
ylabel('实际类');
