m = 200;
d = 25;

BS1 = [m, m, 0];
BS2 = [d + m, m, d];
BS3 = [-d/2 + m, -sqrt(3)/2 * d + m, d];
BS4 = [-d/2 + m, sqrt(3)/2 * d + m, d];
BS5 = [-d + m,  m, -d];
BS6 = [d/2 + m, -sqrt(3)/2 * d + m, -d];
BS7 = [d/2 + m, sqrt(3)/2 * d + m, -d];

positions = [BS1; BS2; BS3; BS4; BS5; BS6; BS7];
% 平移后的坐标
positions_translated = positions - [m, m, 0];
% 平移前的图
figure;
scatter3(positions(:,1), positions(:,2), positions(:,3), 'filled');
text(positions(:,1), positions(:,2), positions(:,3) + 0.1, ...
    {'BS1', 'BS2', 'BS3', 'BS4', 'BS5', 'BS6', 'BS7'}, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

hold on;
plot3([BS1(1) BS2(1)], [BS1(2) BS2(2)], [BS1(3) BS2(3)], 'k-');
plot3([BS1(1) BS3(1)], [BS1(2) BS3(2)], [BS1(3) BS3(3)], 'k-');
plot3([BS1(1) BS4(1)], [BS1(2) BS4(2)], [BS1(3) BS4(3)], 'k-');
plot3([BS2(1) BS3(1)], [BS2(2) BS3(2)], [BS2(3) BS3(3)], 'k-');
plot3([BS2(1) BS4(1)], [BS2(2) BS4(2)], [BS2(3) BS4(3)], 'k-');
plot3([BS3(1) BS4(1)], [BS3(2) BS4(2)], [BS3(3) BS4(3)], 'k-');
plot3([BS1(1) BS5(1)], [BS1(2) BS5(2)], [BS1(3) BS5(3)], 'k-');
plot3([BS1(1) BS6(1)], [BS1(2) BS6(2)], [BS1(3) BS6(3)], 'k-');
plot3([BS1(1) BS7(1)], [BS1(2) BS7(2)], [BS1(3) BS7(3)], 'k-');
plot3([BS5(1) BS6(1)], [BS5(2) BS6(2)], [BS5(3) BS6(3)], 'k-');
plot3([BS5(1) BS7(1)], [BS5(2) BS7(2)], [BS5(3) BS7(3)], 'k-');
plot3([BS6(1) BS7(1)], [BS6(2) BS7(2)], [BS6(3) BS7(3)], 'k-');

xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
title('平移前的双四面体结构');
view(-30, 10);

% 平移后的图
figure;
scatter3(positions_translated(:,1), positions_translated(:,2), positions_translated(:,3), 'filled');
text(positions_translated(:,1), positions_translated(:,2), positions_translated(:,3) + 0.1, ...
    {'BS1', 'BS2', 'BS3', 'BS4', 'BS5', 'BS6', 'BS7'}, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

hold on;
plot3([positions_translated(1,1) positions_translated(2,1)], [positions_translated(1,2) positions_translated(2,2)], [positions_translated(1,3) positions_translated(2,3)], 'k-');
plot3([positions_translated(1,1) positions_translated(3,1)], [positions_translated(1,2) positions_translated(3,2)], [positions_translated(1,3) positions_translated(3,3)], 'k-');
plot3([positions_translated(1,1) positions_translated(4,1)], [positions_translated(1,2) positions_translated(4,2)], [positions_translated(1,3) positions_translated(4,3)], 'k-');
plot3([positions_translated(2,1) positions_translated(3,1)], [positions_translated(2,2) positions_translated(3,2)], [positions_translated(2,3) positions_translated(3,3)], 'k-');
plot3([positions_translated(2,1) positions_translated(4,1)], [positions_translated(2,2) positions_translated(4,2)], [positions_translated(2,3) positions_translated(4,3)], 'k-');
plot3([positions_translated(3,1) positions_translated(4,1)], [positions_translated(3,2) positions_translated(4,2)], [positions_translated(3,3) positions_translated(4,3)], 'k-');
plot3([positions_translated(1,1) positions_translated(5,1)], [positions_translated(1,2) positions_translated(5,2)], [positions_translated(1,3) positions_translated(5,3)], 'k-');
plot3([positions_translated(1,1) positions_translated(6,1)], [positions_translated(1,2) positions_translated(6,2)], [positions_translated(1,3) positions_translated(6,3)], 'k-');
plot3([positions_translated(1,1) positions_translated(7,1)], [positions_translated(1,2) positions_translated(7,2)], [positions_translated(1,3) positions_translated(7,3)], 'k-');
plot3([positions_translated(5,1) positions_translated(6,1)], [positions_translated(5,2) positions_translated(6,2)], [positions_translated(5,3) positions_translated(6,3)], 'k-');
plot3([positions_translated(5,1) positions_translated(7,1)], [positions_translated(5,2) positions_translated(7,2)], [positions_translated(5,3) positions_translated(7,3)], 'k-');
plot3([positions_translated(6,1) positions_translated(7,1)], [positions_translated(6,2) positions_translated(7,2)], [positions_translated(6,3) positions_translated(7,3)], 'k-');

xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
title('平移后的双四面体结构');
view(-30, 10);
