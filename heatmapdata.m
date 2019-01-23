%clear
%% Before run the code, load the data Cells.mat, which may be stored in a different directory.
%load('Cells.mat') 
NumNodes=43; % Number of nodes
EachNode=5;  % Number of outputs of each node
NumPaths=54; % Number of nodes
EachPath=8;  % Number of outputs of each path
st=NumNodes*EachNode;
ed=(NumPaths-1)*EachPath+NumNodes*EachNode;

%endt=1400;
%startt=705;

endt=7000;
startt=6350;

u=cells(2:end,1:endt);
xd1=u(st+1:EachPath:ed+1,startt:endt);
yd1=u(st+2:EachPath:ed+2,startt:endt);
xd2=u(st+3:EachPath:ed+3,startt:endt);
yd2=u(st+4:EachPath:ed+4,startt:endt);

[rowxd1,colxd1,vxd1]=find(xd1);
[rowyd1,colyd1,vyd1]=find(yd1);
[rowxd2,colxd2,vxd2]=find(xd2);
[rowyd2,colyd2,vyd2]=find(yd2);

if ~isempty(colxd1)
nonzerot1=cells(1,colxd1+startt-1)-startt+1;
end

if ~isempty(colxd2)
nonzerot2=cells(1,colxd2+startt-1)-startt+1;
end

heat=[vxd1,vyd1,nonzerot1';vxd2,vyd2,nonzerot2'];
% save the heat map data to the current folder
csvwrite('heat.csv',heat);
