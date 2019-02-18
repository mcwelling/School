M = [-2,1;
	-5,-4;	
	-3,1;
	0,3;
	-8,11;
    -2,5;
	1,0;
	5,-1;
	-1,-3;
	6,1;];

J = [1,2,3;10,5,6;];

T = [1;1;1;1;1;0;0;0;0;0;];
stan = standardize(M);

class_1 = stan(1:5,:);
class_2 = stan(6:10,:);

mn_1 = mean(class_1);
mn_2 = mean(class_2);

scatter_1 = 4 * cov(class_1);
scatter_2 = 4 * cov(class_2);

inter = scatter_1 + scatter_2;

inverse = inv(inter);

between = (mn_1 - mn_2)' * (mn_1 - mn_2);

sol = inverse * between;

[V,D] = eig(sol);
projection = stan * V(:,1:1);

my_data = [projection T];

%temp_mat = magic(4)
%temp_vec = (14:17)'
%threshold = 13;
%idx = any(temp_mat > threshold,2);
%temp_vec(idx)

%gscatter(my_data(:,1:1),my_data(:,2:2));

L2distance(J(1,:)',J(2,:)')


%principals(M)

function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end


%pca function
function p = principals(A)
    cvm = cov(A);
    vals = eig(cvm);
    [V,D] = eig(cvm);
    total = sum(vals);
    temp = 0;
    counter = 0;
    
    %for loop to determine # of vecs needed for 95% info retention
    for i = vals'
        if temp >= (total * .95)
            break;
        end
        counter = counter + 1;
        temp = temp + i;
    end
    
    %controls for case in which counter exceeds len
    if counter > length(vals)
        B = V;
    else
        B = V(:,1:counter);
    end
    p = A * B;
end

function d = L2distance(A,B)
    dims_A = size(A');
    dims_B = size(B');
    if dims_A(:,2) > 3 || dims_B(:,2) > 3
        disp("dimensionality too high - run PCA")
        return;
    end
    if dims_A(:,2) ~= dims_B(:,2)
        disp("dimensional imbalance between A and B")
        return;
    end
    if dims_A(:,2) == 1 && dims_B(:,2) == 1
        dist_sq = (A(1,:) - B(1,:))^2;
        dist = sqrt(dist_sq);
    end
    if dims_A(:,2) == 2 && dims_B(:,2) == 2
        dist_sq = (A(1,:) - B(1,:))^2 + (A(2,:) - B(2,:))^2;
        dist = sqrt(dist_sq);
    end
    if dims_A(:,2) == 3 && dims_B(:,2) == 3
        dist_sq = (A(1,:) - B(1,:))^2 + (A(2,:) - B(2,:))^2 + (A(3,:) - B(3,:))^2;
        dist = sqrt(dist_sq);
    end
    d = dist;
end
