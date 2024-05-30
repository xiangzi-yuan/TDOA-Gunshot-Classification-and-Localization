

% first run FileReading
% so that data_gun, data_explosion ara loaded
% num_gun, num_explosion are defined in FileReading

% -- ǰ��˵�� --

close all; % �ر�����֮ǰ�򿪵�ͼ�ν���
FileReading;
% -- ��ȡǹ������ --
segments_gun = zeros(num_gun,maxlen_gun); % ��ʼ���洢ǹ��Ƭ�εľ���
piece_num_gun = 0; % ��ʼ��ǹ��Ƭ�ε�����������
piece_gun = cell(1,2000); % ��ʼ�����ڴ洢ǹ��Ƭ�εĵ�Ԫ����
for ii = 1:6 % ��������ǹ����¼
    
    figure(1); % ����һ����ͼ�δ��ڻ򼤻���Ϊ1�Ĵ���

    % ����ͼ�л��Ƶ�ǰǹ���ź�
    subplot(4,3,ii);
    plot(data_gun(ii,:));xlabel('t / s');title('gun');

    % ��ʱ�����Ͷ�ʱ�����ʵļ���
    N = 300; % ���ô��ڿ��
    inc = 100; % ����֡��
    win = hamming(N); % ����������
    [frameout,t,energy,zcr] = enframe(data_gun(ii,:),win,inc); % ʹ��֡��������
    t = t';
    subplot(4,3,6+ii);hold on;plot(energy,'b');title('energy');hold off; % ��������
    figure(11); % �л�����һ��ͼ�δ���
    subplot(4,3,ii);plot(zcr);title('zcr'); % ���ƹ�����
    figure(1); % ����ԭͼ�δ���
    
    % ��ֵ�˲����������ź�
    wnd = 50; % ���崰�ڴ�С
    b = (1/wnd)*ones(1,wnd); % �����˲���ϵ��
    a = 1;
    sm = filter(b,a,energy); % �������ź�Ӧ�þ�ֵ�˲�
    subplot(4,3,6+ii);hold on;plot(sm,'k');hold off; % �����˲���������ź�
    energy = sm; % ���������ź�Ϊ�˲���Ľ��
    sm_zcr = filter(b,a,zcr); % �Թ������ź�Ҳ���о�ֵ�˲�
    figure(11); % �л�����ʾ�����ʵ�ͼ�δ���
    subplot(4,3,ii);hold on;plot(sm_zcr,'k');title('zcr');hold off; % �����˲���Ĺ�����
    figure(1); % ����ԭͼ�δ���
    
    % ����Ӧ��ʱ������ֵ�ָ�
    threshold = min(energy)+0.2*(max(energy)-min(energy)); % ������ֵ
    processed_energy = energy; % ���������ź�
    for i = 1:length(energy)
        processed_energy(i) = 0;
        if energy(i) >= threshold 
            processed_energy(i) = 1; % ������ֵ��ֵ�����������ź�
        end
    end
    
    % ����ʱ����������˶�������
    thr = 30; % ������С����ʱ����ֵ
    cnt = 0; % ��ʼ��������
    for i = 1:length(processed_energy)
        if processed_energy(i) == 1
            if cnt > 0
                cnt = cnt+1;
            elseif cnt == 0
                cnt = 1;
            end
            if i == length(processed_energy) && cnt < thr
                processed_energy((i-cnt):i) = 0; % ������һ�γ���ʱ�䲻�㣬������
            end
        elseif processed_energy(i) == 0 && cnt > 0 && cnt < thr
            processed_energy((i-cnt):i) = 0; % ���㲻�������ʱ���Ƭ��
            cnt = 0; % ���ü�����
        end
    end
    
    hold on;plot(threshold*ones(size(energy)),'g');hold off; % ������ֵ��
    subplot(4,3,6+ii);hold on;plot(processed_energy*max(energy),'r');hold off; % ���ƴ����������ź�
    
    % Ƭ�ηָ��ȡ����Ȥ����ƵƬ��
    segments = processed_energy.*t; % �ô����������źŹ���ʱ���
    min_seg = length(segments);
    max_seg = 0;
    piece_start = 0;
    piece_end = 0;
    for i = 1:length(segments)
        if 0 < segments(i) && segments(i) < min_seg
            min_seg = segments(i); % �ҵ�����ķ���ʱ���
        end
        if max_seg < segments(i)
            max_seg = segments(i); % �ҵ�����ķ���ʱ���
        end
        
        if i+1 <= length(segments) && segments(i) == 0 && segments(i+1) > 0
            piece_start = segments(i+1); % ���Ƭ�ο�ʼ
        end
        if 1 <= i-1 && segments(i-1) > 0 && segments(i) == 0
            piece_end = segments(i-1); % ���Ƭ�ν���
            piece_num_gun = piece_num_gun+1; % ����Ƭ�μ���
            piece_gun{1,piece_num_gun} = data_gun(ii,piece_start:piece_end); % ����Ƭ��
            figure(2); % �л�����ʾƬ�ε�ͼ�δ���
            subplot(8,5,piece_num_gun); % ����Ƭ�β���
            plot(data_gun(ii,piece_start:piece_end));
            title('piece');
            fprintf('piece: %d of gun record %d, from %d to %d\n',piece_num_gun,ii,piece_start,piece_end); % ��ӡƬ����Ϣ
            figure(1); % ����ԭͼ�δ���
            subplot(4,3,ii);
            hold on;plot(piece_start:piece_end,data_gun(ii,piece_start:piece_end),'r');hold off; % ��ԭ�ź��ϸ�����ʾƬ��
        end
    end
    figure(1); % ȷ����ǰͼ�δ���Ϊ1
end