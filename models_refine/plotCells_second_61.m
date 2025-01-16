% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
load('N3Cfg_second_61.mat')
load("Cells_second_61.mat")
s=[4 8 9 20 36];% Specify the node number you want to print out
tstart=0;% s Specify the start time
tend=4.5;% s Specify the end time
col_start=find(cells(1,:)<=tstart,1,'last');
col_end=find(cells(1,:)>=tend,1,'first');
if isempty(col_start) || isempty(col_end)
    error('Time span is out of range.');
    exit;
else
    figure;
    ln=length(s);
    m=0;
    ax=zeros(1,ln);
    set(0, 'DefaultAxesColorOrder', [0.0 0.0 0.0]); %black
    hold all;
    margins=[0.02 0.03];
    for i=s %iterates through node list
        m=m+1;
        mtitle=Node_name{i,1};
        ax(1,m)=subtightplot(ln,1,m,margins);
        plot(ax(1,m),(cells(1,col_start:col_end)),cells((i-1)*5+3,col_start:col_end));
        hold on;
        h = gca;
        h.Box=('off');
        ylabel([mtitle '(mV)']);
        xlabel('Time(s)');
    end
    set(0, 'DefaultAxesColorOrder', 'factory');
    % save the figure
    savefig('cells_second.fig');
end