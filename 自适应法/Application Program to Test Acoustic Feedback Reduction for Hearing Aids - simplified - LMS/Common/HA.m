% HA            Application Program to Test Acoustic Feedback Reduction for Hearing Aids 
%               as Shown in Fig.1.9
%
%               A 64-tap adaptive FIR filter is used to estimate 
%               the feedback path of the hearing aids. The adaptive algorithms 
%               used here are the LMS and NLMS algorithms
%
%
% Reference:    M G Siqueira, A Alwan, "Steady-State Analysis of Continuous
%               Adaptation in Acoustic Feedback Reduction Systems for Hearing-Aids,"
%               IEEE Trans. Speech and Audio Processing, Vol. 8, July 2000, pp 443-453
%
% by Lee, Gan, and Kuo, 2008
% Subband Adaptive Filtering: Theory and Implementation
% Publisher: John Wiley and Sons, Ltd

addpath '..\Common';             % Functions in Common folder
clear all; close all;

load fb.dat;                     % Load the feedback path 将反馈路径读入到工作空间中
norm_fb = norm(fb);              % Norm-2 of feedback path  2范数 模
delay = 10;                      % Delay in feedforward path  前向路径中的延迟
ff= [zeros(1,delay+1) 4];        % Simple feedforward path
%[un,fs] = wavread('timit.wav');  % Extract normalized wave file

%[un,fs] = audioread('near.wav');
%[un,fs] = audioread('far.wav');
[un,fs] = audioread('sp_c2e2.wav');
plot(un);
title('Original signal');
grid on;
sound(un);pause;

noise=0.01*randn(size(un));      % Noisy signal
dn = (un+noise)';                % Speech corrupted with noise

num = conv(ff,fb);               % Numerator 分子
den = [1; -num(2:end)];          % Denumerator 分母
y = filter(num,den,dn);

%audiowrite('near_howling.wav',y,fs); 
%audiowrite('far_howling.wav',y,fs); 
audiowrite('sp_c2e2_howling.wav',y,fs); 
M = 64;                          % Filter length
w0 = zeros(M,1);                 % Initialize filter coefs to 0

% Perform adaptive filtering using LMS algorithm

mulms = 0.1;                     % Step size
disp(sprintf('LMS, step-size = %.5f',mulms));
tic;
Slms = HALMSinit(w0,mulms,fb,ff,delay);
                                 % Initialization
[ylms,enlms,fblms,Slms] = HALMSadapt(un,Slms);

                                 % Perform LMS algorithm
disp(sprintf('Total time = %.3f mins',toc/60));

err_sqrlms = enlms.^2;


% Suggestion: Use other algorithms


% Performance results

% (i) Error signal

figure;

plot(enlms'); 
legend('Error of LMS');
grid on;
xlabel('Iterations'); ylabel('Error');
title('Speech signals derived from the LMS algorithms');
disp('Feedback speech...'); sound(y',fs); pause;


disp('Error signal from the LMS...'); sound(enlms,fs);  pause;
%audiowrite('far_howling_suppression.wav',enlms,fs);
%audiowrite('near_howling_suppression.wav',enlms,fs);
audiowrite('sp_c2e2_howling_suppression.wav',enlms,fs);


% (ii) Check differences between the original and error signals

figure;
plot([(un-y').^2,(un-enlms').^2]);
legend('Without processing','With LMS');
xlabel('Iterations'); ylabel('Error'); grid on;
title('Similarity between the original and error signals');


% (iii) Output signal from adaptive filter

figure;
plot(ylms'); 
disp(' Output signal from adaptive filter...'); sound(ylms,fs);  pause;
legend('Output of LMS');
title('Noise signal derived from the LMS algorithms');
grid on; xlabel('Iterations'); ylabel('Output signal');



% (iv) Plotting final coefficients

figure;
plot(Slms.coeffs,'g','LineWidth',2 );
hold on;
plot(fb(1:M,1),'r');
legend('Final coeffs of LMS','Final coeffs of NLMS','FB coeffs');
grid on;
xlabel('Coefficient index'); ylabel('Amplitude');
title('Final coefficients of the LMS algorithms');

% (v) Feedback path signal after adaptation

figure;
plot([y',fblms']);
legend('Feedback signal','Feedback after LMS');
title('Comparison of feedback signals without and with adaptive filtering (LMS)');
grid on; xlabel('Iterations'); ylabel('Feedback signal');
axis([0 length(un) -1 1]);

