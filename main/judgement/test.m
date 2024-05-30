clear;
addpath('../../Classification/')
wave1;

% [audioToSave, fs] = audioread('dog_bark62.wav');
result = Classification1(audioToSave); % 判断枪声类型
