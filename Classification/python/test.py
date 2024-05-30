#!/usr/bin/env python
# coding: utf-8

import pyaudio
import librosa
import numpy as np
import tensorflow as tf
import os
import time
from sklearn.preprocessing import LabelBinarizer

# 常量
AUDIO_RATE = 44100
SAMPLE_DURATION = 2
AUDIO_VOLUME_THRESHOLD = 0.01
MINIMUM_FREQUENCY = 20
MAXIMUM_FREQUENCY = AUDIO_RATE // 2
NUMBER_OF_MELS = 128
NUMBER_OF_FFTS = NUMBER_OF_MELS * 20
MODEL_CONFIDENCE_THRESHOLD = 0.5
LABEL_PATH = "augmented_labels.npy"
MODEL_PATH_1D = "1D.tflite"
MODEL_PATH_2D_64 = "128_x_64_2D.tflite"
MODEL_PATH_2D_128 = "128_x_128_2D.tflite"
WAV_FOLDER_PATH = "D:/[GD]/GD/code/myself/main"

# 加载并二值化标签
labels = np.load(LABEL_PATH)
labels = np.array([("gun_shot" if label == "gun_shot" else "other") for label in labels])
label_binarizer = LabelBinarizer()
labels = label_binarizer.fit_transform(labels)
labels = np.hstack((labels, 1 - labels))

# 定义转换函数
def power_to_db(S, ref=1.0, amin=1e-10, top_db=80.0):
    S = np.asarray(S)
    if amin <= 0:
        raise ValueError("amin必须是正数")
    if np.issubdtype(S.dtype, np.complexfloating):
        magnitude = np.abs(S)
    else:
        magnitude = S
    if callable(ref):
        ref_value = ref(magnitude)
    else:
        ref_value = np.abs(ref)
    log_spec = 10.0 * np.log10(np.maximum(amin, magnitude))
    log_spec -= 10.0 * np.log10(np.maximum(amin, ref_value))
    if top_db is not None:
        if top_db < 0:
            raise ValueError("top_db必须是非负数")
        log_spec = np.maximum(log_spec, log_spec.max() - top_db)
    return log_spec

def convert_audio_to_spectrogram(data, sr):
    spectrogram = librosa.feature.melspectrogram(y=data, sr=sr,
                                                 hop_length=345*2,
                                                 fmin=MINIMUM_FREQUENCY,
                                                 fmax=MAXIMUM_FREQUENCY,
                                                 n_mels=NUMBER_OF_MELS,
                                                 n_fft=NUMBER_OF_FFTS)
    spectrogram = power_to_db(spectrogram)
    spectrogram = spectrogram.astype(np.float32)
    return spectrogram

# 加载模型
def load_model(model_path):
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    input_shape = input_details[0]['shape']
    return interpreter, input_details, output_details, input_shape

interpreter_1, input_details_1, output_details_1, input_shape_1 = load_model(MODEL_PATH_1D)
interpreter_2, input_details_2, output_details_2, input_shape_2 = load_model(MODEL_PATH_2D_64)
interpreter_3, input_details_3, output_details_3, input_shape_3 = load_model(MODEL_PATH_2D_128)

# 处理并识别wav文件
def process_and_predict(file_path):
    # 读取音频文件
    y, sr = librosa.load(file_path, sr=AUDIO_RATE)

    # 处理数据
    if len(y) < AUDIO_RATE:
        y = np.pad(y, (0, AUDIO_RATE - len(y)), mode='constant')
    else:
        y = y[:AUDIO_RATE]

    processed_data_1 = y.reshape(input_shape_1)

    # 使用适当的参数生成频谱图
    spectrogram_64 = convert_audio_to_spectrogram(y, sr)
    spectrogram_128 = convert_audio_to_spectrogram(y, sr)

    if spectrogram_64.shape[1] < 64:
        spectrogram_64 = np.pad(spectrogram_64, ((0, 0), (0, 64 - spectrogram_64.shape[1])), mode='constant')
    if spectrogram_128.shape[1] < 128:
        spectrogram_128 = np.pad(spectrogram_128, ((0, 0), (0, 128 - spectrogram_128.shape[1])), mode='constant')

    spectrogram_64 = spectrogram_64[:, :64]
    spectrogram_128 = spectrogram_128[:, :128]

    processed_data_2 = spectrogram_64.reshape(input_shape_2)
    processed_data_3 = spectrogram_128.reshape(input_shape_3)

    # 进行模型推理
    interpreter_1.set_tensor(input_details_1[0]['index'], processed_data_1)
    interpreter_1.invoke()
    probabilities_1 = interpreter_1.get_tensor(output_details_1[0]['index'])

    interpreter_2.set_tensor(input_details_2[0]['index'], processed_data_2)
    interpreter_2.invoke()
    probabilities_2 = interpreter_2.get_tensor(output_details_2[0]['index'])

    interpreter_3.set_tensor(input_details_3[0]['index'], processed_data_3)
    interpreter_3.invoke()
    probabilities_3 = interpreter_3.get_tensor(output_details_3[0]['index'])

    # 输出结果
    print(f"文件: {file_path}")
    print(f"44100 x 1模型预测概率: {probabilities_1[0]}")
    print(f"128 x 64模型预测概率: {probabilities_2[0]}")
    print(f"128 x 128模型预测概率: {probabilities_3[0]}")
    print(f"44100 x 1模型预测类别: {label_binarizer.inverse_transform(probabilities_1[:, 0])[0]}")
    print(f"128 x 64模型预测类别: {label_binarizer.inverse_transform(probabilities_2[:, 0])[0]}")
    print(f"128 x 128模型预测类别: {label_binarizer.inverse_transform(probabilities_3[:, 0])[0]}")

def main():
    flag = 1
    while flag:
        wav_files = [f for f in os.listdir(WAV_FOLDER_PATH) if f.endswith('.wav')]
        if not wav_files:
            print("未检测到音频文件，等待中...")
            time.sleep(5)  # 等待5秒后再次检查
            continue
        for wav_file in wav_files:
            file_path = os.path.join(WAV_FOLDER_PATH, wav_file)
            print(f"正在处理文件: {file_path}")
            process_and_predict(file_path)
            flag = 0

if __name__ == "__main__":
    main()
