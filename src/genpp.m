% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
% load the mat file which contains all configurations of heart model, which will be used to look up
filename='N3Cfg.mat'; 
load(filename);
nn=length(ppNode(:,1)); % The number of node parameters;
np=length(ppPath(:,1)); % The number of path parameters;
pp=zeros(1,nn+np);
pRange=zeros(nn+np,2);
% Look up the port number of node parameters
pNode=zeros(1,nn);
for i=1:nn
    Num=ppNode(i,1);
    Para=ppNode(i,2);
    n=Para+1;
    pNode(i)=Node_lookup(Num,n);
    pp(i)=ppNode(i,3);
    pRange(i,1:2)=ppNode(i,4:5);
end
% Look up the port number of path parameters
pPath=zeros(1,np);
for i=1:np
    Num=ppPath(i,1);
    Para=ppPath(i,2);
    n=Para+2;    
    pPath(i)=Path_lookup(Num,n);
    pp(i+nn)=ppPath(i,3);
    pRange(i+nn,1:2)=ppPath(i,4:5);
end
% save the new parameters
filename='parasMulti3.mat';
save (filename, 'ppNode','ppPath','pNode','pPath','pp','pRange');