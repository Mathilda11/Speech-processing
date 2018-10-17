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
[un,fs] = audioread('far.wav');
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
audiowrite('far_howling.wav',y,fs); 
M = 64;                          % Filter length
w0 = zeros(M,1);                 % Initialize filter coefs to 0


% NLMS algorithm

munlms = 0.1;                   % Default step size (between 0 and 2)
leak = 0;

disp(sprintf('NLMS, step size = %.5f',munlms));
tic;
Snlms = HANLMSinit(w0,munlms,fb,ff,delay);
                                 % Initialization
[ynlms,ennlms,fbnlms,Snlms] = HANLMSadapt(un,Snlms);
                                 % Perform NLMS algorithm
disp(sprintf('Total time = %.3f mins',toc/60));

err_sqrnlms = ennlms.^2;



% Suggestion: Use other algorithms


% Performance results

% (i) Error signal

figure;

plot(ennlms); 
legend('Error of NLMS');
grid on;
xlabel('Iterations'); ylabel('Error');
title('Speech signals derived from the NLMS algorithms');
disp('Feedback speech...'); sound(y',fs); pause;

disp('Error signal from the NLMS...'); sound(ennlms,fs); pause;
audiowrite('far_howling_suppression.wav',ennlms,fs);
%audiowrite('near_howling_suppression.wav',ennlms,fs);


% (ii) Check differences between the original and error signals

figure;
plot([(un-y').^2,(un-ennlms').^2]);
legend('Without processing','With NLMS');
xlabel('Iterations'); ylabel('Error'); grid on;
title('Similarity between the original and error signals');


% (iii) Output signal from adaptive filter

figure;
plot(ynlms'); 
disp(' Output signal from adaptive filter...'); sound(ynlms,fs);  pause;
legend('Output of NLMS');
title('Noise signal derived from the NLMS algorithms');
grid on; xlabel('Iterations'); ylabel('Output signal');



% (iv) Plotting final coefficients

figure;
plot(Snlms.coeffs,'b','LineWidth',2);
hold on;
plot(fb(1:M,1),'r');
legend('Final coeffs of NLMS','FB coeffs');
grid on;
xlabel('Coefficient index'); ylabel('Amplitude');
title('Final coefficients of the NLMS algorithms');

% (v) Feedback path signal after adaptation

figure;
plot([y',fbnlms']);
legend('Feedback signal','Feedback after NLMS');
title('Comparison of feedback signal without and with adaptive filtering (NLMS)');
grid on; xlabel('Iterations'); ylabel('Feedback signal');
axis([0 length(un) -1 1]);
