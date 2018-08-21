clear all;
load SH380  ;%样本选上证380指数2012年10月10日至2014年10月10日，数据来源于RESSET数据库
W(1)=1000;   %投资者初始禀赋，在0时刻全部投在风险资产
rf=0.03;     %年无风险利率
c=0.005;     %交易手续费
n=238;       %样本窗选取2012年10月10日至2013年10月10日
S1=SH380(1:n+1,2);
%计算风险资产样本期的年收益率miu
miu=log(S1(length(S1))/S1(1));
%估计风险资产收益率的年波动率segma
for i=1:n
       rt(i)=log(S1(i+1)/S1(i));
end
clear i;
mean_rt=sum(rt)/n;
for j=1:n
    var_rt(j)=(rt(j)-mean_rt)^2;
end
clear j;
segma_day=sqrt(sum(var_rt)/(n-1));     %平均日波动率
segma=segma_day*sqrt(n);               %年波动率
adjust_day=[1,5,10,20];
%。。。。。。。。。。。。。分割线。。。。。。。。。。。。。。。
%每年分为N个交易区间，假定一年有240个交易日，取N=240
for q=1:1000                             %模拟次数
creat_S1=creat_s(240,S1,miu,segma);    %调用函数生成数据
[C_result,C_lost,R]=OBPI(creat_S1,rf,segma,W,c);
    Q_result(q,:)=C_result(1,:);%存放每次模拟迭代结果，列向量存放不同调整频率得到的期末价值
end
[l,k]=size(Q_result);
for j=1:k  
    Q_result_adjust(1,j)=mean(Q_result(:,j));  %矩阵的列均值
    Q_result_adjust(2,j)=std(Q_result(:,j));%矩阵的列平方根
    Q_result_adjust(3,j)=  Q_result_adjust(1,j)/ Q_result_adjust(2,j); %校正后的调整策略得分
end
disp '分别按（1，5，10，20）的频率调整策略的结果，第一行为均值，第二行为标准差，第三行为策略得分'
Q_result_adjust%显示各调整频率得分
clear l k j;
%。。。。。。。。。。。。。。。。。。分割线。。。。。。。。。。。。。。。。。。。。。
[a,b]=max(Q_result_adjust(3,:));%找到得分最高的调整方法
disp '模拟数据得分最高的策略采用的调整周期为'
m2=adjust_day(b)
real_S1=SH380(n+1:length(SH380),2);    %提取2013年10月10日至2014年10月10日的实际数据做检测
real_X=real_S1(1);                         %设定期权执行价格期初的风险资产价格
clear a b;
[r_C_result,r_C_lost,r_R]=OBPI(real_S1,rf,segma,W,c);
disp '实际数据四种策略得到的期末策略资产组合价值'
r_C_result
disp '实际数据一年中各策略累积支付的交易费'
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
str=['执行价格X=',num2str(real_X),',调整周期mn=',num2str(mn)];
title(str);
legend('风险资产价值','有交易费投资组合每期期末价值','无交易费投资组合每期期末价值');
hold off
end
clear i;

