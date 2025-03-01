function zp = Chan_2D (nbs,baseStation,wn,d)
    % 2020217825 in hfut
    % 2024.04.16
    % input: 
    % baseStation:各个基站位置
    % baseStation(1,1) = x1, baseStation(1,2) = y1
    % [x1,y1
    %  x2,y2
    %  ... ]
    % wn:噪声功率
    % d : 各个TDOA 
    % [0 d21 d31 ...]
    
    %initialization
    h = zeros(nbs-1, 1);
    x1 = baseStation(1,1);
    y1 = baseStation(1,2);


    for i=1:nbs
        K(i) = baseStation(i,1)^2 + baseStation(i,2)^2; % [K1 K2 ...]
        Xi1(i) = baseStation(i,1)-x1; % [x11 x21 ...]
        Yi1(i) = baseStation(i,2)-y1; % [y11 y21 ...]

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
    
    % 距离差
    c = 342000;  %声速
    rj1 = c * d;   % [0,r21,r31...]
    
    % h Ga
    
    for i = 1:nbs-1
        h(i,1) = 0.5 * (rj1(i+1)^2-K(i+1)+K(1));
        Ga(i,1) = -(Xi1(i+1));
        Ga(i,2) = -(Yi1(i+1));
        Ga(i,3) = -(rj1(i+1));
    end

    % first use (14b) to obtain an initial solution to estimate B
    Za_0 = inv(Ga'*inv(Q)*Ga)*Ga'*inv(Q)*h;
    % Za = [x
    %       y
    %       r1]

    % ri0
    for i = 1:nbs
        ri0(i) = sqrt((baseStation(i,1)-Za_0(1,1))^2+(baseStation(i,2)-Za_0(2,1))^2);
    end
    % B
    for i = 1:nbs-1
        B(i,i) = ri0(i+1);
    end

    PHI = c^2*B*Q*B;

    % The final answer (first WLS) is then computed from (14a).
    Za_1 = inv(Ga'*inv(PHI)*Ga)*Ga'*inv(PHI)*h;
    % Za = [x
    %       y
    %       r1]
    Ga0 = Ga; % 估计

    cov_za = inv(Ga0'*inv(PHI)*Ga0);

    Za1 = Za_1(1,1);
    Za2 = Za_1(2,1);
    Za3 = Za_1(3,1);

    h_l(1,1) =  (Za1-x1)^2;
    h_l(2,1) =  (Za2-y1)^2;
    h_l(3,1) =  Za3^2;

    Ga_l = [1,0;
            0,1;
            1,1];
    x0 = Za1;
    y0 = Za2;
    r10 = Za3;
    % B'
    B_l = diag([x0-x1,y0-y1,r10]);

    % Φ'
    PHI_l = 4*B_l*cov_za*B_l;

    %za'
    za_l = inv(Ga_l'*inv(PHI_l)*Ga_l)*Ga_l'*inv(PHI_l)*h_l;

    % 计算偏移矩阵
    Offset = [Za1 - x1, 0; 0, Za2 - y1];
    
    
    % 计算最终位置 zp
    z_p = sign(Offset) .* sqrt(abs(za_l)) + [x1; y1];
    zp = [x1+z_p(1,1); y1+z_p(2,2)];

end