%% ���廥�����ʱ���ӳ�
% generalized cross correlation 
% TDOA 
clear all; clc; close all;
N=1024;  %����
Fs=500;  %����Ƶ��
n=0:N-1;
t=n/Fs;   %ʱ������
a1=5;     %�źŷ���
a2=5;
d=200;     %�ӳٵ���
x1=a1*cos(2*pi*10*n/Fs);     %�ź�1
%x1=x1+randn(size(x1));      %������
x2=a2*cos(2*pi*10*(n+d)/Fs); %�ź�2
%x2=x2+randn(size(x2));
subplot(211);
plot(t,x1,'r');
axis([-0.2 1.5 -6 6]);
hold on;
plot(t,x2,':');
axis([-0.2 1.5 -6 6]);
legend('x1�ź�', 'x2�ź�');
xlabel('ʱ��/s');ylabel('x1(t) x2(t)');
title('ԭʼ�ź�');grid on;
hold off
%% ����غ��� 1 
X1=fft(x1,2*N-1);
X2=fft(x2,2*N-1);
Sxy=X1.*conj(X2);
Cxy=fftshift(ifft(Sxy));
%Cxy=fftshift(real(ifft(Sxy)));
subplot(212);
t1=(0:2*N-2)/Fs;                        %ע��
plot(t1,Cxy,'b');
title('����غ���');xlabel('ʱ��/s');ylabel('Rx1x2(t)');grid on
[max,location]=max(Cxy);%������ֵmax,�����ֵ���ڵ�λ�ã��ڼ��У�location;
%d=location-N/2-1        %����ӳ��˼�����
d=location-N
Delay=d/Fs;              %���ʱ���ӳ�

%% ����غ��� 2
Cxy2=xcorr(x1,x2);    %Cross-correlation of the signal from-130 to 130 
%dd=find(Cxy2==max(Cxy2))-N     
[max1,location1]=max(Cxy2);
d2=location1-N