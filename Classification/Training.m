% %% ǰ�ù���
FileReading; close all;
% % ȡ��fs���������洢�ڹ�����
% 
% % �������ͱ�ʶ����1-ǹ����2-��������3-������
% stype_gun = 1;
% stype_siren = 2;
% stype_car_horn = 3;
% num_samples = 40;  % �±������ĵڶ�������
% % ��ȡǹ��Ƭ��
% pieces_gun = SegmentExtraction(stype_gun, 90, maxlen_gun, data_gun);
% 
% % ��ȡ������Ƭ��
% pieces_siren = SegmentExtraction(stype_siren, 45, maxlen_siren, data_siren);
% 
% % ��ȡ��ͯ����Ƭ��
% pieces_car_horn = SegmentExtraction(stype_car_horn, 75, maxlen_car_horn, data_car_horn);
% save('pieces_gun.mat', 'pieces_gun', '-v7.3');
% save('pieces_siren.mat', 'pieces_siren', '-v7.3');
% save('pieces_car_horn.mat', 'pieces_car_horn', '-v7.3');


%% ѵ������
load pieces_gun.mat;
load pieces_car_horn.mat;
load pieces_siren.mat;
Spk_num = 3; % ��������
Tra_start = 1;

Tra_end = 80; % ѵ��������
ncentres = 5; % ��ֵ��������

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
            win_type = 'M'; % ������
            cof_num = 20;    
            frm_len = fs*0.02; % ֡��
            fil_num = 20;
            frm_off = fs*0.01; % ֡��
            c = melcepst(pre_sph, fs, win_type, cof_num, fil_num, frm_len, frm_off); %mfcc������ȡ
%             c = c(2:14,:);
            cf = c(:,1:end-1)'; %������MFCC�����ľ����е�ÿһ֡������ϵ��ȥ������ת�þ����Ա��������
            tag2 = tag1 + size(cf,2);
            cof(:,tag1:tag2-1) = cf;
            tag1 = tag2;
% ������ʾ��
%                  if spker_cyc == 1 && sph_cyc <= 6
%                         figure(101);
%                         subplot(3,2,sph_cyc);plot(c);title('ǹ��MFCC');
%                  elseif spker_cyc == 2 && sph_cyc >= 30 && sph_cyc <= 35
%                       figure(102);
%                       subplot(3,2,sph_cyc-29);plot(c);title('������MFCC');
%                  elseif spker_cyc == 3 && sph_cyc <= 6
%                       figure(103);
%                       subplot(3,2,sph_cyc);plot(c);title('��ը��MFCC');
%                  end
% ���Ͻ���������ʾ          

        catch ME
            fprintf('%d,%d,Skipping data due to error: %s\n', spker_cyc,sph_cyc,ME.message);
        
            continue; % ������ǰѭ����ʣ�ಿ�֣�������һ��ѭ��
        end
    end
    
    kiter = 5;
    emiter = 30;
    max_ncentres = 20;
% K-means ���� �ⲿͼ    
%     % �������ľ�����ĿΪmaxK
%     maxK = 10;            % ���ǵ���������Ŀ
%     wss = zeros(1, maxK); % ��ʼ��WSS�洢����
%     
%     % ѭ����ͬ�ľ�����Ŀ�Լ���WSS
%     for k = 1:maxK
%         [centres, ~, sumd] = k_means(cof', k, kiter);
%         wss(k) = sum(sumd); % ��¼ÿ��Kֵ��WSS
%     end
%     
%     % ����K��WSS�Ĺ�ϵͼ
%     figure;
%     plot(1:maxK, wss, '-o');
%     xlabel('K');
%     ylabel('WSS');
%     grid on;
%   % ���Ͻ���������ʾ
    mix = gmm_init(ncentres,cof',kiter,'full');
    [mix, post, errlog] = gmm_em(mix,cof',emiter);
    speaker{spker_cyc}.pai = mix.priors;
    speaker{spker_cyc}.mu = mix.centres;
    speaker{spker_cyc}.sigma = mix.covars;

    clear cof mix;
end

save('speaker.mat', 'speaker', '-v7.3');
