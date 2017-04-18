function [MSE, Mu] = data_read_and_MSE(channel_dimension, data_number)
    load('planecontrol.mat');
    channel = channel_dimension;
    %-----------------------------------------------------------------------------------------------------------------
    % picking  hyperparameters
    sigma_f = 1.75;
    sigma_n = 1.27;
    l = 2.67;

    % PER parameters
    sigma_f_2 = 2.5;
    l_2 = 10.55;

    % LIN parameters
    sigma_b = 20;
    sigma_v = 1;
    l_3 = 10;
    
    % RQ parameters
    my_alpha = 0.2;

    % select data channel  a
    %-----------------------------------------------------------------------------------------------------------------
    data_select = floor(1 + 9999*rand(1,data_number));
    xtrain_use = xtrain(data_select, channel)';
    ytrain_use = ytrain(data_select, 1);

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
    kernel_function_RQ = @(x, x2) sigma_f^2*(1+(x-x2)'*(x-x2)/(2*my_alpha*l^2))^(-my_alpha);

    kernel_function = @(x, x2) kernel_function_LIN(x,x2) + kernel_function_SE(x, x2) * kernel_function_PER(x,x2);
    error_function = @(x, x2) sigma_n^2*(sum(x==x2)==length(x));
    k_m = @(x, x2) kernel_function(x, x2) + error_function(x,x2); 


    %-----------------------------------------------------------------------------------------------------------------
    % calculate error function of initial parameters, and saves in K
    for i = 1 : size(xtrain_use, 2)
        for j = 1 : size(xtrain_use, 2)
            K(i, j) = k_m(xtrain_use(:, i), xtrain_use(:, j));
        end
    end

    %-----------------------------------------------------------------------------------------------------------------
    %calculate K-star
    xtest_tran = xtest(: , channel)';
    K_s = zeros(size(xtest_tran, 2),size(xtrain_use, 2));
    for i = 1 : size(xtest_tran,2)
        for j =1 : size(xtrain_use,2)
            K_s(i, j) = k_m(xtest_tran(: , i), xtrain_use(: , j)); 
        end
    end

    %-----------------------------------------------------------------------------------------------------------------
    % calculate mean function, use cholesky decomposition (P37 in GPML)
    % in order to avoid getting zero single values, we should make a check, we
    % add a little value to the diagnose, using (K+a*I) as a new matrix K
    single_value = svd(K);
    if ~isempty(find(single_value < 0.00000001, 1))
        [len, ~] = size(K);
        diagnose = zeros(1, len) + 0.00000001;
        K = K + diag(diagnose, 0);
    end

    L = chol(K, 'lower');
    my_alpha = L' \ (L \ ytrain_use);
    Mu = K_s * my_alpha;  % this is f-star
    %  calculating MSE
    MSE = MSE_plane_control(Mu);

end