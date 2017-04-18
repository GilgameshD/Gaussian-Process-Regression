%providing an arbitrary starting place
starting_place = [1;1;1;1;1];

%printing the log likelihood using arbitrary values
disp('Initial log likelihood for arbitrary parameters-');
disp(training_function(starting_place));

[hyperparameters, likelihood] = fminsearch(@training_function, starting_place, []);

%Printing the optimal values for the hyperparameters
disp('Optimal hyperparameters sigma_f,l, and sigma_n-');
disp(hyperparameters);

%Printing the minimized log likelihood function
disp('Minimized log-likelihood function');
disp(likelihood);

