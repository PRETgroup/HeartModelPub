function [Node,Node_name,Node_pos,Path,Path_name,Probe,Probe_name,Probe_pos,cfgports]=PreCfgfcn_unified(filexls,Noderange,Node_P_range,Pathrange, Path_P_range, Proberange,filename,datafile,second,create)

% Copyright 2025 Ben Allen.
% This program is released under license GPL version 3.
%% Read paras from xlsx
% Read cfg data from workspace if created network or files if original
if isstruct(create)
    node_atts = create.node_atts;
    path_atts = create.path_atts;
    nodes_name = create.nodes_name;
    Probe_Raw = create.probes;
    Node = cell2mat(node_atts(2:end,2:end-2)); %numerical
    Node_name = nodes_name(2:end,:); %text
    Node_Raw = [nodes_name(2:end,:) node_atts(2:end,2:end-2)]; % both of the above as a cell array??
    Path = cell2mat(path_atts(2:end,3:15)); %numerical
    Path_name = path_atts(2:end,1:2); % text
    Path_Raw = path_atts(2:end,1:15); % (both of the above )
    Node_para = node_atts(1,3:48); %attribute naming
    Path_para = path_atts(1,5:15);
    Probe_name = Probe_Raw(:,1);
    Probe = cell2mat(Probe_Raw(:,2:end));
else
    % Read in Node and Path cfg data depending on unit selected
    if second
        [Node,Node_name,Node_Raw] = xlsread(filexls, 'Node_second',Noderange);
        [Path,Path_name,Path_Raw] = xlsread(filexls, 'Path_second',Pathrange);
    else
        [Node,Node_name,Node_Raw] = xlsread(filexls, 'Node',Noderange);
        [Path,Path_name,Path_Raw] = xlsread(filexls, 'Path',Pathrange);
    end
    [~,Node_para,~] = xlsread(filexls, 'Node',Node_P_range);
    [~,Path_para,~] = xlsread(filexls, 'Path',Path_P_range);
    [Probe,Probe_name,Probe_Raw] = xlsread(filexls, 'Probe',Proberange);
end
Node_pos=Node(:,46:47);
Probe_pos=Probe(:,2:3);
% Save cfg data
% - Nodes
save (filename, 'Node');
save (filename, 'Node_name','-append');
save (filename, 'Node_Raw', '-append');
save (filename, 'Node_pos', '-append');
save (filename, 'Node_para', '-append');
% - Paths
save (filename, 'Path', '-append');
save (filename, 'Path_name', '-append');
save (filename, 'Path_Raw', '-append');
save (filename, 'Path_para', '-append');
% - Probes
save (filename, 'Probe', '-append');
save (filename, 'Probe_name', '-append');
save (filename, 'Probe_Raw', '-append');
save (filename, 'Probe_pos', '-append');
load(filename);
% Create lookup table for parameters update
[r, c]=size(Node);
Node_lookup=zeros(r,c);
[r, c]=size(Path);
Path_lookup=zeros(r,c);

%% Node Assembly
Nodecfg={'23'};
cfgdata=[];
m=0;
for i=1:size(Node,1) %iterates through node list
    % Which type of node
    if strcmp(Node_name{i,2},'M')
        Nodecfg1={'25'};
        cfgdata=horzcat(cfgdata,Node(i,23:47));
        m1=m+1; % the first para
        m=m+25; % the last one; (including x,y)
        m2=m-2; %  the last para (excluding x,y)
        start=23;
        endn=45;
        Node_lookup(i,start:endn)=m1:m2; % para ax0 to para e
        Node_lookup(i,46:47)=m-1:m; % x,y
        Node_lookup(i,48:49)=[0 0];
    elseif strcmp(Node_name{i,2},'N')
        Nodecfg1={'23'};
        cfgdata=horzcat(cfgdata,Node(i,2:22),Node(i,46:47));
        m1=m+1; % the first para
        m=m+23; % the last one; (including x,y)
        m2=m-2; %  the last para (excluding x,y)
        start=2;
        endn=22;       
        Node_lookup(i,start:endn)=m1:m2; % para BCL to para r
        Node_lookup(i,46:47)=m-1:m; % x,y
        Node_lookup(i,48:49)=[0 0];
    elseif strcmp(Node_name{i,2},'NM')
        Nodecfg1={'50'};
        cfgdata=horzcat(cfgdata,Node(i,2:22),Node(i,46:47),Node(i,23:47),1,1);
        m1=m+1; % the first para
        m=m+48; % the last one; (including x,y)
        m2=m-2; %  the last para (excluding x,y)
        start=2;
        endn=45;
        Node_lookup(i,start:22)=m1:m1+20;
        Node_lookup(i,23:endn)=m1+23:m2;
        Node_lookup(i,46:47)=m-1:m;
        m=m+2; % add dij, dji to control the path in between
        Node_lookup(i,48:49)=m-1:m;
    else
        error('The dimension of Nodecfg does not match');
    end
    
    if i>=2
        Nodecfg=strcat(Nodecfg,',',Nodecfg1);
    end
    
end

%% Path Assembly
Pathcfg={'11'};
for i=1:size(Path_name,1)    
    cfgdata=horzcat(cfgdata,Path(i,3:13));
    m1=m+1;
    m=m+11;
    m2=m;
    Path_lookup(i,3:13)=m1:m2;
    if i>=2
        Pathcfg=strcat(Pathcfg,',11');      
    end
end

Node_lookup(:,1)=Node(:,1);
Path_lookup(:,1:2)=Path(:,1:2);

%% Probe Assembly
ARN=0;
ATN=0;
VRN=0;
VTN=0;

for i=1:size(Probe,1) %iterate through probe list
    % Which type of probe
    if strcmp(Probe_name{i,1},'Aring')
        ARN=ARN+1;
        cfgdata=horzcat(cfgdata,Probe(i,2:4));
    elseif strcmp(Probe_name{i,1},'Atip')
        ATN=ATN+1;
        cfgdata=horzcat(cfgdata,Probe(i,2:4));            
    elseif strcmp(Probe_name{i,1},'Vring')
        VRN=VRN+1;
        cfgdata=horzcat(cfgdata,Probe(i,2:4));                
    elseif strcmp(Probe_name{i,1},'Vtip')
        VTN=VTN+1;
        cfgdata=horzcat(cfgdata,Probe(i,2:4));                    
    else
        error('Probe type error!');
    end
end

Probecfg=int2str(ARN*3+ATN*3+VRN*3+VTN*3+4);

cfgdata=horzcat(cfgdata,ARN,ATN,VRN,VTN);
cfgports=strcat('[',Nodecfg,',',Pathcfg,',',Probecfg,']');
save (datafile,'cfgdata');
save (filename, 'cfgports','Node_lookup','Path_lookup','-append');
end
