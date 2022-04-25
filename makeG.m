function G = makeG(n,k,p1,p2)

    x=2;
    G=zeros(k,n);
    %使用预设生成多项式
    g0=x^p1+x^p2+1;
    %计算生成矩阵
    for i=k-1:-1:0
        Grow=zeros(1,n);%预置生成矩阵行向量序列
        temp=x^i*g0;
        temp=dec2bin(temp);
        LOZ=n-length(temp)+1;%序列前补零数+1
        for j=LOZ:n
            Grow(j)=temp(j-LOZ+1)-48;%计算生成矩阵行向量
        end
        G(k-i,:)=Grow;%生成矩阵
    end
    %将生成矩阵化为典型矩阵
    Gr=rref(G);
    G=mod(Gr,2);
end
    