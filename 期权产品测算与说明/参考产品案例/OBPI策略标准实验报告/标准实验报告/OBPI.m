%���ֵC_resultΪ���������Ե���ĩ��ϼ�ֵ,C_lostΪ������֧����������,RΪ��������Ƶ���������������
function [C_result,C_lost,R]=OBPI(creat_S1,rf,segma,W,c)
X=creat_S1(1); 
adjust_day=[1,5,10,20]; %�趨����Ƶ��,���ڶԱ�ͬһ��۸�����creat_S1�ڲ�ͬ����Ƶ���µ���ĩ��ֵ
for f=1:4                             %f����ڼ��ֵ���Ƶ��
m=adjust_day(f); 
yushu=mod(length(creat_S1)-1,m);
if yushu>0;
   creat_S1(length(creat_S1)+m-yushu)=creat_S1(length(creat_S1));
else
end
T=(length(creat_S1)-1)/m;
creat_Sm(1)=creat_S1(1);%m��ʾÿ��m�������յ���һ��
for i=1:T
creat_Sm(i+1)=creat_S1(m*i+1);
end
clear i;
%�����һ��Ӧ�ñ��ֵķ����ʲ�ͷ��
d1(1)=(log(creat_Sm(1)/X)+(rf+0.5*segma^2))/segma;
delta(1)=exp(0)*(normcdf(d1(1))-1);%����������deltaֵ
wt(1)=normcdf(d1(1));%��ʼʱ�̳��еķ����ʲ�ռԭ�����ʲ��ı���(����1-delta)
%��������C����ʲ���¼��
C(1,1)=wt(1)*W(1)*(1-c)/creat_Sm(1);%��һ�ڿ�ʼʱ�����ʲ��ķ���,0ʱ��ȫ���ʽ𶼳��з����ʲ�
C(1,2)=C(1,1)*creat_Sm(1);%��һ�ڿ�ʼʱ�����ʲ���ֵ
C(1,3)=C(1,1)*creat_Sm(2);%��һ�ڽ���ʱ�����ʲ���ֵ
C(1,4)=(1-wt(1))*W(1)*(1-c);%��һ�ڿ�ʼʱ�޷����ʲ���ֵ
C(1,5)=C(1,4)*(1+rf*1/T);%��һ�ڽ���ʱ�޷����ʲ���ֵ
C(1,6)=(1-wt(1))*W(1)*c+(1-wt(1))*W(1)*c;%��һ��֧���Ľ���������
C(1,7)=C(1,3)+C(1,5);%��һ�ڽ��������ʲ�
C(1,8)=1;%����������
%����û�н��׷��ý�������C_free����ʲ���¼��
C_free(1,1)=wt(1)*W(1)/creat_Sm(1);%��һ�ڿ�ʼʱ�����ʲ��ķ���
C_free(1,3)=C_free(1,1)*creat_Sm(2);%��һ�ڽ���ʱ�����ʲ���ֵ
C_free(1,4)=(1-wt(1))*W(1);%��һ�ڿ�ʼʱ�޷����ʲ���ֵ
C_free(1,5)=C_free(1,4)*(1+rf*1/T);%��һ�ڽ���ʱ�޷����ʲ���ֵ
C_free(1,7)=C_free(1,3)+C_free(1,5);%��һ�ڽ��������ʲ�
C_free(1,8)=1;%����������
for t=2:T-1
    d1(t)=(log(creat_Sm(t)/X)+(rf+0.5*segma^2))/segma;%��rf����ɵ�ǰ�����ֵ
    delta(t)=exp(0)*(normcdf(d1(t))-1);
    wt(t)=normcdf(d1(t));
    %������ϵķ��ð��䶯������
    C(t,1)=(wt(t)*C(t-1,7)-abs(wt(t)*C(t-1,7)-C(t-1,3))*c)/creat_Sm(t);%�۳����������Ѻ�ĳһ�ܿ�ʼʱ�����ʲ��ķ���
    C(t,2)=C(t,1)*creat_Sm(t);
    C(t,3)=C(t,1)*creat_Sm(t+1);
    C(t,4)=(1-wt(t))*C(t-1,7)-abs((1-wt(t))*C(t-1,7)-C(t-1,5))*c;%�۳�����������ĳһ�ܿ�ʼʱ�޷����ʲ���ֵ
    C(t,5)=C(t,4)*(1+rf*1/T);
    C(t,6)=C(t-1,6)++abs(wt(t)*C(t-1,7)-C(t-1,3))*c+abs((1-wt(t))*C(t-1,7)-C(t-1,5))*c;%ÿ�ڵ������ۻ����׷���
    C(t,7)=C(t,3)+C(t,5);
    C(t,8)=t;
    %����û�н��׷���
    C_free(t,1)=wt(t)*C_free(t-1,7)/creat_Sm(t);%��t�ڿ�ʼʱ�����ʲ��ķ���
    C_free(t,3)=C_free(t,1)*creat_Sm(t+1);%��t�ڽ���ʱ�����ʲ���ֵ
    C_free(t,4)=(1-wt(t))*C_free(t-1,7);%��t�ڿ�ʼʱ�޷����ʲ���ֵ
    C_free(t,5)=C_free(t,4)*(1+rf*1/T);%��t�ڽ���ʱ�޷����ʲ���ֵ
    C_free(t,7)=C_free(t,3)+C_free(t,5);%��t�ڽ��������ʲ�
    C_free(t,8)=t;%����������  
end
   C(T,7)=C(T-1,1)*creat_Sm(T+1)+C(T-1,4)*(1+rf*1/T);
   C_free(T,7)=C_free(T-1,1)*creat_Sm(T+1)+C_free(T-1,4)*(1+rf*1/T);
    clear t;
   %q�������������f�������Ƶ��
   C_result(1,f)=C(T,7);
   C_lost(1,f)=C(T-1,6);%����֧��������������
   R{1,f}=creat_Sm;%��Ÿ��������ڵ���������
   R{2,f}=C;
   R{3,f}=C_free;
   clear creat_Sm C C_free wt delta d1 ;%ѭ�����㲻ͬ����Ƶ��ʱ�����Ȳ�ͬ��������м����
end

