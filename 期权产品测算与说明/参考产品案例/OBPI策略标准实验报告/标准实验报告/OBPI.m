%输出值C_result为各调整策略的期末组合价值,C_lost为各策略支付的手续费,R为按各调整频率整理的样本数据
function [C_result,C_lost,R]=OBPI(creat_S1,rf,segma,W,c)
X=creat_S1(1); 
adjust_day=[1,5,10,20]; %设定调整频率,便于对比同一组价格序列creat_S1在不同调整频率下的期末价值
for f=1:4                             %f代表第几种调整频率
m=adjust_day(f); 
yushu=mod(length(creat_S1)-1,m);
if yushu>0;
   creat_S1(length(creat_S1)+m-yushu)=creat_S1(length(creat_S1));
else
end
T=(length(creat_S1)-1)/m;
creat_Sm(1)=creat_S1(1);%m表示每隔m个交易日调正一次
for i=1:T
creat_Sm(i+1)=creat_S1(m*i+1);
end
clear i;
%计算第一期应该保持的风险资产头寸
d1(1)=(log(creat_Sm(1)/X)+(rf+0.5*segma^2))/segma;
delta(1)=exp(0)*(normcdf(d1(1))-1);%风险组合组合delta值
wt(1)=normcdf(d1(1));%初始时刻持有的风险资产占原风险资产的比列(等于1-delta)
%建立矩阵C存放资产记录表
C(1,1)=wt(1)*W(1)*(1-c)/creat_Sm(1);%第一期开始时风险资产的份数,0时刻全部资金都持有风险资产
C(1,2)=C(1,1)*creat_Sm(1);%第一期开始时风险资产价值
C(1,3)=C(1,1)*creat_Sm(2);%第一期结束时风险资产价值
C(1,4)=(1-wt(1))*W(1)*(1-c);%第一期开始时无风险资产价值
C(1,5)=C(1,4)*(1+rf*1/T);%第一期结束时无风险资产价值
C(1,6)=(1-wt(1))*W(1)*c+(1-wt(1))*W(1)*c;%第一期支付的交易手续费
C(1,7)=C(1,3)+C(1,5);%第一期结束的总资产
C(1,8)=1;%经过的周数
%假如没有交易费用建立矩阵C_free存放资产记录表
C_free(1,1)=wt(1)*W(1)/creat_Sm(1);%第一期开始时风险资产的份数
C_free(1,3)=C_free(1,1)*creat_Sm(2);%第一期结束时风险资产价值
C_free(1,4)=(1-wt(1))*W(1);%第一期开始时无风险资产价值
C_free(1,5)=C_free(1,4)*(1+rf*1/T);%第一期结束时无风险资产价值
C_free(1,7)=C_free(1,3)+C_free(1,5);%第一期结束的总资产
C_free(1,8)=1;%经过的周数
for t=2:T-1
    d1(t)=(log(creat_Sm(t)/X)+(rf+0.5*segma^2))/segma;%年rf换算成当前区间的值
    delta(t)=exp(0)*(normcdf(d1(t))-1);
    wt(t)=normcdf(d1(t));
    %调整组合的费用按变动金额计算
    C(t,1)=(wt(t)*C(t-1,7)-abs(wt(t)*C(t-1,7)-C(t-1,3))*c)/creat_Sm(t);%扣除调整手续费后某一周开始时风险资产的份数
    C(t,2)=C(t,1)*creat_Sm(t);
    C(t,3)=C(t,1)*creat_Sm(t+1);
    C(t,4)=(1-wt(t))*C(t-1,7)-abs((1-wt(t))*C(t-1,7)-C(t-1,5))*c;%扣除调整手续费某一周开始时无风险资产价值
    C(t,5)=C(t,4)*(1+rf*1/T);
    C(t,6)=C(t-1,6)++abs(wt(t)*C(t-1,7)-C(t-1,3))*c+abs((1-wt(t))*C(t-1,7)-C(t-1,5))*c;%每期调整的累积交易费用
    C(t,7)=C(t,3)+C(t,5);
    C(t,8)=t;
    %假如没有交易费用
    C_free(t,1)=wt(t)*C_free(t-1,7)/creat_Sm(t);%第t期开始时风险资产的份数
    C_free(t,3)=C_free(t,1)*creat_Sm(t+1);%第t期结束时风险资产价值
    C_free(t,4)=(1-wt(t))*C_free(t-1,7);%第t期开始时无风险资产价值
    C_free(t,5)=C_free(t,4)*(1+rf*1/T);%第t期结束时无风险资产价值
    C_free(t,7)=C_free(t,3)+C_free(t,5);%第t期结束的总资产
    C_free(t,8)=t;%经过的周数  
end
   C(T,7)=C(T-1,1)*creat_Sm(T+1)+C(T-1,4)*(1+rf*1/T);
   C_free(T,7)=C_free(T-1,1)*creat_Sm(T+1)+C_free(T-1,4)*(1+rf*1/T);
    clear t;
   %q代表迭代次数，f代表调整频率
   C_result(1,f)=C(T,7);
   C_lost(1,f)=C(T-1,6);%因交易支付的手续费总数
   R{1,f}=creat_Sm;%存放各调整周期的样本数据
   R{2,f}=C;
   R{3,f}=C_free;
   clear creat_Sm C C_free wt delta d1 ;%循环计算不同调整频率时，长度不同，须清除中间变量
end

