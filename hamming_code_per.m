function [G,H,ber]=hamming_code_per(n,k,p1,p2)
    
    %�û�δ�������Ԥ��ֵ
     if (nargin == 0)
        n=63;k=57;p1=6;p2=1;
           disp('���������ȫ��������Ĭ��ֵ');
     end

    r=n-k;%�ලλ��
    L=k*1000;%ԭʼ���ݳ���
    L_code=L/k*n;%�������ݳ���
    data = mod(randperm(L),2);%�ȸ��ʶ�������Դ
    Q=zeros(k,r);%Ԥ�þ���Q

    EbNo_dB=0:10;%�����/dB
    EbNo=10.^(EbNo_dB/10);%�����
    Eb=1;
    No=Eb./EbNo;%�źŹ��ʡ���˹����������
    
    send_data=zeros(1,L_code);%Ԥ�÷�������
    demod=zeros(1,L_code);%Ԥ�ý������
    demod_nohamming=zeros(1,L);%Ԥ��δ����������
    error=zeros(1,length(EbNo_dB));%Ԥ�ô�����
    error_nohamming=zeros(1,length(EbNo_dB));%Ԥ��δ���������
    decode=zeros(1,L);%Ԥ�ý�������
    ber = zeros(1,length(EbNo_dB));%Ԥ������������
    ber_nohamming=zeros(1,length(EbNo_dB));%Ԥ��δ��������������
    
    G=makeG(n,k,p1,p2);%����������ɾ���G

    %����ල����H
    for l=1:k
       Q(l,:)=G(l,k+1:end);
    end
    P=transpose(Q);
    Ir=eye(r);
    H=[P Ir];%�ල����H

    %���벢����
    for i = 0:L/k-1
        code=mod(data(i*k+1:(i+1)*k)*G,2);%����
        temps=(code-1/2)*2;%����
        send_data(i*n+1:(i+1)*n)=temps;%��������
    end
        send_data_nohamming=(data-1/2)*2;%δ������Ϣ����

    %�ŵ��Լ����������
    %����ȴ�0��10
    for j=1:length(EbNo_dB)
        noise = sqrt(No(j)) * randn(1,L_code);%��������������������
        receive=send_data+noise;%��������=�������ݵ�������
        recieve_nohamming=send_data_nohamming+noise(1:L);

        %�������������ݳ����о�
        for q=1:L_code
            if(receive(q)>=0)
                demod(q)=1;
            else
                demod(q)=0;
            end
        end

         %����ֱ�Ӵ�������о�
        for q=1:L
            if(recieve_nohamming(q)>=0)
                demod_nohamming(q)=1;
            else
                demod_nohamming(q)=0;
            end
        end

        %���벢У��
        for i=0:L/k-1
            tempd=demod(i*n+1:(i+1)*n);%����У�������Ľ�������
            S(1:r)=mod(tempd*transpose(H),2);%����У������
            %����У�������жϽ����������Ƿ��д���
            if (length(find(S==0))==r)
            else
                for c=1:n
                    if (H(:,c)==transpose(S))
                        tempdc=~tempd(c);%�ҳ����벢������������
                        tempd(c)=tempdc;%���������Ľ�������
                        break;
                    end
                end
            end
            decode(i*k+1:(i+1)*k)=tempd(1:k);%��������
        end

        %ͳ�ƴ�������
        for v=1:L
            if (decode(v) ~= data(v))
                  error(j) = error(j) + 1;
            end
            if (demod_nohamming(v) ~=data(v))
                  error_nohamming(j) = error_nohamming(j) + 1;
            end
        end
        %����������
         ber(j) = error(j) / L;
         ber_nohamming(j) = error_nohamming(j)/L;
    end

    %��ͼ
    figure(1);
    semilogy(EbNo_dB,ber,'M-X',EbNo_dB,ber_nohamming,'B-O');%��ͼ
    grid on;
    % axis([0 10 10^-5 10^-1])
    xlabel('Eb/N0 (dB)');%�������ǩ                     
    ylabel('BER');%�������ǩ
    if (n==7)
        legend('��7��4��������������','δ����������');
        title('��7��4��������Ա�δ����������������������');
    elseif (n==15)
        legend('��15,11��������������','δ����������');
        title('��15��11��������Ա�δ����������������������');
    elseif(n==31)
        legend('��31,26��������������','δ����������');
        title('��31��26��������Ա�δ����������������������');
    elseif(n==63)
        legend('��63,57��������������','δ����������');
        title('��63��57��������Ա�δ����������������������');
    end
%end
 