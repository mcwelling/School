%Author of this spaghetti: McWelling Todman
%Class: CS613 - Machine Learning
%Drexel University CCI - Winter 2019

%matrix to hold photos read in from directory
global df;
df=[]';

%loop to read photos from directory into matrix
photos='./yalefaces/';
S = dir(fullfile(photos,'subject*.*')); % pattern to match filenames.
for n=1:numel(S)
   F=fullfile(photos,S(n).name);
   p=imread(F);
   %q=double(p);
   r=imresize(p,[40,40]);
   j=reshape(r,[1600,1]);
   df = [df j];
   df = double(df);
end

%standardization of matrix
df_standard = standardize(df);

%if needed, perform dimensionality reduction
dimensions = size(df_standard);
if dimensions(:,2) > 3
    my_pc = principals(df_standard);
    my_data = df_standard * my_pc(:,1:3);
else
    my_data = df_standard;
end

%seed rng to 0
rng('default');
rng(0);

%function call to kMeans
myKMeans(my_data,5)

%generalized standardization function
function s = standardize(A)
    mn = mean(A);
    sd = std(A);
    holder = A - mn;
    s = holder ./ sd;
end

%pca function - returns matrix needed for 95% info retention
function p = principals(A)
    cvm = cov(A);
    vals = eig(cvm);
    vals = sort(vals, 'descend');
    [V,D] = eig(cvm);
    V = fliplr(V);
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
    %disp("Number of Eigenvectors needed for 95% information:")
    %disp(counter)
    %disp("Total Eigenvectors:")
    %disp(length(vals))
    %disp("Largest eigenvalue:")
    %disp(max(vals))
    %disp("Index of largest eigenval")
    %disp(find(vals==max(vals)))
    %controls for case in which counter exceeds len
    if counter > length(vals)
        B = V;
    else
        B = V(:,1:counter);
    end
    p = B;
end

%kmeans algorithm implementation
function k = myKMeans(X,k)
    clust_count = k;
    my_data = X;
    dims = size(X);
    if dims(1,:) < k
        disp("There cannot be more clusters than observations")
        return;
    end
    mu = mean(my_data);
    sigma = std(my_data);
    my_refs = [];
    my_labels = [];
    clean_labels = [];
    prev_centroids = 0;
    
    gen_refs(my_data, clust_count);
    gen_labels(my_data, my_refs);
    gen_centroids(my_data, my_labels);
    gen_labels(my_data, my_refs);
    
    while terminate(prev_centroids, my_refs) == 0
        gen_centroids(my_data, my_labels);
        gen_labels(my_data, my_refs);
        
        figure;
        if dims(:,2) == 3
            scatter3(my_data(:,1),my_data(:,2),my_data(:,3),5,my_labels,'x')
            hold on
            plot3(my_refs(:,1),my_refs(:,2),my_refs(:,3),'o','MarkerSize',15,'LineWidth',3)
            hold off
        elseif dims(:,2) == 2
            gscatter(my_data(:,1),my_data(:,2),5,my_labels,'x')
            hold on
            plot(my_refs(:,1),my_refs(:,2),'o','MarkerSize',15,'LineWidth',3)
            hold off
        end
    end
    
    function T = terminate(previous, current)
        old = previous';
        new = current';
        dist_sum = 0;
        for i=1:clust_count
            temp_dist = L1distance(old(:,i:i),new(:,i:i));
            dist_sum = dist_sum + temp_dist;
        end
        if old == 0
            T = 0;
        elseif dist_sum > 2^(-23)
            T = 0;
        else
            T = 1;
        end
    end 
    function gen_centroids(data, labels)
        dataset = [data labels];
        width = size(dataset);
        begin = width(:,2)/2 + 1;
        ending = width(:,2);
        new_refs = [];
        for item = my_refs'
            target = item';
            temp_array = [];
            for i=1:length(data)
                if labels(i,:) == target
                    temp_array = [temp_array; data(i,:)];
                end
            end
            new_refs = [new_refs; mean(temp_array)];
        end
        prev_centroids = my_refs;
        my_refs = new_refs;
    end
    function refers = gen_refs(data, clusters)
        refs = randi([1,length(data)],1,clusters);
        refers = [];
        for element = refs
            holder = element;
            refers = [refers; data(holder,:)];
        end
        my_refs = refers;
    end 
    function labels = gen_labels(data, ref_vecs)
        new_labels = [];
        for record = data'
            current_label = [];
            min_dist = Inf;
            for item = ref_vecs'
                temp_dist = L2distance(record, item);
                if temp_dist < min_dist
                    min_dist = temp_dist;
                    current_label = item';
                end
            end
            new_labels = [new_labels; current_label];
        end
        my_labels = new_labels;
    end            
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