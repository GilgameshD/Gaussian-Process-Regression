clear all; close all;
load('planecontrol.mat');

% the hyp contains all parameters
train_channel = 7;
data_number = 1000;

data_select = floor(1 + 9999*rand(1,data_number));
data_select = [3000 : 4000];

x = xtrain(data_select, [1 : 40]);
y = ytrain(data_select);
xs = xtest(:, [1 : 40]);

meanfunc = [];                    

cov1 = {'covProd', {'covSEard', 'covLINiso'}};
cov2 = {'covSum', {'covRQiso', 'covPeriodic'}};
cov3 = {'covProd', {'covSEiso', 'covPeriodic'}};
cov4 = {'covProd', {'covSEiso', 'covLIN'}};
cov5 = {'covProd', {cov2, 'covSEiso'}};

covfunc = {'covSEard'};

likfunc = @likGauss;       
startpoint = ones(41, 1);

hyp = struct('mean', [], 'cov', startpoint , 'lik', -1);
hyp2 = minimize(hyp, @gp, -400, @infGaussLik, meanfunc, covfunc, likfunc, x, y);

[Mu, ~] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);

MSE = MSE_plane_control(Mu);
fprintf('finishing calculating MSE, and the MSE is %f \n', MSE);

load('hyp.mat');
if MSE_now > MSE;
    MSE_now = MSE;
    save('hyp.mat', 'hyp2', 'MSE_now', 'covfunc', 'meanfunc', 'likfunc', 'data_number', 'startpoint', 'Mu');
end

% this picture show the comparion of train and test
figure(1)
subplot(2,1,1);
show = 500; % the length of the point to be shown
show_channel = train_channel;
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
    
    subplot(5,8,i);
    show = 100; % the length of the point to be shown
    show_channel = i;
    plot(xtest_new([1 : show], show_channel));
    hold on
    plot(mu_new([1 : show], 1));
end










