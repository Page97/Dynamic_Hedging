%   Description��
%   �ú����������ؿ���ģ�����ɱ���ʲ��۸�·�������β����˶������£�
%   Input��
%   S0-����ʲ��ĳ�ʼ�ļ۸�;
%   K-��Ȩ�۸�
%   r-�޷�������
%   sigma-������(�����׼��)
%   m-ģ��Ĳ���
%   dt-ʱ����(��λ���꣩
%   I-ģ��Ĵ���
%   Output��
%   PathChart-ģ����ı���ʲ��۸�·������һ��Ϊ������ţ�

function PathChart=MonteCarloSimulation(S0,m,dt,sigma,rf,T)
Path=zeros(1,m+1);
PathChart=zeros(m+1,T+1);
PathChart(:,1)=0:m;
for i=1:T
    for t=0:m
        if t==0
            Path(t+1)=S0;
        else
            z = randn(1);
            Path(t+1) = Path(t)*exp((rf-0.5*sigma^2) * dt + sigma * sqrt(dt) * z);
        end
    end
       PathChart(:,i+1)=Path;
end
