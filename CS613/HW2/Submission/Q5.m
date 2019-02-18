%HW2 - Q5 Gradient Descent

% read the data in
path = './x06Simple.csv';
fish = csvread(path,2,1);

% randomize the data
rng('default');
rng(0);
fish_randomized = fish(randperm(size(fish,1)),:);

% learning rate & parameter size
lrn = 0.01;
param_size = size(fish_randomized);

% train test split (train: 67%, test: 33%)
cv = cvpartition(size(fish_randomized,1),'HoldOut',0.67);
idx = cv.test;
fishTrain = fish_randomized(~idx,:);
fishTest  = fish_randomized(idx,:);

%standardize the data except for the last column
fish_std = standardize(fishTrain(:,1:param_size(:,2:2)-1));
fishTrain_std = [fish_std fishTrain(:,param_size(:,2:2))];

% append bias vector
theta_zero = ones([length(fishTrain_std),1]);
fishTrain_std_bias = [theta_zero fishTrain_std];

% standardize test data using params from training set
trainMean = mean(fishTrain(:,1:param_size(:,2:2)-1));
trainStd = std(fishTrain(:,1:param_size(:,2:2)-1));
test_holder = fishTest(:,1:param_size(:,2:2)-1) - trainMean;
test_std = test_holder ./ trainStd;
[testr,testc] = size(test_std);
test_theta = ones([testr,1]);
test_std_bias = [test_theta test_std fishTest(:,param_size(:,2:2))];

% dimensions of updated train/test matrices
test_spec = size(test_std_bias);
train_spec = size(fishTrain_std_bias);

% set initial parameters
lower = -1;
upper = 1;
current_theta = (upper-lower).*rand(train_spec(:,2:2)-1,1) + lower;

% compute preliminary RMSE based on init model params
init_estimates = fishTrain_std_bias(:,1:train_spec(:,2:2)-1) * current_theta;

% concatenate estimates to the data matrix, compute squared error, get size
init_mtrx = [fishTrain_std_bias init_estimates ...
    (fishTrain_std_bias(:,train_spec(:,2:2)) - init_estimates).^2];
init_mtrx_size = size(init_mtrx);

% isolate init squared errors, calculate init RMSE
init_SE = init_mtrx(:,init_mtrx_size(:,2));
init_RMSE = sqrt(mean(init_SE));

% compute gradient
gradient = fishTrain_std_bias(:,1:train_spec(:,2:2)-1)'...
    * (fishTrain_std_bias(:,1:train_spec(:,2:2)-1)...
    * current_theta - fishTrain_std_bias(:,train_spec(:,2:2)));

% step along gradient by factor of learning rate - update theta
current_theta = current_theta - lrn/train_spec(:,2:2) * gradient;

% vars to store cycle / RMSE data
RMSE_COMP = [1.0; init_RMSE];
CYCLE_CNT = 0;
TRAIN_RMSE_VEC = [];
TEST_RMSE_VEC = [];

while abs((RMSE_COMP(2:2,:)-RMSE_COMP(1:1,:))/RMSE_COMP(1:1,:)) >= 2^(-23) ...
        && CYCLE_CNT <= 1000000
    % compute RMSE for current model params, update comparison vec
    estimates = fishTrain_std_bias(:,1:train_spec(:,2:2)-1) * current_theta;
    estimate_mtrx = [fishTrain_std_bias estimates ...
    (fishTrain_std_bias(:,train_spec(:,2:2)) - estimates).^2];
    estimate_mtrx_size = size(estimate_mtrx);
    estimate_SE = estimate_mtrx(:,estimate_mtrx_size(:,2));
    estimate_RMSE = sqrt(mean(estimate_SE));
    RMSE_COMP = [RMSE_COMP(2,:); estimate_RMSE];
    TRAIN_RMSE_VEC = [TRAIN_RMSE_VEC; estimate_RMSE];

    % compute RMSE for test data, because... we have to graph it later
    testimates = test_std_bias(:,1:test_spec(:,2:2)-1) * current_theta;
    testimate_mtrx = [test_std_bias testimates ...
    (test_std_bias(:,test_spec(:,2:2)) - testimates).^2];
    testimate_mtrx_size = size(testimate_mtrx);
    testimate_SE = testimate_mtrx(:,testimate_mtrx_size(:,2));
    testimate_RMSE = sqrt(mean(testimate_SE));
    TEST_RMSE_VEC = [TEST_RMSE_VEC; testimate_RMSE];

    % compute gradient
    gradient = fishTrain_std_bias(:,1:train_spec(:,2:2)-1)'...
        * (fishTrain_std_bias(:,1:train_spec(:,2:2)-1)...
        * current_theta - fishTrain_std_bias(:,train_spec(:,2:2)));

    % step along gradient by factor of learning rate - update theta
    current_theta = current_theta - lrn/train_spec(:,2:2) * gradient;

    % update cycle count
    CYCLE_CNT = CYCLE_CNT + 1;
end


disp('Iteration number:')
disp(num2str(CYCLE_CNT,'%.2f'))
disp(newline)
disp('Final model:')
disp(num2str(current_theta,'%.2f'))
disp(newline)
disp('RMSE:')
disp(num2str(RMSE_COMP(2),'%.2f'))

figure;
horiz = [1:length(TRAIN_RMSE_VEC)];
plot(horiz,TRAIN_RMSE_VEC,'r')
hold on
plot(horiz,TEST_RMSE_VEC,'b')
hold off
title('Training and Testing RMSE as a function of iteration (225 total)')
xlabel('Iteration')
ylabel('RMSE')

% generalized standardization function
function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end

% euclid distnce between two column vecs
function DI = L2distance(A,B)
    dims_A = size(A');
    dims_B = size(B');
    %if dims_A(:,2) > 3 || dims_B(:,2) > 3
    %    disp("dimensionality too high - run PCA")
    %    return;
    %end
    %if dims_A(:,2) ~= dims_B(:,2)
    %    disp("dimensional imbalance between A and B")
    %    return;
    %end
    distance = 0;
    if dims_A(:,2) == 1 && dims_B(:,2) == 1
        dist_sq = (A(1,:) - B(1,:))^2;
        distance = sqrt(dist_sq);
    elseif dims_A(:,2) == 2 && dims_B(:,2) == 2
        dist_sq = (A(1,:) - B(1,:))^2 + (A(2,:) - B(2,:))^2;
        distance = sqrt(dist_sq);
    elseif dims_A(:,2) == 3 && dims_B(:,2) == 3
        dist_sq = (A(1,:) - B(1,:))^2 + (A(2,:) - B(2,:))^2 + (A(3,:) - B(3,:))^2;
        distance = sqrt(dist_sq);
    end
    DI = distance;
end

% manhattan distance between two column vecs
function mdist = L1distance(A,B)
    dims_A = size(A');
    dims_B = size(B');
    mdist = 0;
    if dims_A(:,2) > 3 || dims_B(:,2) > 3
        disp("dimensionality too high - run PCA")
        return;
    end
    if dims_A(:,2) ~= dims_B(:,2)
        disp("dimensional imbalance between A and B")
        return;
    end
    if dims_A(:,2) == 1 && dims_B(:,2) == 1
        mdist = sqrt((A(1,:) - B(1,:))^2);
    elseif dims_A(:,2) == 2 && dims_B(:,2) == 2
        mdist = sqrt((A(1,:) - B(1,:))^2) + sqrt((A(2,:) - B(2,:))^2);
    elseif dims_A(:,2) == 3 && dims_B(:,2) == 3
        mdist = sqrt((A(1,:) - B(1,:))^2) + sqrt((A(2,:) - B(2,:))^2) + sqrt((A(3,:) - B(3,:))^2);
    end
end