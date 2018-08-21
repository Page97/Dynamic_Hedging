%每年分为N个交易区间
function M=creat_s(N,S1,miu,segma)
M(1)=S1(length(S1));%代表新生成时间序列的在时刻0的值
eta=zeros(1,N);
eta=normrnd(miu/N, segma/sqrt(N), N, 1);%生成服从均值为miu，标准差为segma的正态分布的日收益率
for i=2:N+1  %此处i表示第i-1期末
  M(i)=M(i-1)*(1+eta(i-1));
end
clear i eta;
