% ����LMS������Ӧʱ�ӹ���
load('audioToSave.mat');
% ��ȡ��һ��ͨ����Ϊ�ο��ź�
s1 = (audioToSave(:,1))'; % ��һ��ͨ��
fs = 44100;            % ����Ƶ�ʴӴ���1�л��
t = (0:length(s1)-1)/fs; % ʱ������

% ��ʼ������Ӧ�˲�������
N = 50;
delta = 0.001;
M = length(s1);
y = zeros(1,M); %�����ʼ��
e = zeros(1,M);
hh = zeros(M, 2*N+1);
numChannels = size(audioToSave, 2);
delaytime = zeros(1, numChannels);
% ����ÿ��ͨ��
for channelIndex = 2:size(audioToSave, 2) % ��������һͨ��֮�������ͨ��
    x = (audioToSave(:,channelIndex))'; % ��ǰͨ����Ϊ�����ź�
    h = zeros(1, 2*N+1);
    % ���ź�������ʱ��h�᲻������ʹ�����Խ��ԽС���������Сʱh���
    for n = N:M-N-1
        x1 = x(n-N+1:n+N+1);
        y(n) = h*x1';               % ����nʱ�̵����
        e(n) = s1(n) - y(n);        % ����nʱ�̵����
        h = h + delta * e(n) * x1;  % �����˲�����ϵ��
        hh(n,:) = h;
    end
    
    % �����ӳ�
    [Hmax, Hloc] = max(hh, [], 2);
    [HHM, HHL] = max(Hmax);
    delay = (Hloc(HHL)-N-1);  % �ӳٵ�������
    delaytime(channelIndex) = delay / fs;   % ������ӳٵ�ʱ��
    fprintf('ͨ�� %d �ӳ������� = %4d   �ӳ�ʱ�� = %5.6f(��)\n', channelIndex, delay, delaytime(channelIndex));
end

figure(1);
subplot(311);
plot(t, s1, 'r', t, x, 'b');
legend('�ο��ź�', '�����ź�'); grid;
title('s�źž���һ����ʱ����ź�');
subplot(312);
plot(t, s1, 'r', t, y, 'b'); 
legend('�ο��ź�', '����ź�'); grid;
title('������Ӧ�˲����������ź�');
subplot(313);
plot(t, e); grid;
title('����ź�');

figure(2);
plot(hh(HHL,:));
title('������ʱ���˲���ϵ��');
