% % % % % % %%
% 生成信号调理板的幅相校正系数
% 1、由自动采集功能采集1-2、1-3、1-4、...1-180通道的AD数据
% 2、根据保存下来的AD数据的特点，还原12bit数据的十进制形式
% 3、做fft，得到各个通道与参考通道（第一通道）的幅相误差
% 4、得到补偿系数，并转换为FPGA中存储的数据形式
function generate(path)
%a=input(path)
%clc; clear all; close all;
%path = 'F:\专业资料\声纳成像\2016_3_17\幅相校正程序\幅相校正仿真\AD自动采集数据_调整noise.dat'
%fid=fopen('F:\专业资料\声纳成像\2016_3_17\幅相校正程序\幅相校正仿真\AD自动采集数据_调整noise.dat','r');
fid=fopen(path,'r');

N=256;%样本个数

channel_1_char=zeros(179,512);
channel_1_dec=zeros(179,256);

for count=1:179
    channel_1_char(count,:)=fread(fid,512);
    for count_i=1:N;
        b(count,count_i)=channel_1_char(count,2*count_i-1)+channel_1_char(count,2*count_i)*256;
    end
    
    for count_j=1:N;
        channel_1_dec(count,count_j)=b(count,count_j);
        if b(count,count_j)>=32768;
            m=b(count,count_j)-32769;
            x=dec2bin(m);
            for count_jj=1:length(x);
                if(x(count_jj)=='0');
                    x(count_jj)='1';
                else
                    x(count_jj)='0';
                end
            end
            z=bin2dec(x);
            channel_1_dec(count,count_j)=(z)*(-1);
        end
    end
    
end


channel_i_char=zeros(179,512);
channel_i_dec=zeros(179,256);

for count=1:179
    channel_i_char(count,:)=fread(fid,512);
    for count_i=1:N;
        b(count,count_i)=channel_i_char(count,2*count_i-1)+channel_i_char(count,2*count_i)*256;
    end
    
    for count_j=1:N;
        channel_i_dec(count,count_j)=b(count,count_j);
        if b(count,count_j)>=32768;
            m=b(count,count_j)-32769;
            x=dec2bin(m);
            for count_jj=1:length(x);
                if(x(count_jj)=='0');
                    x(count_jj)='1';
                else
                    x(count_jj)='0';
                end
            end
            z=bin2dec(x);
            channel_i_dec(count,count_j)=(z)*(-1);
        end
    end
end

fclose('all');


peak_value(1,1)=max(channel_1_dec(1,:));
peak_value(1,2)=min(channel_1_dec(1,:)); 
for k=1:179
    peak_value(k+1,1)=max(channel_i_dec(k,:));
    peak_value(k+1,2)=min(channel_i_dec(k,:));   
end



figure;
subplot(4,1,1);plot(channel_i_dec(3,:));
subplot(4,1,2);plot(channel_i_dec(5,:));
subplot(4,1,3);plot(channel_i_dec(127,:));
subplot(4,1,4);plot(channel_i_dec(151,:));
xlabel('第4,6,128,152号通道')





fft_channel_1=zeros(179,256);
position_1=zeros(179,1);
Amplitude_1=zeros(179,1);
phase_1=zeros(179,1);
for count_i=1:179
    fft_channel_1(count_i,:)=fft(channel_1_dec(count_i,:));
    [Amplitude_1(count_i),position_1(count_i)]=max(abs(fft_channel_1(count_i,:)));
    phase_1(count_i)=angle(fft_channel_1(count_i,position_1(count_i)));
end



fft_channel_i=zeros(179,256);
position_i=zeros(179,1);
Amplitude_i=zeros(179,1);
phase_i=zeros(179,1);
for count_i=1:179
    fft_channel_i(count_i,:)=fft(channel_i_dec(count_i,:));
    [Amplitude_i(count_i),position_i(count_i)]=max(abs(fft_channel_i(count_i,:)));
    phase_i(count_i)=angle( fft_channel_i(count_i,position_i(count_i)) );
end

figure;plot(abs(fft_channel_1'));hold on;plot(abs(fft_channel_i'));


% % 计算补偿系数
amplitude_correction_coe=zeros(180,1);
phase_correction_coefficient=zeros(180,1);
amplitude_correction_coe(1)=1;
phase_correction_coefficient(1)=1;
for count_i=1:179
    amplitude_correction_coe(count_i+1)=Amplitude_1(count_i)/Amplitude_i(count_i);
    delta_phase(count_i+1)=phase_i(count_i)-phase_1(count_i);
    phase_correction_coefficient(count_i+1)=exp(j*(delta_phase(count_i+1)));
end

figure;
dB=20*log10(amplitude_correction_coe);
plot(dB,'.');grid on;
xlabel('通道号'); ylabel('归一化增益/dB')
figure;
plot(amplitude_correction_coe,'.');grid on;
xlabel('通道号'); ylabel('与参考通道的比值')
figure;
for k=1:length(delta_phase)
    if delta_phase(k)>pi
        delta_phase(k)=delta_phase(k)-2*pi;
    elseif delta_phase(k)<-pi
        delta_phase(k)=delta_phase(k)+2*pi;
    else
        delta_phase(k)=delta_phase(k);
    end
end
plot(delta_phase,'.');grid on;
xlabel('通道号'); ylabel('与参考通道的弧度误差')
figure;
plot(delta_phase*180/pi,'.');grid on;
xlabel('通道号'); ylabel('与参考通道的角度误差')


% %  生成FPGA存储系数
for count_i=1:180
    correction_real(count_i)=amplitude_correction_coe(count_i)*real(phase_correction_coefficient(count_i));
    correction_imag(count_i)=amplitude_correction_coe(count_i)*imag(phase_correction_coefficient(count_i));
end

% error=correction_real+j*correction_imag;
% error_amp=abs(error)';
% error_pha=angle(error)';

for count_i=1:180
    correction_real_fpga(count_i)=round(correction_real(count_i)*(2^14));
    correction_imag_fpga(count_i)=round(correction_imag(count_i)*(2^14));
    if(abs(correction_real_fpga(count_i))>32767)
        correction_real_fpga(count_i)=16384;
    end
    if(abs(correction_imag_fpga(count_i))>32767)
        correction_imag_fpga(count_i)=16384;
    end
end

% % 实部补偿系数
for count_j=1:180
    
    if correction_real_fpga(count_j)<0
        f1=correction_real_fpga(count_j)*(-1);
        f1=f1-1;
        f2=dec2bin(f1,16);
        for count_i=1:length(f2);
            if(f2(count_i)=='0');
                f2(count_i)='1';
            else (f2(count_i)=='1');
                f2(count_i)='0';
            end
        end
        f3=bin2dec(f2);
        correction_real_fpga_complement(count_j)=f3;
    else
        correction_real_fpga_complement(count_j)=correction_real_fpga(count_j);
    end
    
end

% for count_j=1:180
%     correction_real_fpga_char(2*count_j-1)=mod(correction_real_fpga_complement(count_j),256); % 低8位
%     correction_real_fpga_char(2*count_j)=floor(correction_real_fpga_complement(count_j)/256); % 高8位
% end
% A=dec2hex(correction_real_fpga_char);

A=dec2hex(correction_real_fpga_complement);


% % 虚部补偿系数
for count_j=1:180
    
    if correction_imag_fpga(count_j)<0
        f1=correction_imag_fpga(count_j)*(-1);
        f1=f1-1;
        f2=dec2bin(f1,16);
        for count_i=1:length(f2);
            if(f2(count_i)=='0');
                f2(count_i)='1';
            else (f2(count_i)=='1');
                f2(count_i)='0';
            end
        end
        f3=bin2dec(f2);
        correction_imag_fpga_complement(count_j)=f3;
    else
        correction_imag_fpga_complement(count_j)=correction_imag_fpga(count_j);
    end
    
end

% for count_j=1:180
%     correction_imag_fpga_char(2*count_j)=floor(correction_imag_fpga_complement(count_j)/256);
%     correction_imag_fpga_char(2*count_j-1)=mod(correction_imag_fpga_complement(count_j),256);
% end
% B(:,:)=dec2hex(correction_imag_fpga_char);

B=dec2hex(correction_imag_fpga_complement);


% real_xishu=A'; real_xishu=real_xishu(:)';
% imag_xishu=B'; imag_xishu=imag_xishu(:)';
% real_xishu=A';
% imag_xishu=B';
% filename_pos='C:\Documents and Settings\DODO\桌面\幅相校正\幅相校正仿真\corcoe\';
% filename_ap={'real.txt';'imag.txt'};
% filename=char( strcat(filename_pos,filename_ap(1)) );
% fid=fopen(filename,'wt');
% fprintf(fid,'%s',real_xishu);
% fclose(fid);
% filename=char( strcat(filename_pos,filename_ap(2)) );
% fid=fopen(filename,'wt');
% fprintf(fid,'%s',imag_xishu);
% fclose(fid);

AA(:,1:2)=A(:,3:4); AA(:,3:4)=A(:,1:2);
BB(:,1:2)=B(:,3:4); BB(:,3:4)=B(:,1:2);

frame_head=['11';'11';'11';'11'];
correction_coe=[frame_head,AA',BB'];

filename='幅相系数记录.txt';
fid=fopen(filename,'wt');
fprintf(fid,'%s',correction_coe);
fclose(fid);
end
