原理：
       对信号中出现的较明显的几个或十几个超过预设电平值的频点进行电平抑制从而达到抑制啸叫的目的。带反馈的信号首先经过啸叫检测算法，得到一组系数去更新声学路径中的陷波器组系数。


程序：
外部输入项
       语音信号：x
       反馈路径：g
       扩音系统内部传递路径：c

计算项
        两个IIR陷波器：iir_coef1，iir_coef2
        陷波器组：iir_coef
        带反馈信号：y1
        滤波输入：d
        滤波输出：y2


Notice：当将输入语音man.wav更换成其他语音时，程序报错：Error using fdesign.abstracttype/cheby1 Frequency specifications must be between 0 and 1.