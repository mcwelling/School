%HW 2 - scratchpad

q1_data = [-2,1;
          -5,-4;
          -3,1;
          0,3;
          -8,11;
          -2,5;
          1,0;
          5,-1;
          -1,-3;
          6,1;];
      
q1_theta = [1;1;1;1;1;1;1;1;1;1;];
q1_std = standardize(q1_data);
q1_std = [q1_std(:,1) q1_data(:,2)];
q1_plus = [q1_theta q1_std];

my_theta = ((q1_plus(:,1:2)'*q1_plus(:,1:2))^(-1)) * (q1_plus(:,1:2)' * q1_plus(:,3:3));

predictions = q1_plus(:,1:2) * my_theta;
my_estimates = [q1_plus predictions ((q1_plus(:,3) - predictions).^(2))]

q1_std_theta = [q1_theta q1_std(:,1:1) q1_data(:,2:2)];


estimates = [];

for item = q1_std_theta(:,2)'
    estimates = [estimates; my_theta(1,:)*1 + my_theta(2,:)*item]; 
end

result = [q1_std_theta estimates (q1_std_theta(:,3:3) - estimates)];

figure;
scatter(result(:,2:2), result(:,4:4),15,'b')
hold on
scatter(result(:,2:2),result(:,3:3),15,'r')
hold off

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
