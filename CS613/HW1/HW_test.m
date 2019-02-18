% script to for HW1 Q2, Q3, & Q4

%matrix to hold photos read in from directory
global df;
df=[]';

%loop to read photos from directory into matrix
photos='~/Documents/Datasets/yalefaces/';
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

%perform PCA to determine new dimensions
df_pca = principals(df_standard);

%Q2 project onto two dimensions and create a scatter plot
samp = df_standard * df_pca(:,1:2);
%scatter(samp(:,2),samp(:,1));

%Q3 show image of most important principal component
max_import = df_standard * df_pca(:,1:1);
mi = reshape(max_import,[40,40]);
%imshow(mi, []);

%Q3 show image projected into eigenspace via 1 eigenvec
kmost = df_standard * df_pca(:,1:1);
km = kmost * df_pca(:,1:1)';
recon = reshape(km(:,1),[40,40]);
%imshow(recon, []);

%Q3 show image projected into eigenspace with 95% info retention
kmost1 = df_standard * df_pca;
km1 = kmost1 * df_pca';
reconstruct = reshape(km1(:,1),[40,40]);
imshow(reconstruct, []);

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
    disp("Number of Eigenvectors needed for 95% information:")
    disp(counter)
    disp("Total Eigenvectors:")
    disp(length(vals))
    disp("Largest eigenvalue:")
    disp(max(vals))
    disp("Index of largest eigenval")
    disp(find(vals==max(vals)))
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
    my_data = standardize(X);
    dims = size(X);
    if dims(:,2:2) > 3
        my_pc = principals(my_data);
        my_data = my_data * my_pc(:,1:3);
    end
    mu = mean(X);
    sigma = std(X);
    rng('default');
    rng(1);
    refs = randi([1,length(M)],1,clust_count);
    %next step to randomly select ref vectors
    my_ref = [];
    for element = refs
        holder = element;
        my_ref = [my_ref ; X(holder,:)];
    end
    
    
end
    
    
function d = distance(A,B)
    dims_A = size(A');
    dims_B = size(B');
    if dims_A(:,2) ~= dims_b(:,2)
        disp("dimensional imbalance between A and B")
        return;
    else
        
    
end


