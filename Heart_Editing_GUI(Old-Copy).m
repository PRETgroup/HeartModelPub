function Heart_Editing_GUI(mdl,modelName,filename,savepath,raw_excel,raw_probes,raw_paths)
% Copyright 2025 Ben Allen.
% This program is released under license GPL version 3.
close all
global nodes_name
nodes_name = raw_excel(:,1:2);
global node_atts
node_atts = raw_excel(:,2:end);
node_atts(:,end-2) = [];
global probes_name
probes_name = raw_probes(:,1);
global path_atts
path_atts = raw_paths;
%% GUI
global ConfigGUI
% initialization
ConfigGUI.path_plot=[];
ConfigGUI.cells=[];
ConfigGUI.Node_pos=[];
ConfigGUI.t=0;
%% Get the display
pos = get(0, 'screensize'); %get the screensize
W=pos(3);
H=pos(4);
x0=50;
y0=50;
WIDTH=W-50-x0;
HEIGHT=H-100-y0;
%[left bottom width height],the most outer frame 
ConfigGUI.Handle=figure('Units', 'Pixels', 'Position', [x0 y0 WIDTH HEIGHT],...
    'Resize','off','Name','UoA Cardiac Conduction System model','NumberTitle','Off',...
    'AutoResizeChildren','off',...
    'WindowButtonDownFcn',@button_down,'Tag','GUI');
% Cardiac conduction system topology axes
ConfigGUI.TOP_axe=subplot(6,2,[1,3,5,7,9,11],'Parent',ConfigGUI.Handle,...
    'Unit','normalized','OuterPosition',[0 0 1*HEIGHT/WIDTH 1],...
    'Xlim',[40 180],'Ylim',[20 160],...
    'NextPlot','add','Box','on');
axis(ConfigGUI.TOP_axe,'manual');
xlabel(ConfigGUI.TOP_axe,'x');
ylabel(ConfigGUI.TOP_axe,'y');
title(ConfigGUI.TOP_axe,'Cardiac Conduction System');
grid(ConfigGUI.TOP_axe,'on');
colormap(ConfigGUI.TOP_axe,hot);
% Place the Nodes and Probes
ConfigGUI.node_pos=scatter(ConfigGUI.TOP_axe,[],[],100,'filled','LineWidth',2,'Marker','o','CData',[0 0 0]); % black
ConfigGUI.probe_pos=scatter(ConfigGUI.TOP_axe,[],[],'LineWidth',1.5,'Marker','d','CData',[0 0 0]);

% Current position
ConfigGUI.setp=scatter(ConfigGUI.TOP_axe,[],[],'LineWidth',1.5,'Marker','o','CData',[1 0 0]);
ConfigGUI.getp = uicontrol('Parent',ConfigGUI.Handle,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.15 0.96 0.1 0.03],...
    'BackgroundColor',[1 1 1],...
    'String','(x,y)',...
    'HorizontalAlignment','left',...
    'HandleVisibility','callback',...
    'Tag','getp');

% Create a panel for node editing
ConfigGUI.node_edit = uipanel('Parent',ConfigGUI.Handle,...
    'Units','normalized',...
    'Position',[0.5 0.6 0.25 0.3],...
    'Title','Node Edit',...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'HandleVisibility','callback',...
    'Tag','nodePanel');
strings = {'Select Node','Next','Back', 'Update'};
left_positions = [0.05 0.3 0.05 0.55];
bot_positions = [0.8 0 0 0];
h_positions = [0.25 0.25 0.25 0.25];
w_positions = [0.15 0.15 0.15 0.15];
tags = {'selectnode','nextattr','prevattr','attrupdate'};
callbacks = {@localNodeSelect,@localNextNodePressed, @localPrevNodePressed,@localAttrUpdate};
enabled ={'on','on','on', 'on'};
style={'pushbutton','pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_edit,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) h_positions(idx) w_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
ConfigGUI.i = 1;
%Constants

strings = {'Node (i):', 'Attribute:', 'Attribute Value:'};
left_positions = [0.05 0.05 0.05];
bot_positions = [0.6 0.4 0.2];
h_positions = [0.15 0.25 0.35];
w_positions = [0.15 0.15 0.15];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_edit,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) h_positions(idx) w_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
% Node current
ConfigGUI.nodecurr = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.25 0.6 0.25 0.15],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','nodedisp');
% Node Attribute type
ConfigGUI.nodeatt = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.4 0.25 0.15],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','nodeattdisp');
% Node attribute value - editable
ConfigGUI.getnodeatt = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.4 0.2 0.25 0.15],...
    'BackgroundColor',[1 1 1],...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','getnodeatt');
ConfigGUI.nodesetcheck = false;
% use popupmenu in the uicontrol
% uidropdown('Parent',ConfigGUI.node_edit,...
%         'Position',[0.05 0.6 0.25 0.15],...
%         'Items',["N - SA", "N - RE", "N - AV", "M - Atrial","M - Ventricular"],...
%         'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
%         'ValueChangedFcn',@nodetypeChange,...
%         'Enable','on',...
%         'Tag','nodetype');
% Create a panel for path editing
ConfigGUI.path_edit = uipanel('Parent',ConfigGUI.Handle,...
    'Units','normalized',...
    'Position',[0.75 0.6 0.25 0.3],...
    'Title','Path Edit',...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'HandleVisibility','callback',...
    'Tag','pathPanel');
strings = {'Select Path','Next','Back','Update'}; 
left_positions = [0.05 0.3 0.05 0.55];
bot_positions = [0.8 0 0 0 ];
h_positions = [0.25 0.25 0.25 0.25];
w_positions = [0.15 0.15 0.15 0.15];
tags = {'pathselect','nextpathatt','prevpathatt','pathval'};
callbacks = {@localPathSelect,@localNextPathAtt, @localPrevPathAtt,@localPathValUpdate};
enabled ={'on','on','on','on'};
style={'pushbutton','pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_edit,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) h_positions(idx) w_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
ConfigGUI.j = 5;

strings = {'Node 1 (i):', 'Node 2 (j):', 'Attribute:', 'Attribute Value:'};
left_positions = [0.05 0.55 0.05 0.05];
bot_positions = [0.6 0.6 0.4 0.2];
h_positions = [0.25 0.25 0.25 0.35];
w_positions = [0.15 0.15 0.15 0.15];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_edit,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) h_positions(idx) w_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
% Node 1 and 2 numbering
ConfigGUI.node1curr = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.6 0.25 0.15],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node1disp');
ConfigGUI.node2curr = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.75 0.6 0.25 0.15],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node2disp');
% Node Attribute type
ConfigGUI.pathatt = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.4 0.25 0.15],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','pathattdisp');
% Node attribute value - editable
ConfigGUI.getpathatt = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.4 0.2 0.25 0.15],...
    'BackgroundColor',[1 1 1],...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','getpathatt');
ConfigGUI.pathsetcheck = false;
ConfigGUI.firsttime_path = true;
%Load the default model
load_model(filename);
% Store ConfigGUI to Userdata and communicate with the Simulink model
%set_param(sprintf('%s/S-Function',ConfigGUI.modelName),'UserData',ConfigGUI);
%%% SET THE node/path details?????
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function for Load model - displays the system
function load_model(modelcfg)
global ConfigGUI
%[fname,fpath] = uigetfile('*.mat', 'Load VHM Model');
dim=load(modelcfg);
[ConfigGUI.NumNodes,~]=size(dim.Node); % Number of nodes
[ConfigGUI.NumPaths,~]=size(dim.Path); % Number of paths
ConfigGUI.Node_pos=dim.Node_pos;
% Display the nodes and probes; Store the node and probe positions
if ~isempty(ConfigGUI.Node_pos)
    c=zeros(size(ConfigGUI.Node_pos,1),3);
    set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);%'ZData',ConfigGUI.Node_pos(:,3),'CData',c);
    
    for n=1:length(ConfigGUI.Node_pos(:,1))
        text(ConfigGUI.TOP_axe,ConfigGUI.Node_pos(n,1),ConfigGUI.Node_pos(n,2)+2,int2str(n),'Color','blue','FontSize',12);
    end
else
    error('The node position is empty.');
    exit;
end
if ~isempty(dim.Probe_pos)
    set(ConfigGUI.probe_pos,'XData',dim.Probe_pos(:,1),'YData',dim.Probe_pos(:,2));%,'ZData',dim.Probe_pos(:,3));
else
    error('The Probe position is empty.');
    exit;
end
% Draw the paths 
% IMPORTANT HERE: DETERMINE HOW TO MAKE THE PATHS 3D IF NEEDED AT ALL
% add dim.Node_pos(dim.Path(n,3),1) and dim.Node_pos(dim.Path(n,3),2) to
% the x and y respectively when a z dimension is known
for n=1:size(dim.Path,1)
    ConfigGUI.path_plot(n)=line([dim.Node_pos(dim.Path(n,1),1),dim.Node_pos(dim.Path(n,2),1)],[dim.Node_pos(dim.Path(n,1),2),dim.Node_pos(dim.Path(n,2),2)],'LineWidth',1.5,'Color',[0 0 0],'Parent',ConfigGUI.TOP_axe);
end

% Create the legend
legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
hold on;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for selecting the node
function localNodeSelect(hObject,eventdata) %#ok
global ConfigGUI
ConfigGUI.nodesetcheck = true;
% Temporarily disable select node button????
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for next node attribute
function localNextNodePressed(hObject,eventdata) %#ok
global ConfigGUI
global node_atts
% Using current node, cycle to the next attribute
ConfigGUI.i = ConfigGUI.i + 1;
if ConfigGUI.i > size(node_atts,2)
    ConfigGUI.i = 1;
end
set(ConfigGUI.nodeatt,'String',node_atts(1,ConfigGUI.i));
if strcmp(node_atts(1,ConfigGUI.i),'Type')
    set(ConfigGUI.getnodeatt,'String',node_atts{ConfigGUI.ind1+1,ConfigGUI.i});
else
    set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.i}));
end
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for previous node attribute
function localPrevNodePressed(hObject,eventdata)
global ConfigGUI
global node_atts
% Using current node, cycle to the previous attribute
ConfigGUI.i = ConfigGUI.i - 1;
if ConfigGUI.i < 1
    ConfigGUI.i = size(node_atts,2);
end
set(ConfigGUI.nodeatt,'String',node_atts(1,ConfigGUI.i));
if strcmp(node_atts(1,ConfigGUI.i),'Type')
    set(ConfigGUI.getnodeatt,'String',node_atts{ConfigGUI.ind1+1,ConfigGUI.i});
else
    set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.i}));
end
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for updating the current attributes value
function localAttrUpdate(hObject,eventdata) 
global ConfigGUI
% receive the value, check if its NaN, store it in the current nodes, current attribute 

%%% Potentially an extra button to actually store the updated value????
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for selecting the path to edit
function localPathSelect(hObject,eventdata)
global ConfigGUI
ConfigGUI.pathsetcheck = true;
% Temporarily disable select path button????
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for next attribute
function localNextPathAtt(hObject,eventdata)
global ConfigGUI
global path_atts
% Using current node, cycle to the previous attribute
ConfigGUI.j = ConfigGUI.j + 1;
if ConfigGUI.j > 15
    ConfigGUI.j = 5;
end
set(ConfigGUI.pathatt,'String',path_atts(1,ConfigGUI.j));
set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.j}));
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for previous attribute
function localPrevPathAtt(hObject,eventdata)
global ConfigGUI
global path_atts
% Using current node, cycle to the previous attribute
ConfigGUI.j = ConfigGUI.j - 1;
if ConfigGUI.j < 5
    ConfigGUI.j = 15;
end
set(ConfigGUI.pathatt,'String',path_atts(1,ConfigGUI.j));
set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.j}));
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for updating the current attributes value
function localPathValUpdate(hObject,eventdata) 
global ConfigGUI
% receive the value, check if its NaN, store it in the current nodes, current attribute 

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for click
function button_down(hObject,eventdata) 
% IMPORTANT HERE: DETERMINE HOW A MOUSE CLICK IS INTERPRETED FOR A 3D GRAPH
global ConfigGUI
global nodes_name
global probes_name
global node_atts
global path_atts
cursorPoint = get(ConfigGUI.TOP_axe, 'CurrentPoint');
curX = cursorPoint(1,1);
curY = cursorPoint(1,2);
xoffset = 5;
yoffset = 5;
xLimits = get(ConfigGUI.TOP_axe, 'xlim');
yLimits = get(ConfigGUI.TOP_axe, 'ylim');
if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
    set(ConfigGUI.getp,'String',sprintf('(%.2f,%.2f)',curX,curY));
    set(ConfigGUI.setp,'XData',curX,'YData',curY);
    
    % Determine which is the closest Node/Probe
    [~,dist1] = dsearchn([curX,curY],ConfigGUI.Node_pos);
    [~,dist2] = dsearchn([curX,curY],[ConfigGUI.probe_pos.XData.',ConfigGUI.probe_pos.YData.']);
    [m1,ind1]=min(dist1);
    [m2,ind2]=min(dist2);
    if m1 < m2
        str = append('Node: ',int2str(ind1),' = ', nodes_name(ind1+1,1));
        if strcmp('N',nodes_name(ind1+1,2))
            str = [str,'Cell Type: Pacemaker (N)'];
            back_color = [1 1 .3];
        elseif strcmp('NM',nodes_name(ind1+1,2))
            str = [str,'Cell Type: Subsidiary Pacemaker (NM)'];
            back_color = [1 .8 .4];
        elseif strcmp('M',nodes_name(ind1+1,2))
            str = [str,'Cell Type: Myocyte (M)'];
            back_color = [1 .8 .8];
        end
    else
        str = append('Probe: ',int2str(ind2),' = ', probes_name(ind2+1));
        back_color = [.75 .75 .75];
    end
    % Display information for the node
    delete(findobj('tag','mytooltip'))
    text(curX+xoffset,curY+yoffset,str,...
        'backgroundcolor',back_color,'tag','mytooltip','edgecolor',[0 0 0],...
        'hittest','off')

    if ConfigGUI.nodesetcheck
        c=zeros(size(ConfigGUI.Node_pos,1),3);
        ConfigGUI.ind1 = ind1;
        ConfigGUI.i = 1;
        %set the node information based on nearest node
        c(ConfigGUI.ind1,:) = [1 0 0];
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        set(ConfigGUI.nodecurr,'String',sprintf('%s (%i)',nodes_name{ind1+1,1}, ind1));
        set(ConfigGUI.nodeatt,'String',node_atts(1,ConfigGUI.i));
        set(ConfigGUI.getnodeatt,'String',node_atts{ind1+1,ConfigGUI.i});
        ConfigGUI.nodesetcheck = false;
    end
    if ConfigGUI.pathsetcheck
        ConfigGUI.j = 5;
        %set the path information based on nearest two nodes
        if ~ConfigGUI.firsttime_path
            ConfigGUI.path_plot(ConfigGUI.pathind)=line([ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,3},1),...
                ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,4},1)],...
                [ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,3},2),...
                ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,4},2)],'LineWidth',1.5,'Color',[0 0 0],...
                'Parent',ConfigGUI.TOP_axe);
        else
            ConfigGUI.firsttime_path = false;
        end
        ConfigGUI.pathind = nearest_line([curX,curY]);
        ConfigGUI.path_plot(ConfigGUI.pathind)=line([ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,3},1),...
            ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,4},1)],...
            [ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,3},2),...
            ConfigGUI.Node_pos(path_atts{ConfigGUI.pathind+1,4},2)],'LineWidth',1.5,'Color',[1 0 0],...
            'Parent',ConfigGUI.TOP_axe);
        %ConfigGUI.path_plot(ConfigGUI.pathind).Annotation.LegendInformation.IconDisplayStyle = 'off';
        legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
        set(ConfigGUI.node1curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,1},path_atts{ConfigGUI.pathind+1,3}));
        set(ConfigGUI.node2curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,2},path_atts{ConfigGUI.pathind+1,4}));
        set(ConfigGUI.pathatt,'String',path_atts(1,ConfigGUI.j));
        set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.j}));
        ConfigGUI.pathsetcheck = false;
    end
    drawnow update;
else
    set(ConfigGUI.getp,'String',sprintf('(Outside)'));
end

end

function d = point_to_line(pt, v1, v2)
% Euclidean distance to the midpoint of the line  
midpoint = [0.5*(v1(1) +v2(1)) 0.5*(v1(2)+v2(2))];
d = pdist([pt;midpoint],'euclidean');
end

function index = nearest_line(pt)
global ConfigGUI
global path_atts
minimum_val = 1000;
for i = 2:size(path_atts,1)
    curr_dist = point_to_line(pt,ConfigGUI.Node_pos(path_atts{i,3},1:2),ConfigGUI.Node_pos(path_atts{i,4},1:2));
    
    if curr_dist < minimum_val
        minimum_val = curr_dist;
        index = i-1;        
    end
end
end