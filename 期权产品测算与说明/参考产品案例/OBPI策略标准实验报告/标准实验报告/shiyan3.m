clear all;
load SH380  ;%����ѡ��֤380ָ��2012��10��10����2014��10��10�գ�������Դ��RESSET���ݿ�
W(1)=1000;   %Ͷ���߳�ʼ��������0ʱ��ȫ��Ͷ�ڷ����ʲ�
rf=0.03;     %���޷�������
c=0.005;     %����������
n=238;       %������ѡȡ2012��10��10����2013��10��10��
S1=SH380(1:n+1,2);
%��������ʲ������ڵ���������miu
miu=log(S1(length(S1))/S1(1));
%���Ʒ����ʲ������ʵ��겨����segma
for i=1:n
       rt(i)=log(S1(i+1)/S1(i));
end
clear i;
mean_rt=sum(rt)/n;
for j=1:n
    var_rt(j)=(rt(j)-mean_rt)^2;
end
clear j;
segma_day=sqrt(sum(var_rt)/(n-1));     %ƽ���ղ�����
segma=segma_day*sqrt(n);               %�겨����
adjust_day=[1,5,10,20];
%���������������������������ָ��ߡ�����������������������������
%ÿ���ΪN���������䣬�ٶ�һ����240�������գ�ȡN=240
for q=1:1000                             %ģ�����
creat_S1=creat_s(240,S1,miu,segma);    %���ú�����������
[C_result,C_lost,R]=OBPI(creat_S1,rf,segma,W,c);
    Q_result(q,:)=C_result(1,:);%���ÿ��ģ������������������Ų�ͬ����Ƶ�ʵõ�����ĩ��ֵ
end
[l,k]=size(Q_result);
for j=1:k  
    Q_result_adjust(1,j)=mean(Q_result(:,j));  %������о�ֵ
    Q_result_adjust(2,j)=std(Q_result(:,j));%�������ƽ����
    Q_result_adjust(3,j)=  Q_result_adjust(1,j)/ Q_result_adjust(2,j); %У����ĵ������Ե÷�
end
disp '�ֱ𰴣�1��5��10��20����Ƶ�ʵ������ԵĽ������һ��Ϊ��ֵ���ڶ���Ϊ��׼�������Ϊ���Ե÷�'
Q_result_adjust%��ʾ������Ƶ�ʵ÷�
clear l k j;
%�������������������������������������ָ��ߡ�����������������������������������������
[a,b]=max(Q_result_adjust(3,:));%�ҵ��÷���ߵĵ�������
disp 'ģ�����ݵ÷���ߵĲ��Բ��õĵ�������Ϊ'
m2=adjust_day(b)
real_S1=SH380(n+1:length(SH380),2);    %��ȡ2013��10��10����2014��10��10�յ�ʵ�����������
real_X=real_S1(1);                         %�趨��Ȩִ�м۸��ڳ��ķ����ʲ��۸�
clear a b;
[r_C_result,r_C_lost,r_R]=OBPI(real_S1,rf,segma,W,c);
disp 'ʵ���������ֲ��Եõ�����ĩ�����ʲ���ϼ�ֵ'
r_C_result
disp 'ʵ������һ���и������ۻ�֧���Ľ��׷�'
r_C_lost
for i=1:4
    mn=adjust_day(i);
    real_Sm2=r_R{1,i};
    r_C=r_R{2,i};
    r_C_free=r_R{3,i};
    picture_num=num2str(i);
x=(1000/real_Sm2(1)).*real_Sm2(2:length(real_Sm2));
figure,plot(x,'-black.')
hold on
plot(r_C(:,7),'-b.')
plot(r_C_free(:,7),'-g.')
str=['ִ�м۸�X=',num2str(real_X),',��������mn=',num2str(mn)];
title(str);
legend('�����ʲ���ֵ','�н��׷�Ͷ�����ÿ����ĩ��ֵ','�޽��׷�Ͷ�����ÿ����ĩ��ֵ');
hold off
end
clear i;

