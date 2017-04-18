clear all; clc; close all;

% picking  hyperparameters
sigma_f = 11.75;
sigma_n = 0.28;
l = 1.67;

% PER
sigma_f_2 = 107.5;
l_2 = 0.55;

% LIN
sigma_b = 100.5103;
sigma_v = 30.2509;
sigma_b_2 = 1;
sigma_v_2 = 2;
l_3 = 0.0001;
l_4 = 0.5;

load question1.mat;
xtrain_use = xtrain(528 : 543)';
ytrain_use = ytrain(528 : 543);

% Kernel calculation begins
K = zeros(size(xtrain_use,2));
% this kernel function use SE, but it doesn't work well
kernel_function_SE = @(x, x2) sigma_f^2*exp((x-x2)'*(x-x2)/(-2*l^2));
% this kernel function use PER
kernel_function_PER = @(x, x2) sigma_f_2^2*exp(-2*(sin(pi*(x-x2)))^2/l_2^2);
% this kernel function use LIN
kernel_function_LIN = @(x, x2) sigma_b^2 + sigma_v^2*(x-l_3)*(x2-l_3);
kernel_function_LIN_2 = @(x, x2) sigma_b_2^2 + sigma_v_2^2*(x-l_4)*(x2-l_4);
% this kernel function use RQ
kernel_function_RQ = @(x, x2) sigma_f^2*(1+(x-x2)'*(x-x2)/(2*alpha*l^2))^(-alpha);

% choose one kernel, linear combination
% （1）SE表示了整个趋势，PER表示了局部的振荡，现在局部的振荡没有问题，主要是趋势一直是上升的，应该是下降的
% （2）如果用线性核的话能够表示下降的趋势，但是并不是完全的线性性,。
% （3）PER对于参数的敏感性太大
kernel_function = @(x,x2)  kernel_function_SE(x,x2) + ...
                                              kernel_function_PER(x,x2) + ...
                                              kernel_function_LIN(x,x2) + ...
                                              kernel_function_LIN_2(x,x2);

error_function = @(x, x2) sigma_n^2*(sum(x==x2)==length(x));
k_m = @(x, x2) kernel_function(x,x2) + error_function(x,x2); 

% calculate error function of initial parameters, and saves in K
for i = 1 : size(xtrain_use, 2)
    for j = 1 : size(xtrain_use, 2)
        K(i, j) = k_m(xtrain_use(:, i), xtrain_use(:, j));
    end
end
fprintf('finish calculating K ... \n');

xtest_tran = xtest';
%K_ss calculation begins
K_ss = zeros(size(xtest_tran, 2));

for i = 1 : size(xtest_tran, 2)
    for j = i : size(xtest_tran, 2)
        K_ss(i, j) = k_m(xtest_tran(: , i), xtest_tran(: , j));
    end
end
%optimisation exploiting the diagonal symmetry of K_ss
K_ss = K_ss + triu(K_ss, 1)';
%K_ss ends
fprintf('finish calculating Kss ... \n');

K_s = zeros(size(xtest_tran, 2),size(xtrain_use, 2));
for i = 1 : size(xtest_tran,2)
    for j=1 : size(xtrain_use,2)
        K_s(i, j) = k_m(xtest_tran(: , i), xtrain_use(: , j)); 
    end
end
fprintf('finish calculating Ks ... \n');

% calculate Mu and Sigma, use cholesky decomposition(P37 in GPML)
L = chol(K,'lower');
alpha = L' \ (L \ ytrain_use);
Mu = K_s*alpha;  % this is f-star
s = L \ K_s';
Sigma = 1.96*sqrt(diag(K_ss-s'*s));

MSE = MSE_question2(Mu);
fprintf('The MSE is %f\n', MSE);

figure(1);
plot(xtrain, ytrain);
hold on;
plot(xtrain, ytrain,'.');
figure(2);
plot(xtest, Mu);
hold on;
plot(xtest, Mu,'.');
figure(3);
plot(xtrain(1:543), ytrain(1:543));
hold on
f = [Mu+2*sqrt(Sigma); flip(Mu-2*sqrt(Sigma),1)];
fill([xtest; flip(xtest, 1)], f, [7 7 7]/8)
hold on; 
plot(xtest, Mu, 'g');
title('data using mannal kernel function');


