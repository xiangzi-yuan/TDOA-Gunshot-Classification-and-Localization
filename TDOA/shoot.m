clc; close all;

% 马赫波功能正常
% 镗口波功能正常
% 定义声速（毫米/秒）
speed_of_sound = 343200;
mach = 3;
% 中心点移动速度（毫米/秒），可调整此值
center_speed = speed_of_sound * mach;  

% 初始位置和方向向量
initial_position = [500, 1000, 600]; 
movement_direction = [ -1, -1, -1]; 

% 模式设置
Muzzleblast = 1;
Machwave = 1;

% 仿真时间
total_time = 0.005;
dt = 0.00001;  % 步长
t = 0:dt:total_time;

% 计算轨迹
movement = center_speed * t;
x = initial_position(1) + movement .* movement_direction(1);
y = initial_position(2) + movement .* movement_direction(2);
z = initial_position(3) + movement .* movement_direction(3);

% 存储所有球体的句柄
ball_handles = [];
ball_start_times = [];
max_balls = size(t,2);  % 最大球体数


figure;
hold on;
axis equal;
grid on;
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
saxis = 100000;
axis([-saxis+max(x) max(x)+saxis -saxis saxis -saxis saxis]);

% 球体
[sx, sy, sz] = sphere;

% 基站设置
% baseStation = [0, 0, 0;
%                0, 500, 0;
%                0, 0, 500;
%                500, 0, 0;
%                100, 100, 100];
num_sensors = size(baseStation, 1);
TDOA = zeros(1, num_sensors);
TDOA_machwave = zeros(1, num_sensors);
sensor_times_Muzzleblast = inf(1, num_sensors); % 镗口波时间记录
sensor_times_Machwave = inf(max_balls, num_sensors);   % 马赫波时间记录
plot3(baseStation(:, 1), baseStation(:, 2), baseStation(:, 3), 'ko', 'MarkerFaceColor', 'k');

% 镗口波句柄
if Muzzleblast
    muzzleball_handle = mesh(sx, sy, sz, 'EdgeColor', 'none', 'FaceColor', [0 1 0], 'FaceAlpha', 0.1);
    set(muzzleball_handle, 'Visible', 'off');
end

ball_index = 1;
% 动画演示
time = 0;
for i = 1:length(t)
    radius = speed_of_sound * t(i);

    % Muzzleblast Mode
    if Muzzleblast
        set(muzzleball_handle, 'XData', sx * radius + initial_position(1), 'YData', sy * radius + initial_position(2), 'ZData', sz * radius + initial_position(3), 'Visible', 'on');
        
    
        for k = 1:num_sensors
            sensor_pos = baseStation(k, :);
            distance = sqrt((sensor_pos(1) - initial_position(1))^2 + (sensor_pos(2) - initial_position(2))^2 + (sensor_pos(3) - initial_position(3))^2);
            if sensor_times_Muzzleblast(k) == inf && distance <= radius
                sensor_times_Muzzleblast(k) = t(i);
            end
        end
    end

    % Machwave Mode
    if Machwave
        % Color change effect
        color = 0.5 * (sin(2000 * pi * t(i) / 20) + 1);  % Normalized to [0, 1]
        faceColor = [1, color, 1 - color];  % Color changes over time
        if mod(time,500)==0
        % 创建一个新的球体，初始半径为0
            new_ball_handle = mesh(sx, sy, sz, 'EdgeColor', 'none', 'FaceColor', faceColor, 'FaceAlpha', 0.1);
        end
        if length(ball_handles) >= max_balls
            % 替换最老的球体
            delete(ball_handles(ball_index));
            ball_handles(ball_index) = new_ball_handle;
            ball_start_times(ball_index) = t(i);
            x(ball_index) = initial_position(1) + movement(i) * movement_direction(1);
            y(ball_index) = initial_position(2) + movement(i) * movement_direction(2);
            z(ball_index) = initial_position(3) + movement(i) * movement_direction(3);
            ball_index = mod(ball_index, max_balls) + 1;
        else
            ball_handles = [ball_handles, new_ball_handle];
            ball_start_times = [ball_start_times, t(i)];
            x = [x, initial_position(1) + movement(i) * movement_direction(1)];
            y = [y, initial_position(2) + movement(i) * movement_direction(2)];
            z = [z, initial_position(3) + movement(i) * movement_direction(3)];
        end
        
        for j = 1:length(ball_handles)
            current_radius = max(0, speed_of_sound * (t(i) - ball_start_times(j)));  % 半径增加速度等于声速（毫米单位）
%             alpha = max(0.1, 1 - (t(i) - ball_start_times(j)) / 20);  % 透明度随时间递减
            alpha=0.01;
            set(ball_handles(j), 'XData', sx * current_radius + x(j), 'YData', sy * current_radius+ y(j), 'ZData', sz * current_radius+ z(j), 'FaceAlpha', alpha);
            
                for k = 1:num_sensors
                    sensor_pos = baseStation(k, :);
                    distance_to_sensor = sqrt((sensor_pos(1) - x(j))^2 + (sensor_pos(2) - y(j))^2 + (sensor_pos(3) - z(j))^2);
                    if sensor_times_Machwave(j,k) == inf && distance_to_sensor <= current_radius
                        sensor_times_Machwave(j,k) = t(i);  % 记录传感器首次检测到马赫波的时间
                    end
                   
                end
                for k = 1:num_sensors
                    if sensor_times_Machwave(j,:) ~= inf
                         TDOA_machwave(j,k) = sensor_times_Machwave(j,k)-sensor_times_Machwave(j,1);
                    end
                end

        end
        

    end
    pause(0.00001);  
%     % Display sensor interaction times
%     for k = 1:num_sensors
%         if sensor_times_Muzzleblast(k) ~= inf || sensor_times_Machwave(k) ~= inf
%             display_time = min(sensor_times_Muzzleblast(k), sensor_times_Machwave(k));
%             text(baseStation(k, 1), baseStation(k, 2), baseStation(k, 3) + 100000, sprintf('Time: %.6f s', display_time), ...
%                 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');
%         end
%     end
end

% 输出
for k = 1:num_sensors
    if sensor_times_Muzzleblast(k) ~= inf
        TDOA(k) = sensor_times_Muzzleblast(k)-sensor_times_Muzzleblast(1);
        fprintf('Sensor %d first encountered the muzzle blast wave at time %.6f seconds at position (%.0f, %.0f, %.0f).\n', ...
                k, sensor_times_Muzzleblast(k), baseStation(k, 1), baseStation(k, 2), baseStation(k, 3));
    end
end
disp(TDOA);
disp(TDOA_machwave(1,:));