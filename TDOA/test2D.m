nbs = 4;
baseStation = [0,0;
    450,0;
    0,300;
    450,300];
MS = [600, 0];

wn = 1;
c = 342000;
for i = 1: nbs
    R0(i) = sqrt((baseStation(i,1) - MS(1))^2 + (baseStation(i,2) - MS(2))^2); 
end
for i = 1: nbs
    d(i) = (R0(i) - R0(1) + wn * randn(1))/c; 
%     模拟时间差
end
% d = [0,delaytime(2),delaytime(3),delaytime(4)];
zp = Chan_2D(nbs,baseStation,wn,d);
fprintf('x = %.4f, y = %.4f',zp(1),zp(2))

