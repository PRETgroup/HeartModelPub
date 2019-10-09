% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
load('AV_trace_2.mat');
figure;
set(0, 'DefaultAxesColorOrder', [0.0 0.0 0.0]); %black

plot((aprecord(1,:)./1000),aprecord(3,:));
axis([0 70 -20 80]);
h = gca;
h.YTick = [-20 0 60];
xlabel('Time(s)');
ylabel('mV');
hold on;
x=0:30:600;
y=zeros(length(x),1);
plot(x,y,':');
hold on;
x=0:30:600;
y=zeros(length(x),1)-5.6;
plot(x,y,':');
set(0, 'DefaultAxesColorOrder', 'factory');
%grid on;
