function G = makeG(n,k,p1,p2)

    x=2;
    G=zeros(k,n);
    %ʹ��Ԥ�����ɶ���ʽ
    g0=x^p1+x^p2+1;
    %�������ɾ���
    for i=k-1:-1:0
        Grow=zeros(1,n);%Ԥ�����ɾ�������������
        temp=x^i*g0;
        temp=dec2bin(temp);
        LOZ=n-length(temp)+1;%����ǰ������+1
        for j=LOZ:n
            Grow(j)=temp(j-LOZ+1)-48;%�������ɾ���������
        end
        G(k-i,:)=Grow;%���ɾ���
    end
    %�����ɾ���Ϊ���;���
    Gr=rref(G);
    G=mod(Gr,2);
end
    