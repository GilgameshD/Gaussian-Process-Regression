clear all; clc; close all;

global_max_liklihood = inf;
global_handle = {};
folds = 10;

current_handle = {};
all_handle = {};

for fold = 1 : folds
    
    Maxlik_prob_SE = inf;
    Maxlik_prob_RQ = inf;
    Maxlik_prob_LIN = inf;
    Maxlik_prob_PER = inf;
    Maxlik_prob_NOI = inf;
    
    hyp_final.cov = [0.1];
    hyp_final.lik = -1;
    hyp_final.mean = [];
    
    [Maxlik_add_SE, add_SE, hyp_add_SE] = operate_kernel(current_handle, 'add', 'SE', hyp_final);
    [Maxlik_add_RQ, add_RQ, hyp_add_RQ] = operate_kernel(current_handle, 'add', 'RQ', hyp_final);
    [Maxlik_add_LIN, add_LIN, hyp_add_LIN] = operate_kernel(current_handle, 'add', 'LIN', hyp_final);
    [Maxlik_add_PER, add_PER, hyp_add_PER] = operate_kernel(current_handle, 'add', 'PER', hyp_final);
%     [Maxlik_add_NOI, add_NOI, hyp_add_NOI] = operate_kernel(current_handle, 'add', 'NOI', hyp_final);
    
    if fold ~= 1
        [Maxlik_prob_SE, prob_SE, hyp_prod_SE] = operate_kernel(current_handle, 'prod', 'SE', hyp_final);
        [Maxlik_prob_RQ, prob_RQ, hyp_prod_RQ] = operate_kernel(current_handle, 'prod', 'RQ', hyp_final);
        [Maxlik_prob_LIN, prob_LIN, hyp_prod_LIN] = operate_kernel(current_handle, 'prod', 'LIN', hyp_final);
        [Maxlik_prob_PER, prob_PER, hyp_prod_PER] = operate_kernel(current_handle, 'prod', 'PER', hyp_final);
    end
    
    maxlik(fold) = min([Maxlik_add_SE, Maxlik_add_RQ, Maxlik_add_LIN, Maxlik_add_PER, ...%Maxlik_add_NOI, ...
                           Maxlik_prob_SE, Maxlik_prob_RQ, Maxlik_prob_LIN, Maxlik_prob_PER]);             
    
    switch maxlik(fold)
        case Maxlik_add_SE
            current_handle = add_SE;
            hyp_final = hyp_add_SE;
        case Maxlik_add_RQ
            current_handle = add_RQ;
            hyp_final = hyp_add_RQ;
        case Maxlik_add_LIN
            current_handle = add_LIN;
            hyp_final = hyp_add_LIN;
        case Maxlik_add_PER
            current_handle = add_PER;
            hyp_final = hyp_add_PER;
%         case Maxlik_add_NOI
%             current_handle = add_NOI;
%             hyp_final = hyp_add_NOI;
        case Maxlik_prob_SE
            current_handle = prob_SE;
            hyp_final = hyp_prod_SE;
        case Maxlik_prob_RQ
            current_handle = prob_RQ;
            hyp_final = hyp_prod_RQ;
        case Maxlik_prob_LIN
            current_handle = prob_LIN;
            hyp_final = hyp_prod_LIN;
        case Maxlik_prob_PER
            current_handle = prob_PER;
            hyp_final = hyp_prod_PER;
    end
    
    load question1.mat;
    x = xtrain(1 : 543);
    y = ytrain(1 : 543);
    xs = xtest;

    meanfunc = [];                    
    likfunc = @likGauss;              

    [Mu, ~] = gp(hyp_final, @infGaussLik, meanfunc, current_handle, likfunc, x, y, xs);
    MSE_now = MSE_question2(Mu);
    
    MSE(fold) = MSE_now;
    all_hyp(fold) = hyp_final;
    
    if  MSE_now == min(MSE)
        global_max_liklihood = maxlik(fold);
        global_hyp = hyp_final;
        global_handle = current_handle;
        global_MSE = MSE_now;
    end
    
    figure;
    subplot(1,2,1);
    plot(xtest, Mu);
    hold on;
    plot(xtest, Mu,'.');
    subplot(1,2,2);
    plot(xtrain(1:543), ytrain(1:543));
    hold on
    plot(xtest, Mu);
    pause(0.1);
    
    % interperate the cov function 
    fprintf(' current fold is : %d \n', fold);  
    fprintf(' Maxlik_add_SE is  : %f \n ', Maxlik_add_SE);
    fprintf(' Maxlik_add_RQ is  : %f \n ', Maxlik_add_RQ);
    fprintf(' Maxlik_add_LIN is  : %f \n ', Maxlik_add_LIN);
    fprintf(' Maxlik_add_PER is  : %f \n ', Maxlik_add_PER);
    fprintf(' Maxlik_prod_SE is  : %f \n ', Maxlik_prob_SE);
    fprintf(' Maxlik_prod_RQ is  : %f \n ', Maxlik_prob_RQ);
    fprintf(' Maxlik_prod_LIN is  : %f \n ', Maxlik_prob_LIN);
    fprintf(' Maxlik_prod_PER is  : %f \n ', Maxlik_prob_PER);
    
    fprintf(' current max liklihood is : %f \n', maxlik(fold));
    fprintf(' current MSE is : %f \n', MSE_now);
    
    % save the kernel function
%     save('kernel_best.mat', 'global_handle', 'global_hyp', 'global_max_liklihood', 'global_MSE');
%     save('kernel.mat', 'all_hyp', 'maxlik', 'MSE');
%     path = sprintf('handle_%d.mat', fold);
%     save(path, 'current_handle');
end





