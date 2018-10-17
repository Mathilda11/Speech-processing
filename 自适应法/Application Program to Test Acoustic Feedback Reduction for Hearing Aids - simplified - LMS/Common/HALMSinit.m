function S = HALMSinit(w0,mu,fb,ff,delay)

% HALMSinit     Initialize Parameter Structure of the LMS Algorithm
%               for Hearing Aids. Refer to Fig. 1.9 
%
% Arguments:
% w0            Coefficients of FIR filter at start (@n=1)
% mu            Step size for LMS algorithm 
% ff            Feedforward path
% fb            Feedback path
% delay         Delay to adaptive filter
%
% by Lee, Gan, and Kuo, 2008
% Subband Adaptive Filtering: Theory and Implementation
% Publisher: John Wiley and Sons, Ltd


% Assign structure fields

S.coeffs     = w0(:);       % Weight (column) vector of FIR filter 
S.step       = mu;          % Step size of the LMS algorithm
S.iter       = 0;           % Iteration count
S.ff         = ff;          % Feedforward path
S.fb         = fb;          % Feedback path
S.delay      = delay;       % Delay 
S.AdaptStart = length(w0);  % Running effect of adaptive filter
                     
