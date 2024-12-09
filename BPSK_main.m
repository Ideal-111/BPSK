clc;
clear;
%% 参数设置
Fc = 5000;% 载波频率
Rb = 50;  % 比特率
RB = 50;  % 波特率
snr = 0; % 接收信噪比
T = 1/RB; % 码元持续时间
E = T/2;  % 能量
%% (1)输入二进制序列
% s = [1 0 0 0 1 1 1 0 1 1 1 0];
% %% (2)输入英文字母
text = "A system for the conveyance of information is a combination of circuits and/or devices that is assembled to accomplish a desired task, such as the transmission of intelligence from one point to another. Many means for the transmission of information have been used down through the ages. It almost goes without saying that we are concerned about the theory of systems for electrical communications.";
% 哈夫曼编码
str = double(char(strjoin(text(:),'')));
edges = [unique(str), max(str)+1];
freq_num = histcounts(str, edges);
freq = freq_num/sum(freq_num);
% 构建哈夫曼表
[dict, avglen] = huffmandict(unique(str), freq);
% 对文本进行编码
code = huffmanenco(str, dict);
s = code;
maxlen = length(s); 
L0 = 10000*maxlen*T; % 时间向量长度
t = linspace(0, maxlen*T, L0);
% 构造二进制序列对应的信号波形 Sinput
Sinput1 = t; 
for n = 1:maxlen
    if s(n) == 1
        for m = L0/maxlen*(n-1) + 1:L0/maxlen*n
                Sinput1(m) = 1;
        end
    else 
        for m = L0/maxlen*(n-1) + 1:L0/maxlen*n
                Sinput1(m) = 0;
        end
    end
end
% 绘制输入信号波形图像
% figure(1);
% subplot(3,1,1);
% plot(t, Sinput1,'LineWidth',1);
% grid on;
% xlabel('t');
% title('基带成型滤波(a处的波形)');
% axis([0, 0.24 -1 2]);
% 产生双极性信号
Sinput2 = t;
for k = 1:L0
    if Sinput1(k)>=1
        Sinput2(k) = 0;
    else 
        Sinput2(k) = 1;
    end
end
Sinput3 = Sinput1 - Sinput2;
% subplot(3,1,2);
% plot(t, Sinput2,'LineWidth',1);
% grid on
% xlabel('t');
% title('单极性基带信号');
% axis([0, 0.24 -1 2]);
% subplot(3,1,3);
% plot(t, Sinput3,'LineWidth',1);
% grid on
% xlabel('t');
% title('双极性基带信号');
% axis([0, 0.24 -2 2]);
%% 调制
t1 = linspace(0,0.024,L0);
s1 = sin(2*pi*Fc*t1);
bpsk_signal = Sinput3.*s1;
% figure(2);
% subplot(2,1,1);
% plot(t,bpsk_signal);
% grid on
% title('BPSK调制信号(b处的波形)');
% xlabel('t');
% axis([0,0.24,-2,2]);
%% 叠加高斯白噪声信号
signal_trans = awgn(bpsk_signal, snr, 'measured');
% subplot(2,1,2);
% plot(t, signal_trans);
% grid on
% axis([0 0.24 -2 2]);
% title('叠加噪声后的BPSK调制信号(c处的波形)');
%% 解调
signal_demodulate= 1/sqrt(E).*s1.*signal_trans;
% 积分器
z = [];
L = L0/maxlen;
for i = 0:maxlen - 1
    midv = 0;
    for j = 1:L
        midv = midv + signal_demodulate(j+i*L);
    end
    z = [z midv];
end
% figure(3);
% stem(z,'filled');
% title('经过积分器后的信号(d处的波形)');
%% 抽样判决
signal_judge = 1*(z>0);
% figure(4);
% stem(signal_judge,'filled');
% grid on
% title('抽样判决后的信号波形(e处的波形)');
%% huffman解码
sig = huffmandeco(signal_judge, dict);
str_result = char(sig);
disp(str_result);
% 判断是否和输入文本相同
str_check = string(str_result);
result = isequal(str_check, text);
if result == 1
    disp("Correct!");
else 
    disp("Wrong!");
end