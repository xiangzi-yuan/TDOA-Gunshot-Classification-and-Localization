function [centres, post, sumd] = k_means(data, k, kiter)
    [numData, dim] = size(data);
    % 随机选择初始中心点
    perm = randperm(numData);
    centres = data(perm(1:k), :);
    
    % 初始化变量
    oldCentres = zeros(size(centres));
    post = zeros(numData, k);
    sumd = zeros(1, k);  % 存储每个簇的距离和
    
    % 进行K-means迭代
    for iter = 1:kiter
        % 计算所有数据点到每个中心的距离
        distances = zeros(numData, k);
        for j = 1:k
            distances(:, j) = sum((data - centres(j, :)).^2, 2);
        end
        
        % 分配数据点到最近的中心
        [minDist, idx] = min(distances, [], 2);
        newPost = zeros(numData, k);
        for i = 1:numData
            newPost(i, idx(i)) = 1;
        end
        
        % 更新中心点
        for j = 1:k
            if any(idx == j)
                centres(j, :) = mean(data(idx == j, :), 1);
                sumd(j) = sum(minDist(idx == j));
            end
        end
        
        % 检查收敛（中心点变化很小）
        if max(max(abs(centres - oldCentres))) < 1e-4
            break;
        end
        oldCentres = centres;
        post = newPost;
    end
end
