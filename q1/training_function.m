function [ loglik ] = training_function(x)

    kernel_function_m = @(x,x2,sigma_f,l,v,l_2) sigma_f^2*exp((x-x2)'*(x-x2)/(-2*l^2)) + sigma_f^2*exp(-2*(sin(v*pi*(x-x2)))^2/l_2^2);
    error_function_m = @(x,x2,sigma_n) sigma_n^2*(sum(x==x2)==length(x));
    k_m = @(x,x2,sigma_f,l,v,l_2,sigma_n) kernel_function_m(x,x2,sigma_f,l,v,l_2)+error_function_m(x,x2,sigma_n);
    
    load question1.mat;
    X_o = xtrain';
    Y_o = ytrain;
    K = zeros(size(X_o,2));
    
    for i = 1:size(X_o,2)
        for j = 1:size(X_o,2)
            K(i,j) = k_m(X_o(:,i),X_o(:,j),x(1),x(2),x(3),x(4),x(5));
        end
    end
    
    L = chol(K, 'lower');
    alpha = L' \ (L \ Y_o);
    %we want to minimize loglik and record the hyperparameters that do so
    loglik = 0.5*Y_o'*alpha+sum(log(diag(L))) + log(2*pi)*size(xtrain,1)/2;
    
    % output hyperparameters and loglik
    display('hyperparameters:');
    display(x);
    display(loglik);
end

