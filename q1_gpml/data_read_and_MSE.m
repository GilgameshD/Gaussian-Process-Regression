clear all; close all;
load('question1.mat');
load('kernel_best.mat');
addpath '../GPML'
startup

tic
[Mu, s] = gp(hyp3, @infGaussLik, meanfunc, covfunc, likfunc, xtrain, ytrain, xtest);
toc

MSE = MSE_question2(Mu);
fprintf('finishing calculating MSE, and the MSE is %f \n', MSE);

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
fill([xtest; flip(xtest, 1)], f, [7 7 7]/8)
hold on; 
plot(xtest, Mu, 'g');
title('data using mannal kernel function');