% Final Project - Logistic Batch Gradient Ascent for HCAHPS

%clear all;

% read the data in
path = 'hcahps.csv';
my_data = csvread(path,2,1);

% randomize the data
rng('default');
rng(0);
data_randomized = my_data(randperm(size(my_data,1)),:);
data_randomized = [data_randomized(:,2:end) data_randomized(:,1)];
for row=1:size(data_randomized,1)
    if data_randomized(row,end) == 1
        data_randomized(row,end) = 0;
    else
        data_randomized(row,end) = 1;
    end
end

% learning rate & parameter size
lrn = 0.01;
param_size = size(data_randomized);

% train test split (train: 67%, test: 33%)
cv = cvpartition(size(data_randomized,1),'HoldOut',0.33);
idx = cv.test;
dataTrain = data_randomized(~idx,:);
dataTest  = data_randomized(idx,:);

%standardize training set
trainSubset = dataTrain(:,1:end-1);
esp = 1*10^(-10);
mnTrain = mean(trainSubset);
sdTrain = std(trainSubset);
std_train = dataTrain(:,end-1) - mnTrain;
std_train = std_train ./ (sdTrain + eps);
dataTrain = [std_train dataTrain(:,end)];

%standardize testing set
std_test = dataTest(:,1:end-1) - mnTrain;
std_test = std_test ./ (sdTrain + eps);
dataTest = [std_test dataTest(:,end)];

% append bias vector to training set
theta_zero = ones([length(dataTrain),1]);
dataTrain_bias = [theta_zero dataTrain];

% append bias vector to test set
[testr,testc] = size(dataTest);
test_theta = ones([testr,1]);
test_bias = [test_theta dataTest];

% dimensions of updated train/test matrices
test_spec = size(test_bias);
train_spec = size(dataTrain_bias);

% set initial parameters
lower = -1;
upper = 1;
current_theta = (upper-lower).*rand(train_spec(:,2)-1,1) + lower;

% compute preliminary estimates
init_estimates = est(dataTrain_bias(:,1:end-1), current_theta);

% concatenate estimates to the data matrix, get size
init_mtrx = [dataTrain_bias init_estimates];
im_size = size(init_mtrx);

% compute gradient, log likelihood
gradient = grad(init_mtrx(:,1:im_size(:,2)-2),...
    init_mtrx(:,im_size(:,2)-1),current_theta);
log_likelihood = logl(init_mtrx(:,1:im_size(:,2)-2),...
    init_mtrx(:,im_size(:,2)),current_theta);

% step along gradient by factor of learning rate - update theta
prev_train_logl = 0;
cur_train_logl = log_likelihood;
cur_test_logl = 0;
prev_test_logl = 0;
prev_theta = current_theta;
current_theta = current_theta + lrn * gradient;
train_logls = [];
test_logls = [];
CYCLE_CNT = 0;

%abs((cur_train_logl-prev_train_logl)/prev_train_logl) >= 2^(-23)

while abs(cur_train_logl-prev_train_logl) >= 2^(-43) ...
        && CYCLE_CNT <= 10000
    x_train = dataTrain_bias(:,1:end-1);
    y_train = dataTrain_bias(:,size(dataTrain_bias,2));
    x_test = test_bias(:,1:end-1);
    y_test = test_bias(:,size(test_bias,2));
    
    % compute log likelihood for current model params, update comparison vec
    prev_train_logl = cur_train_logl;   %specific to training set
    cur_train_logl = logl(x_train, y_train, current_theta);
    train_logls = [train_logls; cur_train_logl];
    
    % compute log likelihood for test data, because... we have to graph it later
    prev_test_logl = cur_test_logl;
    cur_test_logl = logl(x_test, y_test, current_theta);
    test_logls = [test_logls; cur_test_logl];
    
    % compute gradient
    train_grad = grad(x_train, y_train, current_theta);

    % step along gradient by factor of learning rate - update theta
    prev_theta = current_theta;
    current_theta = current_theta - lrn * train_grad;
    
    % tune learning param
    %if cur_train_logl > prev_train_logl
    %    lrn = lrn + lrn*0.05;
    %else
    %    current_theta = prev_theta;
    %    lrn = lrn * 0.5;
    %end
        
    % update cycle count
    CYCLE_CNT = CYCLE_CNT + 1;
    
end

% test out model
results = est(test_bias(:,1:end-1), current_theta);
validate = [test_bias(:,end) results];

% classification threshold
for row=1:size(validate,1)
    if validate(row,2) < .75
        validate(row,2) = 0;
    else
        validate(row,2) = 1;
    end
end

figure;
[Xpr,Ypr,Tpr,AUCpr] = perfcurve(test_bias(:,end), results, 1, 'xCrit', 'reca', 'yCrit', 'prec');
plot(Xpr,Ypr)
xlabel('Recall'); ylabel('Precision')
title(['Precision-recall curve (AUC: ' num2str(AUCpr) ')'])

figure;
horiz = [1:CYCLE_CNT];
plot(horiz,train_logls,'r')
hold on
plot(horiz,test_logls,'b')
hold off
title('Training and Testing Log Likelihood sum as a function of iteration')
xlabel('Iteration')
ylabel('Sum Log Likelihood')

% calculate base performance measures
pos_vals = validate(validate(:,1) == 1,:);
neg_vals = validate(validate(:,1) == 0,:);
tp = size(pos_vals(pos_vals(:,2) == 1),1);
fn = size(pos_vals(pos_vals(:,2) == 0),1);
tn = size(neg_vals(neg_vals(:,2) == 0),1);
fp = size(neg_vals(neg_vals(:,2) == 1),1);

% calculate precision (tp/(tp+fp))
precision = get_prec(tp,fp)

% calculate recall (tp/(tp + fn))
recall = get_rec(tp,fn)

% calc F-measure (2*precision*recall)/(precision + recall)
f_measure = get_f(precision,recall)

% calc accuracy ((tp+tn)/(tp+tn+fp+fn))
accuracy = get_acc(tp,tn,fp,fn)
tp
fp
tn
fn

figure;
cm = confusionchart([tn,fp;fn,tp;],[0,1]);
%xlabel('False positive rate') 
%ylabel('True positive rate')
title('Confusion Matrix (1=unsatisfied)');

%%%%%%%%%%%%%
% Functions %
%%%%%%%%%%%%%

% get precision
function precision = get_prec(tp,fp)
    precision = tp/(tp+fp);
end

% get recall
function recall = get_rec(tp,fn)
    recall = tp/(tp+fn);
end

% get accuracy
function accuracy = get_acc(tp,tn,fp,fn)
    accuracy = (tp+tn)/(tp+tn+fp+fn);
end

% get fmeasure
function fmeasure = get_f(prec,rec)
    fmeasure = (2*prec*rec)/(prec + rec);
end
    
% sigmoid function
function sigmoid = sig(z)
    sigmoid = 1 ./ (1+exp(-1*z));
end

% compute gradient
function gradient = grad(x,y,theta)
    % compute number of rows in dataset
    N = size(x,1);
    % compute simgmoid
    beta = sig(x * theta);
    gradient = (1/N) * x' * (y - beta);
end

% compute log likelihood
function likelihood = logl(x, y, theta)
    N = size(x,1);
    epsilon = 1 * 10^(-10);
    sigma = sig(x * theta);
    likelihoods = [];
    for row=1:N
        ll = y(row)' * log(sigma(row) + epsilon)...
            + (1 - y(row))' * log(1 - sigma(row) + epsilon);
        likelihoods = [likelihoods; ll];
    end
    likelihood = sum(likelihoods);
end

function estimates = est(x, theta)
    container = sig(x * theta);
    estimates = container;
end

% generalized standardization function
function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end