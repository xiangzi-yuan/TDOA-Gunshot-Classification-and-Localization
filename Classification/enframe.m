function [f,t,eng,zcr]=enframe(x,win,inc)
%ENFRAME split signal up into (overlapping) frames: one per row. [F,T]=(X,WIN,INC)
%
%	F = ENFRAME(X,LEN) splits the vector X(:) up into
%	frames. Each frame is of length LEN and occupies
%	one row of the output matrix. The last few frames of X
%	will be ignored if its length is not divisible by LEN.
%	It is an error if X is shorter than LEN.
%
%	F = ENFRAME(X,LEN,INC) has frames beginning at increments of INC
%	The centre of frame I is X((I-1)*INC+(LEN+1)/2) for I=1,2,...
%	The number of frames is fix((length(X)-LEN+INC)/INC)
%
%	F = ENFRAME(X,WINDOW) or ENFRAME(X,WINDOW,INC) multiplies
%	each frame by WINDOW(:)
%
%   The second output argument, T, gives the time in samples at the centre
%   of each frame. T=i corresponds to the time of sample X(i). 
%

nx=length(x);
nwin=length(win);

%%如果nwin=1的话，则win是一个数字而非向量，例如win=9，但是len(nwin)=1,所以生成正常矩形窗
%%如果 win 是单一整数，那么这个整数就被用作窗口长度（len），并且窗口向量需要在函数内部根据这个长度来生成。
%%如果 win 是一个向量，那么这个向量本身就被视为窗口，并且其长度（nwin）被用作窗口长度（len）。
if (nwin == 1)
   len = win;
else
   len = nwin;
end
if (nargin < 3) % 参数小于3个，未指定步长，则步长默认为窗口长度，即不重叠
   inc = len;
end
%%nargin 是一个内置的函数，用于返回当前函数调用时提供的输入参数个数。当在函数内部使用时，
% 它可以帮助确定调用者给函数传递了多少个参数，这使得函数能够根据传入参数的数量执行不同的逻辑。

len = nwin;
nf = fix((nx-len+inc)/inc);
f=zeros(nf,len);
indf= inc*(0:(nf-1)).';
inds = (1:len);
f(:) = x(indf(:,ones(1,len))+inds(ones(nf,1),:));
if (nwin > 1)
    w = win(:)';
    f = f .* w(ones(nf,1),:);
end

t = floor((1+len)/2)+indf;
%fprintf('size of f\n');
szf = size(f);
% ff = f(:).*f(:);
for i = 1:szf(1)
    %ff = f(i,:).*f(i,:)
%     ff = abs(f(i,:));
%     eng(i) = sum(ff);
    eng(i) = 0;
    zcr(i) = 0;
    for j = 1:szf(2)
        eng(i) = eng(i)+abs(f(i,j));
        if j+1 <= szf(2)
            zcr(i) = zcr(i)+abs(sign(f(i,j+1))-sign(f(i,j)));
        end
    end
    zcr(i) = 0.5*zcr(i);
end

