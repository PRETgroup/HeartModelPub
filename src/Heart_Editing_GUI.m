function Heart_Editing_GUI(filename,nodes_name,probes_name,model_params,node_atts,node_atts_copy,path_atts,path_atts_copy,timescale,model)

close all
global nodes_name
global probes_name
global node_atts_copy 
global path_atts_copy 
global node_atts
global path_atts
global model_params
global timescale
%% GUI
global ConfigGUI
node_temp = cell2mat(node_atts_copy(2:44,3:50));
node_temp(:,45:46)=40000;
node_temp(isnan(node_temp))=40000;
[ConfigGUI.node_presets,ConfigGUI.unique_node_idx] = unique(node_temp,'rows');
ConfigGUI.node_presets = changem(ConfigGUI.node_presets,NaN,40000);
ConfigGUI.unique_node_idx = ConfigGUI.unique_node_idx +1;
path_temp = cell2mat(path_atts_copy(2:55,5:15));
[ConfigGUI.path_presets,ConfigGUI.unique_path_idx] = unique(path_temp,'rows');
ConfigGUI.unique_path_idx = ConfigGUI.unique_path_idx +1;
% initialization
ConfigGUI.path_plot=[];
ConfigGUI.cells=[];
ConfigGUI.Node_pos=[];
ConfigGUI.t=0;
ConfigGUI.model=model;
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
xlabel(ConfigGUI.TOP_axe,'x (mm)');
ylabel(ConfigGUI.TOP_axe,'y (mm)');
title(ConfigGUI.TOP_axe,'Cardiac Conduction System');
grid(ConfigGUI.TOP_axe,'on');
colormap(ConfigGUI.TOP_axe,hot);
% Place the Nodes and Probes
ConfigGUI.node_pos=scatter(ConfigGUI.TOP_axe,[],[],100,'filled','LineWidth',2,'Marker','o','CData',[0 0 0]); % black
ConfigGUI.probe_pos=scatter(ConfigGUI.TOP_axe,[],[],'LineWidth',1.5,'Marker','d','CData',[0 0 0]);

strings = {'Save & Quit','Quit'};
left_positions = [0.3 0.4];
bot_positions = [0.0 0.0];
h_positions = [0.05 0.05];
w_positions = [0.1 0.1];
tags = {'save','quit'};
callbacks = {@saveGUI,@closeGUI};
enabled ={'on','on'};
style={'pushbutton','pushbutton'};
for idx=1:length(strings)
    uicontrol('Parent',ConfigGUI.Handle,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
% Current position
ConfigGUI.setp=scatter(ConfigGUI.TOP_axe,[],[],'LineWidth',1.5,'Marker','^','CData',[1 0 1]);
uicontrol('Parent',ConfigGUI.Handle,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.07 0.96 0.1 0.03],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','Cursor Location',...
    'HorizontalAlignment','left',...
    'HandleVisibility','callback');
ConfigGUI.getp = uicontrol('Parent',ConfigGUI.Handle,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.15 0.96 0.1 0.03],...
    'BackgroundColor',[1 1 1],...
    'String','(x,y)',...
    'HorizontalAlignment','left',...
    'HandleVisibility','callback',...
    'Tag','getp');

tabs = uitabgroup(ConfigGUI.Handle,'Position',[0.5 0.05 0.5 0.9]);
%% Create a panel for node editing
ConfigGUI.node_edit = uitab(tabs,'Title','Node Edit');
% streamline the buttons
strings = {'Select Node','Reset', 'Update', 'Plot AP'};
left_positions = [0.05 0.8 0.7 0.15];
bot_positions = [0.8 0.7 0.7 0.6];
h_positions = [0.15 0.1 0.1 0.15];
w_positions = [0.15 0.1 0.1 0.15];
tags = {'selectnode','reset','attrupdate', 'plotnodetrace'};
callbacks = {@localNodeSelect,@localResetNodeAttr,@localAttrUpdate, @localPlotNodeAP};
enabled ={'on','off','off','off'};
style={'pushbutton','pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_edit,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
%Constants

strings = {'Node (i):', 'Type:', 'Attribute:', 'Attribute Value:'};
left_positions = [0.2 0.4 0.2 0.45];
bot_positions = [0.85 0.85 0.8 0.8];
h_positions = [0.1 0.1 0.05 0.05];
w_positions = [0.1 0.1 0.1 0.15];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_edit,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
% Node current
ConfigGUI.nodecurr = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.85 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','nodedisp');
ConfigGUI.nodetypecurr = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.5 0.85 0.05 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','nodetypedisp');

% Node Attribute type
ConfigGUI.nodeatt = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.8 0.15 0.05],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String',cellstr(node_atts(1,3:end)),...
    'HandleVisibility','callback',...
    'Callback',@localNodeAttrClick,...
    'Tag','nodeattdisp');
% Node attribute value - editable
ConfigGUI.getnodeatt = uicontrol('Parent',ConfigGUI.node_edit,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.6 0.8 0.15 0.05],...
    'BackgroundColor',[1 1 1],...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','getnodeatt');
ConfigGUI.nodesetcheck = false;
% Display a plot for the action potential trace
ConfigGUI.AP_nodetrace=subplot(6,2,[1,3,5,7,9,11],'Parent',ConfigGUI.node_edit,...
    'Unit','normalized','Position',[0.1 0.1 0.85 0.5],...
    'NextPlot','add','Box','on');
ConfigGUI.trace = line(ConfigGUI.AP_nodetrace,[],[],'LineWidth',1.5);
xlabel(ConfigGUI.AP_nodetrace,sprintf('Time (%s)',timescale));
ylabel(ConfigGUI.AP_nodetrace,'Membrane Potential (mV)');
title(ConfigGUI.AP_nodetrace,'Cell Action Potential');
grid(ConfigGUI.AP_nodetrace,'on');

%% Create a panel for path editing
ConfigGUI.path_edit = uitab(tabs,'Title','Path Edit');
strings = {'Select Path','Update','Reset'}; 
left_positions = [0.05 0.7 0.8];
bot_positions = [0.8 0.7 0.7];
h_positions = [0.15 0.1 0.1];
w_positions = [0.15 0.1 0.1];
tags = {'selectpath','pathval', 'pathvalreset'};
callbacks = {@localPathSelect,@localPathValUpdate,@localPathReset};
enabled ={'on','off','off'};
style={'pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_edit,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end

strings = {'Node 1 (i):', 'Node 2 (j):', 'Attribute:', 'Attribute Value:', sprintf('A delay (%s):',timescale), sprintf('R delay (%s):',timescale)};
left_positions = [0.2 0.4 0.2 0.45 0.2 0.4];
bot_positions = [0.85 0.85 0.8 0.8 0.7 0.7];
h_positions = [0.1 0.1 0.05 0.05 0.1 0.1];
w_positions = [0.1 0.1 0.1 0.15 0.1 0.1];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_edit,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
% Node 1 and 2 numbering
ConfigGUI.node1curr = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.85 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node1disp');
ConfigGUI.node2curr = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.5 0.85 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node2disp');
% Node Attribute type
ConfigGUI.pathatt = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.8 0.15 0.05],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String',cellstr(path_atts(1,5:15)),...
    'HandleVisibility','callback',...
    'Callback',@localPathAttrClick,...
    'Tag','pathattdisp');
% Node attribute value - editable
ConfigGUI.getpathatt = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.6 0.8 0.15 0.05],...
    'BackgroundColor',[1 1 1],...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','getpathatt');
ConfigGUI.adelay = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.7 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','Adelay');
ConfigGUI.rdelay = uicontrol('Parent',ConfigGUI.path_edit,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.5 0.7 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','Rdelay');
ConfigGUI.pathsetcheck = false;
ConfigGUI.firsttime_path = true;
%% Tab for creating nodes as well as deleting them
ConfigGUI.node_create = uitab(tabs,'Title','Node Creation');
% 1. Receive click location to place the node
ConfigGUI.selectlocal = false;
strings = {'Select Location','Save','Cancel'}; 
left_positions = [0.05 0.5 0.6];
bot_positions = [0.8 0.8 0.8];
h_positions = [0.15 0.1 0.1];
w_positions = [0.15 0.1 0.1];
tags = {'selectlocation','savenode','cancelnode'};
callbacks = {@selectlocation,@savenode,@cancelnode};
enabled ={'on','off','off'};
style={'pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_create,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
% Name the node
ConfigGUI.nodename = uicontrol('Parent',ConfigGUI.node_create,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.35 0.8 0.15 0.1],...
    'BackgroundColor', get(ConfigGUI.Handle,'Color'),...
    'String','NewCell_1',...
    'HandleVisibility','callback',...
    'Tag','nodepreset');
% 2. Select which preset to use as a base
%ConfigGUI.node_presets for the raw info
strings = cell(length(ConfigGUI.unique_node_idx),1);
for idx = 1:length(ConfigGUI.unique_node_idx)
    strings{idx} = append(node_atts_copy{ConfigGUI.unique_node_idx(idx),1},' ','-',' ',...
        nodes_name{ConfigGUI.unique_node_idx(idx)});
end
% N/M/NM plus the name of node to name the preset (strings)
ConfigGUI.nodepreset = uicontrol('Parent',ConfigGUI.node_create,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.35 0.8 0.15 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String',strings,...
    'HandleVisibility','callback',...
    'Tag','nodepreset');
strings = {'Node Preset:', 'Node Name:'};
left_positions = [0.25 0.25];
bot_positions = [0.85 0.75];
h_positions = [0.1 0.1];
w_positions = [0.1 0.1];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_create,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
ConfigGUI.nodecheck = false;
strings = {'Select Node for Deletion','Delete Node', 'Cancel Node Deletion'}; 
left_positions = [0.25 0.5 0.75];
bot_positions = [0.5 0.5 0.5];
h_positions = [0.15 0.15 0.15];
w_positions = [0.25 0.15 0.15];
tags = {'selectnodedel','delnode','cancelnodedel'};
callbacks = {@nodeSelect,@deleteNode,@nodeCancelDel};
enabled ={'on','off','off'};
style={'pushbutton','pushbutton','pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.node_create,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end


%% Tab for creating paths as well as deleting them
ConfigGUI.path_create = uitab(tabs,'Title','Path Creation');

strings = {'Select Node 1','Select Node 2','Save','Cancel'}; 
left_positions = [0.05 0.45 0.5 0.6];
bot_positions = [0.8 0.8 0.65 0.65];
h_positions = [0.15 0.15 0.1 0.1];
w_positions = [0.15 0.15 0.1 0.1];
tags = {'node1','node2', 'savepath', 'cancelpath'};
callbacks = {@node1select,@node2select,@savepath, @cancelpath};
enabled ={'on','on','off', 'off'};
style={'pushbutton','pushbutton','pushbutton', 'pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_create,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
ConfigGUI.node1set = false;
ConfigGUI.node2set = false;

strings = cell(length(ConfigGUI.unique_path_idx),1);
for idx = 1:length(ConfigGUI.unique_path_idx)
    strings{idx} = append(path_atts_copy{ConfigGUI.unique_path_idx(idx),1},' ','-',' ',...
        path_atts_copy{ConfigGUI.unique_path_idx(idx),2});
end
ConfigGUI.pathpreset = uicontrol('Parent',ConfigGUI.path_create,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.35 0.65 0.15 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String',strings,...
    'HandleVisibility','callback',...
    'Tag','pathpreset');
% Nodes selected for the path
ConfigGUI.node1path = uicontrol('Parent',ConfigGUI.path_create,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.3 0.85 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node1path');
ConfigGUI.node2path = uicontrol('Parent',ConfigGUI.path_create,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.7 0.85 0.1 0.1],...
    'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
    'String','N/A',...
    'HandleVisibility','callback',...
    'Tag','node2path');

strings = {'Node 1 (i):', 'Node 2 (j):', 'Path Preset:'};
left_positions = [0.2 0.6 0.25];
bot_positions = [0.85 0.85 0.65];
h_positions = [0.1 0.1 0.15];
w_positions = [0.1 0.1 0.1];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_create,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end

ConfigGUI.pathcheck = false;
strings = {'Select Path for Deletion','Delete Path', 'Cancel Deletion'}; 
left_positions = [0.25 0.5 0.75];
bot_positions = [0.5 0.5 0.5];
h_positions = [0.15 0.15 0.15];
w_positions = [0.25 0.15 0.15];
tags = {'selectpathdel','delpath', 'cancelpathdel'};
callbacks = {@pathSelect,@deletePath, @pathCancelDel};
enabled ={'on','off', 'off'};
style={'pushbutton','pushbutton', 'pushbutton'};
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_create,...
        'Style',style{idx},...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'Enable',enabled{idx},...
        'Callback',callbacks{idx},...
        'HandleVisibility','callback',...
        'Tag',tags{idx});
end
ConfigGUI.path_ind_visual = 0;
ConfigGUI.pathind = 0;
ConfigGUI.ind1 = 0;
ConfigGUI.ind2 = 0;
ConfigGUI.node1ind = 0;
ConfigGUI.node2ind = 0;
%Load the default model
load_model(filename);
waitfor(ConfigGUI.Handle);
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
        text(ConfigGUI.TOP_axe,ConfigGUI.Node_pos(n,1),ConfigGUI.Node_pos(n,2)+2,int2str(n),'Color','blue','FontSize',12,'tag',sprintf('cell%i',n));
    end
    ConfigGUI.node_connections = 1:length(ConfigGUI.Node_pos);
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
    ConfigGUI.path_plot(n)=line([dim.Node_pos(dim.Path(n,1),1),dim.Node_pos(dim.Path(n,2),1)],...
        [dim.Node_pos(dim.Path(n,1),2),dim.Node_pos(dim.Path(n,2),2)],'LineWidth',1.5,'Color',[0 0 0],...
        'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',n));
end
ConfigGUI.path_connections = [1:size(dim.Path,1).'; dim.Path(:,1).'; dim.Path(:,2).'].';
% Create the legend
legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
I = imread('heartoutline.jpg'); 
x = [20 180];
y = [28 192];
I = flipdim(I, 1);
h= image(ConfigGUI.TOP_axe,x,y,I); 
uistack(h,'bottom')
hold on;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Node edit functions
% Callback Function for selecting the node
function localNodeSelect(hObject,eventdata) %#ok
global ConfigGUI
ConfigGUI.nodesetcheck = true;
b = findobj('tag','selectnode');
b.Enable = 'off';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for attribute selection
function localNodeAttrClick(hObject,eventdata)
global ConfigGUI
global node_atts
if ConfigGUI.ind1 ~= 0
    set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2}));
end
drawnow update;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for previous node attribute
function localResetNodeAttr(hObject,eventdata)
global ConfigGUI
global node_atts
global node_atts_copy
% store the previous node attributes
temp = node_atts;
temp{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2} = node_atts_copy{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2};
assignin('base','node_atts',temp)
set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2}));
drawnow update;
b = findobj('tag','reset');
b.Enable = 'off';
b = findobj('tag','attrupdate');
b.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for updating the current attributes value
function localAttrUpdate(hObject,eventdata) 
global ConfigGUI
global node_atts
% receive the value, check if its NaN, store it in the current nodes, current attribute 
val = str2double(get(ConfigGUI.getnodeatt,'String'));
if isnan(val)
    disp('Error occured. Please ensure value is numeric.')
else
    temp = node_atts;
    temp{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2} = val;
    assignin('base','node_atts',temp);
end
drawnow update;
b = findobj('tag','reset');
b.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting the currently selected nodes AP
function localPlotNodeAP(hObject,eventdata)
global ConfigGUI
global node_atts
global node_atts_copy
global params
b = findobj('tag','plotnodetrace');
b.Enable = 'off';
params = [];
% plot the current nodes model trace
if strcmp('N',node_atts(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(cat(2,node_atts(ConfigGUI.ind1+1,3:23),...
        node_atts(ConfigGUI.ind1+1,end-3:end-2)))]);
    test = load_system("N_v6_GUI.slx");
elseif strcmp('M',node_atts(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(node_atts(ConfigGUI.ind1+1,24:end-2))]);
    test = load_system("M_v4_GUI.slx");
elseif strcmp('NM',node_atts(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(node_atts(ConfigGUI.ind1+1,3:end-2)) 1 1]);
    test = load_system("NM_v4_GUI.slx");
end
qv = sim(test);
time = qv.APvoltage.time;
trace = qv.APvoltage.data;
close_system(test)
delete(findobj('tag','myAlteredTrace'))
line(ConfigGUI.AP_nodetrace,time,trace,'color',[0 1 0],'LineWidth',2,'tag','myAlteredTrace')
hold on;
% plot the current nodes model trace
if strcmp('N',node_atts_copy(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(cat(2,node_atts_copy(ConfigGUI.ind1+1,3:23),...
        node_atts_copy(ConfigGUI.ind1+1,end-3:end-2)))]);
    test = load_system("N_v6_GUI.slx");
elseif strcmp('M',node_atts_copy(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(node_atts_copy(ConfigGUI.ind1+1,24:end-2))]);
    test = load_system("M_v4_GUI.slx");
elseif strcmp('NM',node_atts_copy(ConfigGUI.ind1+1,1))
    assignin('base','params',[cell2mat(node_atts_copy(ConfigGUI.ind1+1,3:end-2)) 1 1]);
    test = load_system("NM_v4_GUI.slx");
end
qv = sim(test);
time = qv.APvoltage.time;
trace = qv.APvoltage.data;
close_system(test)
delete(findobj('tag','myOgTrace'))
line(ConfigGUI.AP_nodetrace,time,trace,'color',[0 0 0],'LineWidth',2,'tag','myOgTrace')
drawnow update;
b = findobj('tag','plotnodetrace');
b.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for selecting the path
% Callback Function for selecting the path to edit
function localPathSelect(hObject,eventdata)
global ConfigGUI
ConfigGUI.pathsetcheck = true;
p = findobj('tag','selectpath');
p.Enable = 'off';        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for next attribute
function localPathAttrClick(hObject,eventdata)
global ConfigGUI
global path_atts
if ConfigGUI.pathind ~= 0
    set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4}));
end
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for resetting the currently selected attribute
function localPathReset(hObject,eventdata)
global ConfigGUI
global path_atts
global path_atts_copy
% store the previous node attributes
temp = path_atts;
temp{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4} = path_atts_copy{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4};
temp{ConfigGUI.pathind+1,21} = temp{ConfigGUI.pathind+1,20}/temp{ConfigGUI.pathind+1,5};
temp{ConfigGUI.pathind+1,22} = temp{ConfigGUI.pathind+1,20}/temp{ConfigGUI.pathind+1,10};
assignin('base','path_atts',temp)
set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4}));
set(ConfigGUI.adelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,21}));
set(ConfigGUI.rdelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,22}));
drawnow update;
p = findobj('tag','pathvalreset');
p.Enable = 'off';
p = findobj('tag','pathval');
p.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for updating the current attributes value
function localPathValUpdate(hObject,eventdata) 
global ConfigGUI
global path_atts
% receive the value, check if its NaN, store it in the current nodes, current attribute 
val = str2double(get(ConfigGUI.getpathatt,'String'));
if isnan(val)
    disp('Error occured. Please ensure value is numeric.')
else
    temp = path_atts;
    temp{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4} = val;
    temp{ConfigGUI.pathind+1,21} = temp{ConfigGUI.pathind+1,20}/temp{ConfigGUI.pathind+1,5};
    temp{ConfigGUI.pathind+1,22} = temp{ConfigGUI.pathind+1,20}/temp{ConfigGUI.pathind+1,10};
    assignin('base','path_atts',temp);
    set(ConfigGUI.adelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,21}));
    set(ConfigGUI.rdelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,22}));
end
drawnow update;
p = findobj('tag','pathvalreset');
p.Enable = 'on';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for creating a node
% Select the location for the node
function selectlocation(hObject,eventdata)
global ConfigGUI
ConfigGUI.selectlocal = true;
b = findobj('tag','selectlocation');
b.Enable = 'off';
end
% Save the current node with drop down preset
function savenode(hObject,eventdata)
global ConfigGUI
global node_atts
global node_atts_copy
global nodes_name
% Save the position of the node to the graph
if ismember(ConfigGUI.nodename.String,nodes_name)
    f =msgbox("Cell Name already exists","Error","error");
    waitfor(f);
    return
end
c = get(ConfigGUI.node_pos,'CData');
x_temp = get(ConfigGUI.node_pos,'XData');
y_temp = get(ConfigGUI.node_pos,'YData');
x = x_temp(end);
y = y_temp(end);
ConfigGUI.Node_pos(end+1,:) = [x y];
c(end,:) = [0 0 0];
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
n = unique_num(ConfigGUI.node_connections);
text(ConfigGUI.TOP_axe,ConfigGUI.Node_pos(end,1),ConfigGUI.Node_pos(end,2)+2,int2str(n),'Color','blue','FontSize',12,'tag',sprintf('cell%i',n));
% Get the attributes for the new node
type_node = strsplit(ConfigGUI.nodepreset.String{ConfigGUI.nodepreset.Value});
type_node = type_node{1};
atts = ConfigGUI.node_presets(ConfigGUI.nodepreset.Value,:);
atts(45:46) = [x y];
% Save the new nodes attributes in the correct arrays 
temp = nodes_name;
temp(end+1,:) = [{ConfigGUI.nodename.String} type_node];
assignin('base','nodes_name',temp)
temp = node_atts;
temp(end+1,:) = [type_node n num2cell(atts)];
assignin('base','node_atts',temp)
temp = node_atts_copy;
temp(end+1,:) = [type_node n num2cell(atts)];
assignin('base','node_atts_copy',temp)
ConfigGUI.node_connections(end+1)=n;
b = findobj('tag','selectlocation');
b.Enable = 'on';
b = findobj('tag','savenode');
b.Enable = 'off';
b = findobj('tag','cancelnode');
b.Enable = 'off';
end
% Cancel the current node creation
function cancelnode(hObject,eventdata)
global ConfigGUI
% Removing the node from the graph
c = get(ConfigGUI.node_pos,'CData');
c(end,:) = [];
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
b = findobj('tag','selectlocation');
b.Enable = 'on';
b = findobj('tag','savenode');
b.Enable = 'off';
b = findobj('tag','cancelnode');
b.Enable = 'off';
end
% Function for selecting the node to delete
function nodeSelect(hObject,eventdata)
global ConfigGUI
ConfigGUI.nodecheck = true;
b = findobj('tag','selectnodedel');
b.Enable = 'off';
end
% Function for selecting the node to delete
function nodeCancelDel(hObject,eventdata)
global ConfigGUI
c = get(ConfigGUI.node_pos,'CData');
color = [1 0 0];        
[q, idx] = ismember(color,c,'rows');
if q
    if(idx == ConfigGUI.ind1)
        c(idx,:) = [0 0 1];
    elseif (idx == ConfigGUI.node1ind)
        c(idx,:) = [1 1 0];
    elseif(idx == ConfigGUI.node2ind)
        c(idx,:) = [1 0 1];
    else
        c(idx,:) = [0 0 0];
    end
end
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
ConfigGUI.ind2 = 0;
b = findobj('tag','delnode');
b.Enable = 'off';
b = findobj('tag','selectnodedel');
b.Enable = 'on';
p = findobj('tag', 'cancelnodedel');
p.Enable = 'off';
end
% Deleting the node from the model
function deleteNode(hObject,eventdata)
global ConfigGUI
global node_atts
global nodes_name
global node_atts_copy
global path_atts
global path_atts_copy
b = findobj('tag','delnode');
b.Enable = 'off';
b = findobj('tag','cancelnodedel');
b.Enable = 'off';
% Checks if theres an overlap with other tabs
if ConfigGUI.ind1 == ConfigGUI.ind2
    set(ConfigGUI.nodecurr,'String','N/A');
    set(ConfigGUI.nodetypecurr,'String','N/A');
    set(ConfigGUI.getnodeatt,'String','N/A');
    b = findobj('tag','selectnode');
    b.Enable = 'on';
    b = findobj('tag','reset');
    b.Enable = 'off';
    b = findobj('tag','attrupdate');
    b.Enable = 'off';
    b = findobj('tag','plotnodetrace');
    b.Enable = 'off';        
    ConfigGUI.ind1 = 0;
end
if ConfigGUI.ind2 == ConfigGUI.node1ind
    set(ConfigGUI.node1path, 'String', 'N/A');      
    b = findobj('tag','savepath');
    b.Enable = 'off';
    ConfigGUI.node1ind = 0;
end
if ConfigGUI.ind2 == ConfigGUI.node2ind
    set(ConfigGUI.node2path, 'String', 'N/A');       
    b = findobj('tag','savepath');
    b.Enable = 'off';
    ConfigGUI.node2ind = 0;
end
% Delete the node physically from the plot
ConfigGUI.Node_pos(ConfigGUI.ind2,:) = [];
ConfigGUI.node_connections(ConfigGUI.ind2) = [];
c = get(ConfigGUI.node_pos,'CData');
c(ConfigGUI.ind2,:) = [];
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
% Delete the node from the arrays
true_index = node_atts{ConfigGUI.ind2+1,2};
partial1 =[node_atts{2:end,2}].';
[index1,~] = find(partial1 == true_index);
index1 = index1+1;
temp = node_atts;
temp(index1,:) = [];
assignin('base','node_atts',temp)
temp = node_atts_copy;
temp(index1,:) = [];
assignin('base','node_atts_copy',temp)
temp = nodes_name;
temp(index1,:) = [];
assignin('base','nodes_name',temp)
delete(findobj('tag',sprintf('cell%i',true_index)));
% Delete the paths connected to the node being deleted
partial1 =[path_atts{2:end,3}; path_atts{2:end,4}].';
[index1,~] = find(partial1 == true_index);
[index_visual,~] = find(ConfigGUI.path_connections(:,2:end) == true_index);
index_visual=index1;
% Selecting multiple paths to delete from a row
delete(ConfigGUI.path_plot([ConfigGUI.path_connections([index_visual])]))
for idx =1:length(index_visual)
    delete(findobj('tag',sprintf('path%i',ConfigGUI.path_connections(index_visual(idx)))));
end
% alternatively this could also be an issue, try contains(array,pattern) instead
if ismember(ConfigGUI.path_ind_visual,ConfigGUI.path_connections([index_visual],1))
    p = findobj('tag','selectpathdel');
    p.Enable = 'on'; 
    p = findobj('tag', 'cancelpathdel');
    p.Enable = 'off';
    p = findobj('tag','delpath');
    p.Enable = 'off';       
    ConfigGUI.path_ind_visual = 0;
end
if ismember(ConfigGUI.pathind,ConfigGUI.path_connections([index_visual],1))
    ConfigGUI.firsttime_path = true;
    ConfigGUI.pathind = 0;
end
ConfigGUI.path_connections([index_visual],:) = [];
index1 = index1+1;
temp = path_atts;
temp(index1,:) = [];
assignin('base','path_atts',temp)
temp = path_atts_copy;
temp(index1,:) = [];
assignin('base','path_atts_copy',temp)
ConfigGUI.ind2 = 0;
delete(findobj('tag','mytooltip'))
drawnow update;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for creating a path
% Selecting the first node in the path
function node1select(hObject,eventdata)
global ConfigGUI
p = findobj('tag','node1');
p.Enable = 'off';        
p = findobj('tag','node2');
p.Enable = 'off';       
ConfigGUI.node1set = true;
end
% Selecting the second node in the path
function node2select(hObject,eventdata)
global ConfigGUI
p = findobj('tag','node1');
p.Enable = 'off';        
p = findobj('tag','node2');
p.Enable = 'off';       
ConfigGUI.node2set = true;
end
% Save the current path with drop down preset
function savepath(hObject,eventdata)
global ConfigGUI
global path_atts
global path_atts_copy
global nodes_name
n = unique_num(ConfigGUI.path_connections(:,1));
ConfigGUI.path_plot(end+1)=line([ConfigGUI.Node_pos(ConfigGUI.node1ind,1),ConfigGUI.Node_pos(ConfigGUI.node2ind,1)],...
 [ConfigGUI.Node_pos(ConfigGUI.node1ind,2),ConfigGUI.Node_pos(ConfigGUI.node2ind,2)],'LineWidth',1.5,'Color',[0 0 0],...
 'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',n));
ConfigGUI.path_connections(end+1,:) = [n, ConfigGUI.node1ind, ConfigGUI.node2ind];
legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
atts = ConfigGUI.path_presets(ConfigGUI.pathpreset.Value,:);
x1 = ConfigGUI.Node_pos(ConfigGUI.node1ind,1);
x2 = ConfigGUI.Node_pos(ConfigGUI.node2ind,1);
y1 = ConfigGUI.Node_pos(ConfigGUI.node1ind,2);
y2 = ConfigGUI.Node_pos(ConfigGUI.node2ind,2);
dist = sqrt((x1-x2)^2+(x1-x2)^2);
adelay = dist/atts(1);
rdelay = dist/atts(6);
update=[nodes_name(ConfigGUI.node1ind+1,1) nodes_name(ConfigGUI.node2ind+1,1) ...
    ConfigGUI.node1ind ConfigGUI.node2ind...
    num2cell(atts) x1 y1 x2 y2 dist adelay rdelay NaN NaN NaN];
temp = path_atts;
temp(end+1,:)=update;
assignin('base','path_atts',temp)
temp = path_atts_copy;
temp(end+1,:)=update;
assignin('base','path_atts_copy',temp)
set(ConfigGUI.node1path, 'String','N/A');
set(ConfigGUI.node2path, 'String','N/A');
ConfigGUI.node1ind = 0;
ConfigGUI.node2ind = 0;
c = get(ConfigGUI.node_pos,'CData');
color = [1 1 0];        
[q, idx] = ismember(color,c,'rows');
if q
    if (idx == ConfigGUI.ind1)
        c(idx,:) = [0 0 1];
    elseif (idx == ConfigGUI.ind2)
        c(idx,:) = [1 0 0];
    else
        c(idx,:) = [0 0 0];
    end
end
color = [1 0 1];     
[q, idx] = ismember(color,c,'rows');
if q
    if (idx == ConfigGUI.ind1)
        c(idx,:) = [0 0 1];
    elseif (idx == ConfigGUI.ind2)
        c(idx,:) = [1 0 0];
    else
        c(idx,:) = [0 0 0];
    end
end
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
p = findobj('tag','savepath');
p.Enable = 'off';
p = findobj('tag','cancelpath');
p.Enable = 'off';
end
% Cancel the currently selected path creation
function cancelpath(hObject,eventdata)
global ConfigGUI
c = get(ConfigGUI.node_pos,'CData');
color = [1 1 0];        
[q, idx] = ismember(color,c,'rows');
if q
    if (idx == ConfigGUI.ind1)
        c(idx,:) = [0 0 1];
    elseif (idx == ConfigGUI.ind2)
        c(idx,:) = [1 0 0];
    else
        c(idx,:) = [0 0 0];
    end
end
color = [1 0 1];     
[q, idx] = ismember(color,c,'rows');
if q
    if (idx == ConfigGUI.ind1)
        c(idx,:) = [0 0 1];
    elseif(idx == ConfigGUI.ind2)
        c(idx,:) = [1 0 0];
    else
        c(idx,:) = [0 0 0];
    end
end
set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
set(ConfigGUI.node2path, 'String', 'N/A');
set(ConfigGUI.node1path, 'String', 'N/A');
p = findobj('tag','savepath');
p.Enable = 'off';
p = findobj('tag','cancelpath');
p.Enable = 'off';
end
% Selecting path to delete it 
function pathSelect(hObject,eventdata)
global ConfigGUI
ConfigGUI.pathcheck = true;
p = findobj('tag','selectpathdel');
p.Enable = 'off';        
end
% Cancel the current deletion process
function pathCancelDel(hObject,eventdata)
global ConfigGUI
global path_atts
[node1idx,~] = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind1+1,3});
[node2idx,~] = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind1+1,4});
delete(ConfigGUI.path_plot(ConfigGUI.path_ind_visual))
delete(findobj('tag',sprintf('path%i',ConfigGUI.path_ind_visual)))
if ConfigGUI.pathind == ConfigGUI.path_ind_visual
    colour = [0 0 1];
else
    colour = [0 0 0];
end
ConfigGUI.path_plot(ConfigGUI.path_ind_visual)=line([ConfigGUI.Node_pos(node1idx,1),...
    ConfigGUI.Node_pos(node2idx,1)],...
    [ConfigGUI.Node_pos(node1idx,2),...
    ConfigGUI.Node_pos(node2idx,2)],'LineWidth',1.5,'Color',colour,...
    'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',ConfigGUI.path_ind_visual));
legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
ConfigGUI.path_ind_visual = 0;
p = findobj('tag','selectpathdel');
p.Enable = 'on'; 
p = findobj('tag', 'cancelpathdel');
p.Enable = 'off';
p = findobj('tag','delpath');
p.Enable = 'off';       
end
% Deleting the path from the model
function deletePath(hObject,eventdata)
global ConfigGUI
global path_atts
global path_atts_copy
p = findobj('tag','delpath');
p.Enable = 'off';
p = findobj('tag','cancelpathdel');
p.Enable = 'off';
p = findobj('tag','selectpathdel');
p.Enable = 'on';
if ConfigGUI.path_ind_visual == ConfigGUI.pathind
    ConfigGUI.firsttime_path = true;
    set(ConfigGUI.node1curr, 'String','N/A');
    set(ConfigGUI.node2curr, 'String','N/A');
    set(ConfigGUI.getpathatt,'String','N/A');
    set(ConfigGUI.adelay,'String','N/A');
    set(ConfigGUI.rdelay,'String','N/A');
    ConfigGUI.pathind = 0;
    p = findobj('tag','selectpath');
    p.Enable = 'on';
    p = findobj('tag','pathval');
    p.Enable = 'off';
    p = findobj('tag','pathvalreset');
    p.Enable = 'off';
end
delete(ConfigGUI.path_plot(ConfigGUI.path_ind_visual))
delete(findobj('tag',sprintf('path%i',ConfigGUI.path_ind_visual)));
idx = find(ismember(ConfigGUI.path_connections(:,1),ConfigGUI.path_ind_visual,"rows"));
ConfigGUI.path_connections(idx,:) = [];
temp = path_atts;
temp(ConfigGUI.pathind1+1,:) = [];
assignin('base','path_atts',temp);
temp = path_atts_copy;
temp(ConfigGUI.pathind1+1,:) = [];
assignin('base','path_atts_copy',temp);
ConfigGUI.path_ind_visual = 0;
drawnow update;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other functions
function saveGUI(hObject,eventdata)
global ConfigGUI
global path_atts
global node_atts
global nodes_name
global probes_name
%%% Save the model updates
close all
model.node_atts=node_atts;
model.nodes_name=nodes_name;
model.path_atts=path_atts;
model.probes=probes_name;
model.pacemaker=ConfigGUI.model;
PreBuild_unified(model)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeGUI(hObject,eventdata)
% Close the model without saving anything
close all
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
        str = append('Node: ',int2str(node_atts{ind1+1,2}),' = ', nodes_name(ind1+1,1));
        if strcmp('N',nodes_name(ind1+1,2))
            str = [str,'Cell Type: N'];
            back_color = [1 1 .3];
        elseif strcmp('NM',nodes_name(ind1+1,2))
            str = [str,'Cell Type: NM'];
            back_color = [1 .8 .4];
        elseif strcmp('M',nodes_name(ind1+1,2))
            str = [str,'Cell Type: M'];
            back_color = [1 .8 .8];
        end
    else
        str = append('Probe: ',int2str(ind2),' = ', probes_name(ind2+1,1));
        back_color = [.75 .75 .75];
    end
    % Display information for the node
    delete(findobj('tag','mytooltip'))
    text(curX+xoffset,curY+yoffset,str,...
        'backgroundcolor',back_color,'tag','mytooltip','edgecolor',[0 0 0],...
        'hittest','off')

    if ConfigGUI.nodesetcheck %for editing a node
        ConfigGUI.ind1 = ind1;
        %set the node information based on nearest node
        c = get(ConfigGUI.node_pos,'CData');
        color = [0 0 1];        
        [q, idx] = ismember(color,c,'rows');
        % Changing the previously selected node if it exists
        if q %ConfigGUI.ind1 previous
            if idx == ConfigGUI.ind2
                c(idx,:) = [1 0 0];
            elseif idx == ConfigGUI.node1ind
                c(idx,:) = [1 1 0];
            elseif idx == ConfigGUI.node2ind
                c(idx,:) = [1 0 1];
            else
                c(idx,:) = [0 0 0];
            end
        end
        c(ind1,:) = color; 
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        set(ConfigGUI.nodecurr,'String',sprintf('%s (%i)',nodes_name{ind1+1,1}, ind1));
        set(ConfigGUI.nodetypecurr,'String',node_atts(ind1+1,1));
        set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2}));
        ConfigGUI.nodesetcheck = false;
        b = findobj('tag','selectnode');
        b.Enable = 'on';
        b = findobj('tag','reset');
        b.Enable = 'on';
        b = findobj('tag','attrupdate');
        b.Enable = 'on';
        b = findobj('tag','plotnodetrace');
        b.Enable = 'on';        
    elseif ConfigGUI.nodecheck %for deleting a node
        ConfigGUI.ind2 = ind1;
        %set the node information based on nearest node
        c = get(ConfigGUI.node_pos,'CData');
        color = [1 0 0];        
        [q, idx] = ismember(color,c,'rows');
        if q %ConfigGUI.ind2 previous
            if idx == ConfigGUI.ind1
                c(idx,:) = [0 0 1];
            elseif idx == ConfigGUI.node1ind
                c(idx,:) = [1 1 0];
            elseif idx == ConfigGUI.node2ind
                c(idx,:) = [1 0 1];
            else
                c(idx,:) = [0 0 0];
            end
        end
        c(ind1,:) = color;
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        ConfigGUI.nodecheck = false;
        b = findobj('tag','selectnodedel');
        b.Enable = 'on';
        b = findobj('tag','delnode');
        b.Enable = 'on';

        p = findobj('tag', 'cancelnodedel');
        p.Enable = 'on';
    elseif ConfigGUI.selectlocal %for creating a node
        c = get(ConfigGUI.node_pos,'CData');
        x_temp = get(ConfigGUI.node_pos,'XData');
        y_temp = get(ConfigGUI.node_pos,'YData');
        x_temp(end+1) = curX;
        y_temp(end+1) = curY;
        c(end+1,:) = [0 1 0];
        set(ConfigGUI.node_pos,'XData',x_temp,'YData',y_temp,'CData',c);
        ConfigGUI.selectlocal = false;
        b = findobj('tag','savenode');
        b.Enable = 'on';
        b = findobj('tag','cancelnode');
        b.Enable = 'on';
        delete(findobj('tag','mytooltip'))

    elseif ConfigGUI.node1set
        ConfigGUI.node1ind = ind1;
        c = get(ConfigGUI.node_pos,'CData');
        color = [1 1 0];        
        [q, idx] = ismember(color,c,'rows');
        if q %ConfigGUI.node1ind previous
            if idx == ConfigGUI.ind1
                c(idx,:) = [0 0 1];
            elseif idx == ConfigGUI.ind2
                c(idx,:) = [1 0 0];
            elseif idx == ConfigGUI.node2ind
                c(idx,:) = [1 0 1];
            else
                c(idx,:) = [0 0 0];
            end
        end
        c(ind1,:) = color;
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        set(ConfigGUI.node1path, 'String', sprintf('%s (%i)',nodes_name{ind1+1,1},ind1));        
        p = findobj('tag','node1');
        p.Enable = 'on';        
        p = findobj('tag','node2');
        p.Enable = 'on';       
        p = findobj('tag','cancelpath');
        p.Enable = 'on';       
        ConfigGUI.node1set = false;
        if ~strcmp(ConfigGUI.node2path.String,'N/A') & ...
                ~strcmp(ConfigGUI.node1path.String,ConfigGUI.node2path.String) % FUTURE: Might want a self triggering node
            b = findobj('tag','savepath');
            b.Enable = 'on';
        end
    elseif ConfigGUI.node2set
        ConfigGUI.node2ind = ind1;
        c = get(ConfigGUI.node_pos,'CData');
        color = [1 0 1];        
        [q, idx] = ismember(color,c,'rows');
        if q %ConfigGUI.node2ind previous
            if idx == ConfigGUI.ind1
                c(idx,:) = [0 0 1];
            elseif idx == ConfigGUI.ind2
                c(idx,:) = [1 0 0];
            elseif idx == ConfigGUI.node1ind
                c(idx,:) = [1 1 0];
            else
                c(idx,:) = [0 0 0];
            end
        end
        c(ind1,:) = color;
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        set(ConfigGUI.node2path, 'String', sprintf('%s (%i)',nodes_name{ind1+1,1},ind1));
        p = findobj('tag','node1');
        p.Enable = 'on';        
        p = findobj('tag','node2');
        p.Enable = 'on';      
        p = findobj('tag','cancelpath');
        p.Enable = 'on';        
        ConfigGUI.node2set = false;
        if ~strcmp(ConfigGUI.node1path.String,'N/A') & ...
                ~strcmp(ConfigGUI.node1path.String,ConfigGUI.node2path.String)
            b = findobj('tag','savepath');
            b.Enable = 'on';
        end
    end
    if ConfigGUI.pathsetcheck
        %set the path information based on nearest two nodes
        if ~ConfigGUI.firsttime_path
            node1idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind+1,3});
            node2idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind+1,4});
            delete(ConfigGUI.path_plot(ConfigGUI.pathind))
            delete(findobj('tag',sprintf('path%i',ConfigGUI.pathind)))
            if ConfigGUI.pathind == ConfigGUI.path_ind_visual
                colour = [1 0 0];
            else
                colour = [0 0 0];
            end
            ConfigGUI.path_plot(ConfigGUI.pathind)=line([ConfigGUI.Node_pos(node1idx,1),...
                ConfigGUI.Node_pos(node2idx,1)],...
                [ConfigGUI.Node_pos(node1idx,2),ConfigGUI.Node_pos(node2idx,2)],'LineWidth',1.5,'Color',colour,...
                'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',ConfigGUI.pathind));
            
        else
            ConfigGUI.firsttime_path = false;
        end
        ConfigGUI.pathind = nearest_line([curX,curY]);
        if ConfigGUI.pathind == 0
            ConfigGUI.pathsetcheck = false;
            return
        end
        node1idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind+1,3});
        node2idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind+1,4});
        delete(ConfigGUI.path_plot(ConfigGUI.pathind))
        delete(findobj('tag',sprintf('path%i',ConfigGUI.pathind)))
        ConfigGUI.path_plot(ConfigGUI.pathind)=line([ConfigGUI.Node_pos(node1idx,1),...
            ConfigGUI.Node_pos(node2idx,1)],...
            [ConfigGUI.Node_pos(node1idx,2),ConfigGUI.Node_pos(node2idx,2)],'LineWidth',1.5,'Color',[0 0 1],...
            'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',ConfigGUI.pathind));
        legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
        set(ConfigGUI.node1curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,1},path_atts{ConfigGUI.pathind+1,3}));
        set(ConfigGUI.node2curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,2},path_atts{ConfigGUI.pathind+1,4}));
        set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4}));
        set(ConfigGUI.adelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,21}));
        set(ConfigGUI.rdelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,22}));
        ConfigGUI.pathsetcheck = false;
        p = findobj('tag','selectpath');
        p.Enable = 'on';
        p = findobj('tag','pathval');
        p.Enable = 'on';
        p = findobj('tag','pathvalreset');
        p.Enable = 'on';
        delete(findobj('tag','mytooltip'))        
    elseif ConfigGUI.pathcheck % for deleting the path
        ConfigGUI.pathind1 = nearest_line([curX,curY]);
        if ConfigGUI.pathind1 == 0
            ConfigGUI.pathcheck = false;
            return
        end
        pathvis = find(ismember(ConfigGUI.path_connections(:,2:end), ...
            [path_atts{ConfigGUI.pathind1+1,3},path_atts{ConfigGUI.pathind1+1,4}],'row'));
        ConfigGUI.path_ind_visual = ConfigGUI.path_connections(pathvis,1);
        node1idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind1+1,3});
        node2idx = find(ConfigGUI.node_connections.' == path_atts{ConfigGUI.pathind1+1,4});
        delete(ConfigGUI.path_plot(ConfigGUI.path_ind_visual))
        delete(findobj('tag',sprintf('path%i',ConfigGUI.path_ind_visual)))
        ConfigGUI.path_plot(ConfigGUI.path_ind_visual)=line([ConfigGUI.Node_pos(node1idx,1),...
            ConfigGUI.Node_pos(node2idx,1)],...
            [ConfigGUI.Node_pos(node1idx,2),ConfigGUI.Node_pos(node2idx,2)],'LineWidth',1.5,'Color',[1 0 0],...
            'Parent',ConfigGUI.TOP_axe,'tag',sprintf('path%i',ConfigGUI.path_ind_visual));
        legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
        ConfigGUI.pathcheck = false;
        p = findobj('tag','selectpathdel');
        p.Enable = 'off';        
        p = findobj('tag','delpath');
        p.Enable = 'on';
        p = findobj('tag','cancelpathdel');
        p.Enable = 'on';
        delete(findobj('tag','mytooltip'))
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
minimum_val = 1000000;
if isempty(path_atts) %not stress tested
    disp('No more paths left')
    p = findobj('tag','selectpathdel');
    p.Enable = 'off';        
    p = findobj('tag','selectpath');
    p.Enable = 'off';
    index = 0;
    return 
end
for i = 2:size(path_atts,1)
    [node1idx,~] = find(ConfigGUI.node_connections.' == path_atts{i,3});
    [node2idx,~] = find(ConfigGUI.node_connections.' == path_atts{i,4});
    curr_dist = point_to_line(pt,ConfigGUI.Node_pos(node1idx,1:2),ConfigGUI.Node_pos(node2idx,1:2));
    if curr_dist < minimum_val
        minimum_val = curr_dist;
        index = i-1;        
    end
end
end

function val = unique_num(array)
B = sort(array);
for i=1:length(B)
    if i ~= B(i)
        val = i;
        return
    end
end
val = B(end)+1;
end