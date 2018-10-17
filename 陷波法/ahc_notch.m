clear all
close all
clc

%[x,fs] = wavread('man.wav');
[x,fs] = audioread('man.wav');
%[x,fs] = audioread('timit.wav');
% x = x(1:fs);
g = load('path.txt');

K = 0.2;                                % 增益

g = g(:);                               % 反馈声学路径g
c = [0,0,0,0,1]';                       % 扩音系统内部传递路径c

xs1 = zeros(size(c));
xs2 = zeros(size(g));

y1 = zeros(size(x));                    % 先分配y1和y2空间，避免运行中临时分配空间占用大量的运算量
y2 = zeros(size(x));
temp = 0;

for i = 1:length(x)                     % 卷积形成反馈回路
    xs1 = [x(i)+temp; xs1(1:end-1)];    % 等待与c卷积的信号缓存
    y1(i) = K*(xs1'*c);                 % 馈给扬声器的信号
    y1(i) = min(1,y1(i));               % 幅度约束，啸叫则出现截止
    y1(i) = max(-1,y1(i));
    xs2 = [y1(i); xs2(1:end-1)];        % 等待与g卷积的信号缓存
    temp = xs2'*g;                      % temp作为单样点缓存，待下一采样点处理时与输入信号混合
end
%audiowrite('timit_howling.wav',y1,fs);
audiowrite('man_howling.wav',y1,fs);
d  = fdesign.notch('N,F0,Q,Ap',2,922/(fs/2),1,1);   % 设计陷波器，中心频率为922Hz N - Filter Order (must be even),F0 - Center Frequency,Q - Quality Factor,Ap - Passband Ripple (decibels)
Hd = design(d);
iir_coef1 = Hd.sosMatrix;

d  = fdesign.notch('N,F0,Q,Ap',2,4534/(fs/2),1,1);  % 设计陷波器，中心频率为4534Hz
Hd = design(d);
iir_coef2 = Hd.sosMatrix;

iir_coef = [iir_coef1; iir_coef2];  % 两个陷波器级联成陷波器组


iir_buffer = zeros(size(iir_coef,1),5);

xs1 = zeros(size(c));
xs2 = zeros(size(g));
temp = 0;

for i = 1:length(x)
    xs1 = [x(i)+temp; xs1(1:end-1)];
    y2(i) = K*(xs1'*c);
    y2(i) = min(1,y2(i));
    y2(i) = max(-1,y2(i));
    d = y2(i);                      % iir滤波输入
    for k = 1:size(iir_coef,1)      % iir滤波过程
        iir_buffer(k,1:3) = [d, iir_buffer(k,1:2)];
        d = iir_buffer(k,1:3) * iir_coef(k,1:3)' - iir_buffer(k,4:5) * iir_coef(k,5:6)';
        iir_buffer(k,4:5) = [d, iir_buffer(k,4)];
    end
    y2(i) = d;
    xs2 = [y2(i); xs2(1:end-1)];
    temp = xs2'*g;
end
%audiowrite('timit_howling_suppression.wav',y2,fs);
audiowrite('man_howling_suppression.wav',y2,fs);
[b,a] = sos2tf(iir_coef,ones(size(iir_coef,1)+1,1));
figure,freqz(b,a,1:fs/2,fs)     % 观察陷波器组的频响

figure
subplot(211),plot(y1)           % 未处理信号
subplot(212),plot(y2)           % 啸叫抑制信号
