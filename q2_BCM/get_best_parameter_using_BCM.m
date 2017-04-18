clear all; close all;
load('planecontrol.mat');
addpath '../GPML';
startup;

% the hyp contains all parameters
batch_number = 500;
[all_data, ~] = size(ytrain);
all_mu = zeros(3750, all_data/batch_number);
all_var = zeros(3750, all_data/batch_number);

tic % start timer
% train all modules
for i = 0 : all_data/batch_number-1
    % choose modules' data
    data_select = i*batch_number+1 : (i+1)*batch_number;   
    fprintf('This is the %d time loop \n', i+1);
    
    x = xtrain(data_select, [1 : 40]);
    y = ytrain(data_select);
    xs = xtest;
    
    meanfunc = {};                                                                                                                                                 
    covfunc = {'covSum', {'covSEard', 'covNoise'}};

    likfunc = @likGauss;
    startpoint = zeros(42, 1) + 0.1;
    start_mean = [];

    hyp = struct('mean', start_mean, 'cov', startpoint , 'lik', -1);
    hyp = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);

    % calculating modules' Mu and var
    [Mu, var] = gp(hyp, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);
    all_mu(:, i+1) = Mu;
    all_var(:, i+1) = var;
end

% combine all modules
% calculate sigmaQQ
sigmaQQ = feval(covfunc{:}, hyp.cov, xs, 'diag'); 

% calculate var
plus_var = zeros(3750, 1);
for i = 1 : all_data/batch_number
    plus_var = plus_var + 1./all_var(:, i);
end
plus_var = plus_var - (all_data/batch_number-1)*sigmaQQ;
plus_var = 1./plus_var;

% calculate mu
plus_mu = zeros(3750, 1);
for i = 1 : all_data/batch_number
    plus_mu = plus_mu + all_mu(:, i) .* 1./all_var(:, i);
end
plus_mu = plus_mu .* plus_var;
toc % end timer

% calculating the MSE
fprintf('BCM model with individual hyperparams:\n');
fprintf('MSE = %f \n', MSE_plane_control(plus_mu));

% this picture show the comparion of train and test
figure(1)
subplot(2,1,1);
show = 500; % the length of the point to be shown
show_channel = 7;
plot(xtrain([1 : show],show_channel)*100+1000);
hold on
plot(ytrain([1 : show])*500-1000);
%axis([0 show -2500 1000]);
subplot(2,1,2);
plot(xtest([1 : show],show_channel)*100+1000);
hold on
plot(Mu([1 : show])*500-1000);
%axis([0 show -2500 1000]);

figure(2)
all_MSE = zeros(1, all_data/batch_number);
for i = 1 :  all_data/batch_number
    all_MSE(1, i) = MSE_plane_control(all_mu(:, i));
end
plot(all_MSE);
hold on;
plot(all_MSE, 'd');
title('The MSE of all modules');