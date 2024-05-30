function zp = Chan_3D (nbs,baseStation,wn,d)
    % 2020217825 in hfut
    % 2024.04.17
    % input: 
    % baseStation:各个基站位置
    % baseStation(1,1) = x1, baseStation(1,2) = y1, baseStation(1,3) = z1
    % [x1,y1,z1
    %  x2,y2,z2
    %  ...     ]
    % wn:噪声功率
    % d : 各个TDOA 
    % [0 d21 d31 ...]
    % zp:[x0   y0  z0   % 第一次估计
    %     x1   y1  z1]  % 最终估计
    %initialization
    h = zeros(nbs-1, 1);
    x1 = baseStation(1,1);
    y1 = baseStation(1,2);
    z1 = baseStation(1,3);
    zp = zeros(2,3);

    for i=1:nbs
        K(i) = baseStation(i,1)^2 + baseStation(i,2)^2 + baseStation(i,3)^2; % [K1 K2 ...]
        Xi1(i) = baseStation(i,1)-x1; % [x11 x21 ...]
        Yi1(i) = baseStation(i,2)-y1; % [y11 y21 ...]
        Zi1(i) = baseStation(i,3)-z1; % [z11 z21 ...]

    end

    Q = 0.5 * ones(nbs-1, nbs-1);
    for i =1:nbs-1
        Q(i,i) = 1;
    end
    if wn==0
        Q = Q;
    else
        Q = Q * wn;
    end
    % or Q = cov(R')
    % 距离差
    c = 343200;  %声速
    rj1 = c * d;   % [0,r21,r31...]
    
    % h Ga
    
    for i = 1:nbs-1
        h(i,1) = 0.5 * (rj1(i+1)^2-K(i+1)+K(1));
        Ga(i,1) = -(Xi1(i+1));
        Ga(i,2) = -(Yi1(i+1));
        Ga(i,3) = -(Zi1(i+1));
        Ga(i,4) = -(rj1(i+1));
    end

    % first use (14b) to obtain an initial solution to estimate B
    Za_0 = pinv(Ga'*pinv(Q)*Ga)*Ga'*pinv(Q)*h;
    % Za = [x
    %       y
    %       r1]

    % ri0
    for i = 1:nbs
        ri0(i) = sqrt((baseStation(i,1)-Za_0(1,1))^2 + (baseStation(i,2)-Za_0(2,1))^2 + (baseStation(i,3)-Za_0(3,1))^2);
    end
    % B
    for i = 1:nbs-1
        B(i,i) = ri0(i+1);
    end

    PHI = c^2*B*Q*B;

    % The final answer (first WLS) is then computed from (14a).
    Za_1 = pinv(Ga'*pinv(PHI)*Ga)*Ga'*pinv(PHI)*h;
    Za_r1 = Za_1';
    zp(1,:) = Za_r1(1:3);
    % Za_1 = [x
    %         y
    %         z
    %         r1]
    Ga0 = Ga; % 估计

    cov_za = pinv(Ga0'*pinv(PHI)*Ga0);

    Za1 = Za_1(1,1); % x
    Za2 = Za_1(2,1); % y
    Za3 = Za_1(3,1); % z
    Za4 = Za_1(4,1); % r1

    h_l(1,1) =  (Za1-x1)^2;
    h_l(2,1) =  (Za2-y1)^2;
    h_l(3,1) =  (Za3-y1)^2;
    h_l(4,1) =  Za4^2;

    Ga_l = [1,0,0;
            0,1,0;
            0,0,1;
            1,1,1];
    x0 = Za1;
    y0 = Za2;
    z0 = Za3;
    r10 = Za4;
    % B'
    B_l = diag([x0-x1,y0-y1,z0-z1,r10]);

    % Φ'
    PHI_l = 4*B_l*cov_za*B_l;

    %za'
    za_l = pinv(Ga_l'*pinv(PHI_l)*Ga_l)*Ga_l'*pinv(PHI_l)*h_l;

    % 计算偏移矩阵
    Offset = [Za1 - x1, 0 ,0;
              0, Za2 - y1, 0;
              0, 0 ,Za3 - z1];
    
    
    % 计算最终位置 zp
    z_p = sign(Offset) .* sqrt(abs(za_l)) + [x1; y1; z1];
    zp(2,:)= [x1+z_p(1,1); y1+z_p(2,2);z1+z_p(3,3)];
    
end