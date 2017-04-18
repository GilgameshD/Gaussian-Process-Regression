close all; clc;
load question1.mat;

x = xtrain(1 : 543);
y = ytrain(1 : 543);
xs = xtest;

cov2 = {'covSum', {'covRQiso', 'covPeriodic'}};
cov3 = {'covProd', {'covSEard', 'covPeriodic'}};
cov4 = {'covProd', {'covSEard', 'covLINiso'}};
cov5 = {'covProd', {cov2, 'covSEard'}};

covfunc = {'covSum', {cov4, cov5}};
meanfunc = [];                    
likfunc = @likGauss;              

startpoint = zeros(11, 1);

hyp = struct('mean', [], 'cov', startpoint , 'lik', -1);
hyp2 = minimize(hyp, @gp, -180, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
hyp3 = minimize(hyp2, @gp, -378, @infGaussLik, meanfunc, covfunc, likfunc, x, y);

[Mu, s] = gp(hyp3, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);

MSE = MSE_question2(Mu);

figure(1);
plot(xtrain, ytrain);
hold on;
plot(xtrain, ytrain,'r.');
figure(2);
plot(xtest, Mu);
hold on;
plot(xtest, Mu,'r.');
figure(3);
plot(xtrain(1:543), ytrain(1:543));
hold on
f = [Mu+2*sqrt(s); flip(Mu-2*sqrt(s),1)];
fill([xs; flip(xs,1)], f, [7 7 7]/8)
hold on; 
plot(xs, Mu, 'g');


% save the kernel function
save('kernel_best.mat', 'meanfunc', 'covfunc', 'hyp2', 'hyp3', 'likfunc', 'MSE');
    
    
    
    