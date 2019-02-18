%HW2 - Q4 Locally Weighted Linear Regression

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

%standardize test data using params from training set
trainMean = mean(fishTrain(:,1:2));
trainStd = std(fishTrain(:,1:2));
test_holder = fishTest(:,1:2) - trainMean;
test_std = test_holder ./ trainStd;
[testr,testc] = size(test_std);
test_theta = ones([testr,1]);
test_std_bias = [test_theta test_std fishTest(:,3:3)];

local_models = [];
%calculate similarity matrix for each test observation
%append weights along the diagonal
for item = test_std_bias(:,1:3)'
    %generate similarity vector for local model
    my_similarities = [];
    for obs=fishTrain_std_bias(:,1:3)'
        element = get_sim(item,obs);
        my_similarities = [my_similarities element];
    end
    %convert sim vector to diagonal matrix
    sim_vec = diag(my_similarities);
    theta_vec = (fishTrain_std_bias(:,1:3)'*sim_vec...
        *fishTrain_std_bias(:,1:3))^(-1)...
    * (fishTrain_std_bias(:,1:3)'*sim_vec*fishTrain_std_bias(:,4:4));
    local_models = [local_models; theta_vec'];
end

local_pairs = [test_std_bias  local_models];
local_estimates = [];

for i=local_pairs'
    local_e = i(1:3,:)'*i(5:7,:);
    local_estimates = [local_estimates; local_e];
end

local_results = [test_std_bias local_estimates...
    (test_std_bias(:,4) - local_estimates).^2];

RMSE = sqrt(mean(local_results(:,6:6)))

% point weighting logic
function similarity = get_sim(A,B)
    dist = L1distance(A,B);
    similarity = exp(-1*dist);
end

%generalized standardization function
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
