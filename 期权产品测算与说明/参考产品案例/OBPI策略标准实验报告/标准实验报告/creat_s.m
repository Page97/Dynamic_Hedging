%ÿ���ΪN����������
function M=creat_s(N,S1,miu,segma)
M(1)=S1(length(S1));%����������ʱ�����е���ʱ��0��ֵ
eta=zeros(1,N);
eta=normrnd(miu/N, segma/sqrt(N), N, 1);%���ɷ��Ӿ�ֵΪmiu����׼��Ϊsegma����̬�ֲ�����������
for i=2:N+1  %�˴�i��ʾ��i-1��ĩ
  M(i)=M(i-1)*(1+eta(i-1));
end
clear i eta;
