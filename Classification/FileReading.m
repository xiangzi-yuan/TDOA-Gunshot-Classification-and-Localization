clc;clear;
maxlen_gun = 0;
maxlen_siren = 0;
maxlen_car_horn = 0;
num_gun = 90;
num_siren = 45;
num_car_horn = 75;

% Checking the length of gun audio files
for i = 1:num_gun
    file_name = strcat('../train/gun_shot/gun', num2str(i), '.wav');
    fprintf('checking %s...\n', file_name);
    [y1, fs] = audioread(file_name);
    if maxlen_gun < length(y1(:, 1))
        maxlen_gun = length(y1(:, 1));
    end
end

% Checking the length of siren audio files
for i = 1:num_siren
    file_name = strcat('../train/siren/siren', num2str(i), '.wav');
    fprintf('checking %s...\n', file_name);
    [y2, fs] = audioread(file_name);
    if maxlen_siren < length(y2(:, 1))
        maxlen_siren = length(y2(:, 1));
    end
end

% Checking the length of car_horn audio files
for i = 1:num_car_horn
    file_name = strcat('../train/car_horn/car_horn', num2str(i), '.wav');
    fprintf('checking %s...\n', file_name);
    [y3, fs] = audioread(file_name);
    if maxlen_car_horn < length(y3(:, 1))
        maxlen_car_horn = length(y3(:, 1));
    end
end


data_gun = zeros(num_gun, maxlen_gun);
data_siren = zeros(num_siren, maxlen_siren);
data_car_horn = zeros(num_car_horn, maxlen_car_horn);


% Reading and plotting gun data
for i = 1:num_gun
    file_name = strcat('../train/gun_shot/gun', num2str(i), '.wav');
    fprintf('reading %s...\n', file_name);
    [y1, fs] = audioread(file_name);
    data_gun(i, 1:length(y1(:, 1))) = y1(:, 1)';
    %figure(2); subplot(4, 2, i); plot(data_gun(i, :));
end

% Reading and plotting siren data
for i = 1:num_siren
    file_name = strcat('../train/siren/siren', num2str(i), '.wav');
    fprintf('reading %s...\n', file_name);
    [y2, fs] = audioread(file_name);
    data_siren(i, 1:length(y2(:, 1))) = y2(:, 1)';

end

% Reading and plotting car_horn data
for i = 1:num_car_horn
    file_name = strcat('../train/car_horn/car_horn', num2str(i), '.wav');
    fprintf('reading %s...\n', file_name);
    [y3, fs] = audioread(file_name);
    data_car_horn(i, 1:length(y3(:, 1))) = y3(:, 1)';
   
end

fprintf('\n');

fprintf('size of data_gun: ');
size(data_gun)
fprintf('\n');
fprintf('size of data_siren: ');
size(data_siren)
fprintf('\n');
fprintf('size of data_car_horn: ');
size(data_car_horn)
fprintf('\n');
