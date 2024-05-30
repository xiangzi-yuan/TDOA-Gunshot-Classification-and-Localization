% % clc;
Training;
% % wright = 0;
% % or

% clear;clc;
% folderPath = 'D:\[GD]\GD\code\myself\Classification'; 
% fileName = 'speaker.mat';
% filePath = fullfile(folderPath, fileName);
% load('pieces_siren.mat')
% load('pieces_car_horn.mat')
% load('pieces_gun.mat')
% load(filePath);
wright = zeros(1,3);
% fs = 16000;
% Spk_num = 3;
% ncentres= 5 ; %混合成分数目
FN = 0;
FP = 0;
TP = 0;
TN = 0;
%% 选择判断语音
s1 = sum(~cellfun(@isempty, pieces_gun));
s2 = sum(~cellfun(@isempty, pieces_siren));
s3 = sum(~cellfun(@isempty, pieces_car_horn));
s = [s1,s2,s3];
for j = 1:3
    for num = Tra_end:s(j)
        people = j ;
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
%             c = c(2:14,:);
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
            if j==1
                if idx == pflag
%                   fprintf('Right,pflag = %d \n',idx);
                    wright(j) = wright(j) + 1;
                    TP = TP + 1;
                else
                    FN = FN+1;
%                   fprintf('Wrong,pflag = %d\n',idx);
                end
            elseif  j ==3
                if idx == pflag
                   TN = TN + 1;
                elseif idx ==1
                   FP = FP + 1; 
                end
            end
            
        catch ME
            s(j) = s(j)-1;
%             fprintf('Error processing data number %d: %s\n', num, ME.message);
%             
            continue; % Skip to next iteration
        end
    end
    goal = wright(j) / (s(j)-Tra_end);
    if j==1
        fprintf('讲话人%d ,正确率%.3f \n',j,goal);
    end
end

% 输出混淆矩阵
confMat = [TP, FN; FP, TN];
disp('混淆矩阵:');
disp(confMat);

% 绘制混淆矩阵图
labels = {'gun', 'others'};
confusionchart(confMat, labels, 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');

