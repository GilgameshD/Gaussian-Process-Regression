function [maxlik, hyp] = get_maxlik(handle, current_hyp)
    load('question1.mat');
    
    x = xtrain(1 : 543);
    y = ytrain(1 : 543);
    [num, ~] = size(x);

    meanfunc = [];
    likfunc = @likGauss;
    start_mean = [];
    number_of_parameter = eval(feval(handle{:}));
    
    % use last iteration's parameters
    [hyp_size, ~] = size(current_hyp.cov);
    startpoint = rand(number_of_parameter - hyp_size, 1);
    
    hyp2 = struct('mean', start_mean, 'cov', [startpoint ; current_hyp.cov] , 'lik', current_hyp.lik);
    hyp = minimize(hyp2, @gp, -200, @infGaussLik, meanfunc, handle, likfunc, x, y);
    
    [maxlik, ~] = gp(hyp, @infGaussLik, meanfunc, handle, likfunc, x, y);
    
    % get BCM value
    maxlik = maxlik + 0.5*number_of_parameter*log(num);
end