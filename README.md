# -TDOA-

枪声分类+TDOA chan's 3D algorithm 定位



# 文件目录

/Classification 枪声分类

/TDOA Chan's 定位算法实现

/main 主程序

/microphone 麦克风接收音频





# 参考项目：

1. 机器学习分类部分（这个其实不适合这个项目，而且原项目有许多问题）

   [zzFon/GunshotDetection_MFCC-GMM: 基于MFCC+GMM的声学事件检测(SED), MATLAB实现, 课程设计, 2020夏 (github.com)](https://github.com/zzFon/GunshotDetection_MFCC-GMM)

2. 深度学习分类部分，这个模型效果很好，我将源代码改成检测文件夹音频用于配合MATLAB生成的音频文件，只使用了其模型做测试，因为没有自己训练，所以没写到文章里[gabemagee/gunshot_detection: Building a model that can detect gunshots from audio and that can also be scalably deployed to a Raspberry Pi cluster. (github.com)](https://github.com/gabemagee/gunshot_detection)

# 参考文献

[1]   谭艳敏.基于麦克风阵列的枪声定位技术研究[D].电子科技大学,2024.DOI:10.27005/ d.cnki.gdzku.2023.004666．（论文写作）

[2]   Chan Y T, Ho K C. A simple and efficient estimator for hyperbolic location[J]. IEEE transactions on signal processing, 1994, 42(8): 1905-1915. （原理推导）

[3]   Ma Y. A Simulation of the TDOA Chan Localization Used in the Train Station and Indoor Location System[C]//13th Asia Pacific Transportation Development Conference. Reston, VA: American Society of Civil Engineers, 2020: 450-459. （更详细的推导）



