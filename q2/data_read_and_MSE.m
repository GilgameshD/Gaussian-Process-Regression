clear all; close all;
load('planecontrol.mat');
load('hyp.mat');

addpath '../GPML';
startup;

tic
[Mu, ~] = gp(hyp_now, @infGaussLik, meanfunc_now, covfunc_now, likfunc_now, xtrain, ytrain, xtest);
toc

MSE = MSE_plane_control(Mu);
fprintf('finishing calculating MSE, and the MSE is %f \n', MSE);

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

figure(3)
for i = 1 : 40
    sort_channel = i;
    combine_train = [xtrain ytrain];
    combine_train = sortrows(combine_train, sort_channel);
    xtrain_new = combine_train(:, 1:40);
    ytrain_new = combine_train(:, 41);
    
    subplot(5,8,i);
    show = 100; % the length of the point to be shown
    show_channel = i;
    plot(xtrain_new([1 : show], show_channel));
    hold on
    plot(ytrain_new([1 : show], 1));
end

figure(4)
for i = 1 : 40
    sort_channel = i;
    combine_train = [xtest Mu];
    combine_train = sortrows(combine_train, sort_channel);
    xtest_new = combine_train(:, 1:40);
    mu_new = combine_train(:, 41);
    
    subplot(5, 8, i);
    show = 100; % the length of the point to be shown
    show_channel = i;
    plot(xtest_new([1 : show], show_channel));
    hold on
    plot(mu_new([1 : show], 1));
end