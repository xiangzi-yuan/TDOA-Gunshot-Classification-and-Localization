function [post,act]=calcpost(mix,x)
% 计算后验概率和激活值
% 激活值通常是指给定数据点x在第j个高斯分布下的概率密度值
% 在GMM中，后验概率用于表示给定观测数据后，数据点属于某个特定高斯分布的概率。
[dim,data_sz]=size(x');
ndata=size(x,1);
act=zeros(data_sz,mix.ncentres); %正态分布 N(mu,covar)

switch mix.covar_type
case 'diag'
  normal=(2*pi)^(dim/2);
  s=prod(sqrt(mix.covars),2);
  for j=1:mix.ncentres
    diffs=x-(ones(data_sz,1)*mix.centres(j,:));
    act(:,j)=exp(-0.5*sum((diffs.*diffs)./(ones(data_sz,1)*...
      mix.covars(j,:)),2))./(normal*s(j));
  end       
case 'full'
  normal=(2*pi)^(dim/2);
  %---计算N(j),j=1,...,mix.ncentres---
  for j=1:mix.ncentres
   diffs=x-(ones(data_sz,1)*mix.centres(j,:));
   c=chol(mix.covars(:,:,j));
   temp=diffs/c;
   act(:,j)=exp(-0.5*sum(temp.*temp,2))./(normal*prod(diag(c)));
  end  
otherwise
  error(['Unknown covariance type ', mix.covar_type]);
end

post=(ones(data_sz,1)*mix.priors).*act;
s=sum(post,2); %计算分母项
if any(s==0)
   warning('Some zero posterior probabilities')
   % Set any zeros to one before dividing
   zero_rows=find(s==0);
   s=s+(s==0);
   post(zero_rows,:)=1/mix.ncentres;
end
post=post./(s*ones(1,mix.ncentres));