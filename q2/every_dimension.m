clear all; clc; close all;
load('planecontrol.mat');

MSE = zeros(1, 40);
Mu = zeros(3750, 40);
fprintf('start calculating MSEs... \n');
for i = 1 : 40
     [MSE(i), Mu(:, i)] = one_dimension(i, 100);
     fprintf('finish calculating MSE of channel ¡¾%d¡¿ , and the MSE is ¡¾%f¡¿ \n', i, MSE(i));
end


figure(1)
for i = 1 : 40
    plot(xtrain([1 : 100],i)+i*100);
    hold on;
end
plot(ytrain([1 : 100],1)*1000);

% this picture show the comparion of train and test
figure(2)
subplot(1,2,1);
show = 100; % the length of the point to be shown
show_channel = 7;
plot(xtrain([1 : show],show_channel)*100+1000);
hold on
plot(ytrain([1 : show], 1)*500-1000);
axis([0 show -2500 1000]);
subplot(1,2,2);
plot(xtest([1 : show],show_channel)*100+1000);
hold on
plot(Mu([1 : show], show_channel)*500-1000);
axis([0 show -2500 1000]);

figure(3)
plot(xtest([1 : show],1));
hold on
for i = 1 : 40
   plot(Mu([1 : show], i)*1000 - i*1000);
end
figure(4)
plot(MSE);

% figure(5)
% for i = 1 : 10
%     for j = 1 : 40
%         [MSE(j), Mu(:, j)] = data_read_and_MSE(j, 10*i);
%         fprintf('finish calculating MSE of channel ¡¾%d¡¿ , and the MSE is ¡¾%f¡¿ \n', j, MSE(j));
%     end;
%     fprintf('---------------------------  finish calculating MSE of data ¡¾1 : %d¡¿---------------------------------\n', 100*i);
%     hold on
%     plot(MSE);
% end

figure(6)
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

figure(7)
for i = 1 : 40
    sort_channel = i;
    combine_train = [xtest Mu(:, i)];
    combine_train = sortrows(combine_train, sort_channel);
    xtest_new = combine_train(:, 1:40);
    mu_new = combine_train(:, 41);
    
    subplot(5,8,i);
    show = 1000; % the length of the point to be shown
    show_channel = i;
    plot(xtest_new([1 : show], show_channel));
    hold on
    plot(mu_new([1 : show], 1));
end

figure(8)
for i = 1 : 40
    subplot(5,8,i);
    show = 1000; % the length of the point to be shown
    show_channel = i;
    plot(xtest([1 : show], show_channel));
    hold on
    plot(Mu([1 : show], i));
    temp(:, i) = mu_new;
end






 