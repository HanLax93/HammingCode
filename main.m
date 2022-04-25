clear;
close all;
clc;
I=input('Please enter [n,k,p1,p2]( Example: [7,4,3,2] ):\n');
if (length(I)==4)
    n=I(1);k=I(2);p1=I(3);p2=I(4);
    [G,H,ber]=hamming_code_per(n,k,p1,p2);
else
    [G,H,ber]=hamming_code_per();
end
%function [G,H]=hamming_code_per(n,k,p1,p2)
%n为汉明码码长，k为汉明码信息位数目
%g(x) = x^p1 + x^p2 + 1 
%其中p1,p2见任务书