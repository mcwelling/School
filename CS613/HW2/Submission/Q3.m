%Q3 - s-fold cross validation

%read the data in
path = './x06Simple.csv';
fish = csvread(path,2,1);
partitions = 3;

RMSE_VEC = [];
for s=0:20
    seed = s;
    
    %randomize the data
    rng('default');
    rng(seed);
    fish_randomized = fish(randperm(size(fish,1)),:);
    
    %create s-fold object to coordinate testing
    CVO = cvpartition(length(fish_randomized),'KFold',partitions);
    %swap 'KFold' for 'HoldOut' and set partitions to 1 for leave-1-out
    
    %create vector to hold standard errors for RMSE calc
    SE_VEC = [];
    
    %loop train models
    for i=1:partitions
        idxTrain = CVO.training(i);
        idxTest = CVO.test(i);
        fishTrain = fish_randomized(idxTrain,:);
        fishTest = fish_randomized(idxTest,:);
        [trainr,trainc] = size(fishTrain);
        theta_zero = ones([trainr,1]);
        train_std_bias = [theta_zero, standardize(fishTrain(:,1:2)), fishTrain(:,3:3)];

        %compute closed form solution
        theta_vec = (train_std_bias(:,1:3)'*train_std_bias(:,1:3))^(-1)...
            * (train_std_bias(:,1:3)'*train_std_bias(:,4:4));
        
        %standardize test data using params from training set
        trainMean = mean(fishTrain(:,1:2));
        trainStd = std(fishTrain(:,1:2));
        test_holder = fishTest(:,1:2) - trainMean;
        test_std = test_holder ./ trainStd;
        [testr,testc] = size(test_std);
        test_theta = ones([testr,1]);
        test_std_bias = [test_theta test_std fishTest(:,3:3)];
        
        %generate vector of model estimates
        estimates = test_std_bias(:,1:3) * theta_vec;
        
        %concatenate estimates to the data matrix, compute squared error
        result = [test_std_bias estimates (test_std_bias(:,4:4) - estimates).^2];
        
        %isolate squared error and append to storage vector
        SE = result(:,6:6);
        SE_VEC = [SE_VEC; SE];
    end
    
    %calculate RMSE for SEs contained in storage, append result to RMSE vec
    RMSE = sqrt(mean(SE_VEC));
    RMSE_VEC = [RMSE_VEC; RMSE];
end

RMSE_mean = mean(RMSE_VEC)
RMSE_std = std(RMSE_VEC)


%generalized standardization function
function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end
    
    
