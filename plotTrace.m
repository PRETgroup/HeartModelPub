function plotTrace(heart1,heart0,t0,t1)
% Heart1
figure('rend','painters','pos',[20 30 1900 900]);
LRI=1000;
AVI=170;
URI=500;
VRP=230;
PVARP=250;
nplot=7; % the number of subplots
margins=[0.02 0.03];
ax=zeros(1,nplot);
istart=t0+1;
iend=t1+1;
h1=heart1(:,istart:iend);
h0=heart0(:,istart:iend);
t=h1(1,:);
xmin=t(1);
xmax=t(end);
Aget=h1(2,:);
Vget=h1(3,:);
Agets=Aget(1:2:end);
Vgets=Vget(1:2:end);
egm=[t(1:2:end)' Agets' Vgets'];
csvwrite('egm.csv',egm);
%%Heart0
Aget0=h0(2,:);
Vget0=h0(3,:);
Agets0=Aget0(1:2:end);
Vgets0=Vget0(1:2:end);
egm0=[t(1:2:end)' Agets0' Vgets0'];
csvwrite('egm0.csv',egm0);
%%Heart1 events
as1t=t(find(h1(8,:)));
as1=zeros(1,length(as1t))+1.5;
ap1t=t(find(h1(6,:)));
ap1=zeros(1,length(ap1t))+2;
ast=t(find(h1(10,:)));
as=zeros(1,length(ast))+1.25;

vs1t=t(find(h1(9,:)));
vs1=zeros(1,length(vs1t))-1.5;
vp1t=t(find(h1(7,:)));
vp1=zeros(1,length(vp1t))-2;
vst=t(find(h1(11,:)));
vs=zeros(1,length(vst))-1.25;
%%Heart0 events
as1t0=t(find(h0(8,:)));
as10=zeros(1,length(as1t0))+1.5;
ap1t0=t(find(h0(6,:)));
ap10=zeros(1,length(ap1t0))+2;

vs1t0=t(find(h0(9,:)));
vs10=zeros(1,length(vs1t0))-1.5;
vp1t0=t(find(h0(7,:)));
vp10=zeros(1,length(vp1t0))-2;

%%Heart1
m=1;
ax(1,m)=subtightplot(nplot,1,m,margins);
plot(ax(1,m),t,Aget);
xlim(ax(1,m),[xmin xmax]);
ylabel(ax(1,m),'Aegm');
grid on;
m=2;
ax(1,m)=subtightplot(nplot,1,m,margins);
plot(ax(1,m),t,Vget);
xlim(ax(1,m),[xmin xmax]);
ylabel(ax(1,m),'Vegm');
grid on;
m=3;
ax(1,m)=subtightplot(nplot,1,m,margins);
X={as1t,ap1t,ast,vs1t,vp1t,vst};
Y={as1,ap1,as,vs1,vp1,vs};
cc={'blue','red','magenta','blue','red','magenta'};
mm={'o','^','x','o','v','x'};
for i=1:6
    if isempty(X{i})==0 %not empty
        hh=stem(ax(1,m),X{i},Y{i});
        hh.Color = cc{i};
        hh.Marker = mm{i};
        hold on;
        switch i
            case 1
                saveas1=[as1t' as1'];
                csvwrite('as1.csv',saveas1);
            case 2
                saveap1=[ap1t' ap1'];
                csvwrite('ap1.csv',saveap1);
                nn=length(ap1t);
                for n=1:nn
                    line([ap1t(n),ap1t(n)+AVI],[-1, -1]);
                end
            case 3
                saveas=[ast' as'];
                csvwrite('as.csv',saveas);
                nn=length(ast);
                for n=1:nn
                    line([ast(n),(ast(n)+AVI)],[-1,-1]);
                end
            case 4
                savevs1=[vs1t' vs1'];
                csvwrite('vs1.csv',savevs1);
            case 5
                savevp1=[vp1t' vp1'];
                csvwrite('vp1.csv',savevp1);
                nn=length(vp1t);
                for n=1:nn
                    line([vp1t(n),vp1t(n)+PVARP],[0.5, 0.5]);
                    line([vp1t(n),vp1t(n)+VRP],[-0.5, -0.5]);
                    line([vp1t(n),vp1t(n)+URI],[-1.5, -1.5]);
                    line([vp1t(n),vp1t(n)+LRI-AVI],[1, 1]);
                end
            case 6
                savevs=[vst' vs'];
                csvwrite('vs.csv',savevs);
                nn=length(vst);
                for n=1:nn
                    line([vst(n),vst(n)+PVARP],[0.5, 0.5]);
                    line([vst(n),vst(n)+VRP],[-0.5, -0.5]);
                    line([vst(n),vst(n)+URI],[-1.5, -1.5]);
                    line([vst(n),vst(n)+LRI-AVI],[1, 1]);
                end
                
        end
        
    end
end
axis(ax(1,m),[xmin xmax -2.5 2.5])
ylabel(ax(1,m),'Events');
grid on;
hold off;

%% Heart0
m=4;
ax(1,m)=subtightplot(nplot,1,m,margins);
plot(ax(1,m),t,Aget0);
xlim(ax(1,m),[xmin xmax]);
ylabel(ax(1,m),'Aegm');
grid on;
m=5;
ax(1,m)=subtightplot(nplot,1,m,margins);
plot(ax(1,m),t,Vget0);
xlim(ax(1,m),[xmin xmax]);
ylabel(ax(1,m),'Vegm');
grid on;
m=6;
ax(1,m)=subtightplot(nplot,1,m,margins);
X={as1t0,ap1t0,vs1t0,vp1t0};
Y={as10,ap10,vs10,vp10};
cc={'blue','red','blue','red'};
mm={'o','^','o','v'};
for i=1:4
    if isempty(X{i})==0 %not empty
        hh=stem(ax(1,m),X{i},Y{i});
        hh.Color = cc{i};
        hh.Marker = mm{i};
        hold on;
        switch i
            case 1
                saveas10=[as1t0' as10'];
                csvwrite('as1_0.csv',saveas10);
                nn=length(as1t0);
                for n=1:nn
                    line([as1t0(n),as1t0(n)+AVI],[-1, -1]);
                end
            case 2
                saveap10=[ap1t0' ap10'];
                csvwrite('ap1_0.csv',saveap10);
            case 3
                savevs10=[vs1t0' vs10'];
                csvwrite('vs1_0.csv',savevs10);
                nn=length(vs1t0);
                for n=1:nn
                    line([vs1t0(n),vs1t0(n)+PVARP],[0.5, 0.5]);
                    line([vs1t0(n),vs1t0(n)+VRP],[-0.5, -0.5]);
                    line([vs1t0(n),vs1t0(n)+URI],[-1.5, -1.5]);
                    line([vs1t0(n),vs1t0(n)+LRI-AVI],[1, 1]);
                end
            case 4
                savevp10=[vp1t0' vp10'];
                csvwrite('vp1_0.csv',savevp10);              
        end
    end
end
axis(ax(1,m),[xmin xmax -2.5 2.5])
ylabel(ax(1,m),'Events');
grid on;
hold off;

end