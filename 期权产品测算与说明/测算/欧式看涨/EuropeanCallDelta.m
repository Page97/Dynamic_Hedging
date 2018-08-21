%   �ú�����������ĳʱ��ŷʽ������Ȩ��deltaֵ
%   Input:
%   S-����ʲ����ּ�
%   K-��Ȩ��
%   segma-����ʲ��۸���껯������
%   rf-�޷�������
%   T-�ൽ���յ�ʱ�䣨��λ���꣩
%   Output:
%   delta-����Ȩ��deltaֵ
%   Author:
%   PageZhao 20180522

function delta=EuropeanCallDelta(S,K,v,rf,T)
d1=(log(S/K)+(rf+0.5*v^2)*T)/(v*T^0.5);
delta=normcdf(d1); %��Ȩ��deltaֵ
end
