clc;clear;
nbs = 8;  % 传感器数量
baseStation = [0,0,0;
               0,150,0;
               150,0,0;
               150,150,0;
               0,0,150;
               150,0,150;
               150,150,150;
               0,150,150];

wn =0;
MS = [0, 500 , 100];  %目标位置
zp = distance_3D(nbs,baseStation,wn,MS)