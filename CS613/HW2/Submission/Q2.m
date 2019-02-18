%HW2 - Q2 Closed Form Linear Regression

%read the data in
path = './x06Simple.csv';
fish = csvread(path,2,1);

%randomize the data
rng('default');
rng(0);
fish_randomized = fish(randperm(size(fish,1)),:);

%train test split (train: 67%, test: 33%)
cv = cvpartition(size(fish_randomized,1),'HoldOut',0.67);
idx = cv.test;
fishTrain = fish_randomized(~idx,:);
fishTest  = fish_randomized(idx,:);

%standardize the data except for the last column
fish_std = standardize(fishTrain(:,1:2));
fishTrain_std = [fish_std fishTrain(:,3)];

%append bias vector
theta_zero = ones([length(fishTrain_std),1]);
fishTrain_std_bias = [theta_zero fishTrain_std];

%compute closed form solution
theta_vec = (fishTrain_std_bias(:,1:3)'*fishTrain_std_bias(:,1:3))^(-1)...
    * (fishTrain_std_bias(:,1:3)'*fishTrain_std_bias(:,4:4));

%standardize test data using params from training data
trainMean = mean(fishTrain(:,1:2));
trainStd = std(fishTrain(:,1:2));
test_holder = fishTest(:,1:2) - trainMean;
fishTest_std = test_holder ./ trainStd;
test_theta = ones([length(fishTest_std),1]);
fishTest_std_bias = [test_theta fishTest_std fishTest(:,3:3)];

estimates = fishTest_std_bias(:,1:3) * theta_vec;

result = [fishTest_std_bias estimates (fishTest_std_bias(:,4:4) - estimates).^2];

RMSE = sqrt(mean(result(:,6:6)));

RMSE
disp(num2str(theta_vec,'%.2f'))

figure;
scatter3(result(:,2:2), result(:,3:3), result(:,4:4),15,'b')
hold on
scatter3(result(:,2:2),result(:,3:3),result(:,5:5),15,'r')
hold off

%generalized standardization function
function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end

