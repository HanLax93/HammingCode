function [G,H,ber]=hamming_code_per(n,k,p1,p2)
    
    %用户未输入参数预设值
     if (nargin == 0)
        n=63;k=57;p1=6;p2=1;
           disp('输入参数不全，将采用默认值');
     end

    r=n-k;%监督位数
    L=k*1000;%原始数据长度
    L_code=L/k*n;%编码数据长度
    data = mod(randperm(L),2);%等概率二进制信源
    Q=zeros(k,r);%预置矩阵Q

    EbNo_dB=0:10;%信噪比/dB
    EbNo=10.^(EbNo_dB/10);%信噪比
    Eb=1;
    No=Eb./EbNo;%信号功率、高斯白噪声功率
    
    send_data=zeros(1,L_code);%预置发送数据
    demod=zeros(1,L_code);%预置解调数据
    demod_nohamming=zeros(1,L);%预置未编码解调数据
    error=zeros(1,length(EbNo_dB));%预置错码组
    error_nohamming=zeros(1,length(EbNo_dB));%预置未编码错码组
    decode=zeros(1,L);%预置解码数据
    ber = zeros(1,length(EbNo_dB));%预置误码率数组
    ber_nohamming=zeros(1,length(EbNo_dB));%预置未编码误码率数组
    
    G=makeG(n,k,p1,p2);%计算典型生成矩阵G

    %计算监督矩阵H
    for l=1:k
       Q(l,:)=G(l,k+1:end);
    end
    P=transpose(Q);
    Ir=eye(r);
    H=[P Ir];%监督矩阵H

    %编码并调制
    for i = 0:L/k-1
        code=mod(data(i*k+1:(i+1)*k)*G,2);%编码
        temps=(code-1/2)*2;%调制
        send_data(i*n+1:(i+1)*n)=temps;%发送数据
    end
        send_data_nohamming=(data-1/2)*2;%未编码信息序列

    %信道以及解调、解码
    %信噪比从0到10
    for j=1:length(EbNo_dB)
        noise = sqrt(No(j)) * randn(1,L_code);%根据噪声功率生成噪声
        receive=send_data+noise;%接收数据=发送数据叠加噪声
        recieve_nohamming=send_data_nohamming+noise(1:L);

        %汉明码编码后数据抽样判决
        for q=1:L_code
            if(receive(q)>=0)
                demod(q)=1;
            else
                demod(q)=0;
            end
        end

         %数据直接传输抽样判决
        for q=1:L
            if(recieve_nohamming(q)>=0)
                demod_nohamming(q)=1;
            else
                demod_nohamming(q)=0;
            end
        end

        %解码并校正
        for i=0:L/k-1
            tempd=demod(i*n+1:(i+1)*n);%分组校正解调后的解码数据
            S(1:r)=mod(tempd*transpose(H),2);%计算校正矩阵
            %根据校正矩阵判断解调后的码中是否有错码
            if (length(find(S==0))==r)
            else
                for c=1:n
                    if (H(:,c)==transpose(S))
                        tempdc=~tempd(c);%找出错码并纠正纠正错码
                        tempd(c)=tempdc;%单组纠正后的解码数据
                        break;
                    end
                end
            end
            decode(i*k+1:(i+1)*k)=tempd(1:k);%解码数据
        end

        %统计错码数量
        for v=1:L
            if (decode(v) ~= data(v))
                  error(j) = error(j) + 1;
            end
            if (demod_nohamming(v) ~=data(v))
                  error_nohamming(j) = error_nohamming(j) + 1;
            end
        end
        %计算误码率
         ber(j) = error(j) / L;
         ber_nohamming(j) = error_nohamming(j)/L;
    end

    %画图
    figure(1);
    semilogy(EbNo_dB,ber,'M-X',EbNo_dB,ber_nohamming,'B-O');%画图
    grid on;
    % axis([0 10 10^-5 10^-1])
    xlabel('Eb/N0 (dB)');%横坐标标签                     
    ylabel('BER');%纵坐标标签
    if (n==7)
        legend('（7，4）汉明码误码率','未编码误码率');
        title('（7，4）汉明码对比未编码误比特率随信噪比曲线');
    elseif (n==15)
        legend('（15,11）汉明码误码率','未编码误码率');
        title('（15，11）汉明码对比未编码误比特率随信噪比曲线');
    elseif(n==31)
        legend('（31,26）汉明码误码率','未编码误码率');
        title('（31，26）汉明码对比未编码误比特率随信噪比曲线');
    elseif(n==63)
        legend('（63,57）汉明码误码率','未编码误码率');
        title('（63，57）汉明码对比未编码误比特率随信噪比曲线');
    end
%end
 