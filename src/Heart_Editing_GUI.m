function Heart_Editing_GUI(mdl,modelName,filename,savepath,raw_excel,raw_probes,model_params,node_atts,node_atts_copy,path_atts,path_atts_copy,timescale)
% Copyright 2025 Ben Allen.
% This program is released under license GPL version 3.
close all
global nodes_name
nodes_name = raw_excel(:,1:2);
global probes_name
probes_name = raw_probes(:,1);
global node_atts_copy
global path_atts_copy
global node_atts
global path_atts
global model_params
global timescale
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
ConfigGUI.setp=scatter(ConfigGUI.TOP_axe,[],[],'LineWidth',1.5,'Marker','o','CData',[1 0 0]);
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
enabled ={'on','on','on','on'};
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
enabled ={'on','on','on'};
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

strings = {'Node 1 (i):', 'Node 2 (j):', 'Attribute:', 'Attribute Value:', 'A delay (ms):', 'R delay (ms):'};
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
% 2. Select which preset to use as a base
% 3. Save node to the network
%% Tab for creating paths as well as deleting them
ConfigGUI.path_create = uitab(tabs,'Title','Path Creation');
% 1. Receive clickS
% -- i. Start node
% -- ii. End node
% 2. Select which preset to use as a base
% 3. Save the path to the network

strings = {'Select Node 1','Select Node 2','Save'}; 
left_positions = [0.05 0.45 0.5];
bot_positions = [0.8 0.8 0.65];
h_positions = [0.15 0.15 0.1];
w_positions = [0.15 0.15 0.1];
tags = {'node1','node2', 'savepath'};
callbacks = {@node1select,@node2select,@savepath};
enabled ={'on','on','on'};
style={'pushbutton','pushbutton','pushbutton'};
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
strings = {'1', '2', '3', '4', '5'};
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

strings = {'Node 1 (i):', 'Node 2 (j):'};
left_positions = [0.2 0.6];
bot_positions = [0.85 0.85];
h_positions = [0.1 0.1];
w_positions = [0.1 0.1];
for idx = 1:length(strings)
    uicontrol('Parent',ConfigGUI.path_create,...
        'Style','text',...
        'Units','normalized',...
        'Position',[left_positions(idx) bot_positions(idx) w_positions(idx) h_positions(idx)],...
        'BackgroundColor',get(ConfigGUI.Handle,'Color'),...
        'String',strings{idx},...
        'HandleVisibility','callback');
end
%Load the default model
load_model(filename);
% Store ConfigGUI to Userdata and communicate with the Simulink model
%set_param(sprintf('%s/S-Function',ConfigGUI.modelName),'UserData',ConfigGUI);
%%% SET THE node/path details?????
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
set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2}));
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting the currently selected nodes AP
function localPlotNodeAP(hObject,eventdata)
global ConfigGUI
global node_atts
global params
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
% Add option to hold on to the trace - how many???
delete(findobj('tag','myTrace'))
line(ConfigGUI.AP_nodetrace,time,trace,'color',[1 0 0],'LineWidth',2,'tag','myTrace')
drawnow update;

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
set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4}));
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

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for creating a node


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
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other functions

function saveGUI(hObject,eventdata)
global ConfigGUI
global path_atts
global node_atts
%%% Save the model updates and empty any arrays
% Save the path_atts and node_atts to files (nonspecific naming, to then
% use in the full model)
close all
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeGUI(hObject,eventdata)
global ConfigGUI
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
        str = append('Node: ',int2str(ind1),' = ', nodes_name(ind1+1,1));
        if strcmp('N',nodes_name(ind1+1,2))
            str = [str,'Cell Type: N','-> Pacemaker'];
            back_color = [1 1 .3];
        elseif strcmp('NM',nodes_name(ind1+1,2))
            str = [str,'Cell Type: NM','-> Subsidiary Pacemaker'];
            back_color = [1 .8 .4];
        elseif strcmp('M',nodes_name(ind1+1,2))
            str = [str,'Cell Type: M','-> Myocyte'];
            back_color = [1 .8 .8];
        end
    else
        str = append('Probe: ',int2str(ind2),' = ', probes_name(ind2+1));
        back_color = [.75 .75 .75];
    end

    if ConfigGUI.nodesetcheck
        c=zeros(size(ConfigGUI.Node_pos,1),3);
        ConfigGUI.ind1 = ind1;
        %set the node information based on nearest node
        c(ConfigGUI.ind1,:) = [1 0 0];
        set(ConfigGUI.node_pos,'XData',ConfigGUI.Node_pos(:,1),'YData',ConfigGUI.Node_pos(:,2),'CData',c);
        set(ConfigGUI.nodecurr,'String',sprintf('%s (%i)',nodes_name{ind1+1,1}, ind1));
        set(ConfigGUI.nodetypecurr,'String',node_atts(ind1+1,1));
        set(ConfigGUI.getnodeatt,'String',sprintf('%f',node_atts{ConfigGUI.ind1+1,ConfigGUI.nodeatt.Value+2}));
        ConfigGUI.nodesetcheck = false;
        b = findobj('tag','selectnode');
        b.Enable = 'on';
    end
    if ConfigGUI.pathsetcheck
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
        legend([ConfigGUI.node_pos,ConfigGUI.probe_pos],{'Node','Probe'});
        set(ConfigGUI.node1curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,1},path_atts{ConfigGUI.pathind+1,3}));
        set(ConfigGUI.node2curr, 'String', sprintf('%s (%i)',path_atts{ConfigGUI.pathind+1,2},path_atts{ConfigGUI.pathind+1,4}));
        set(ConfigGUI.getpathatt,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,ConfigGUI.pathatt.Value+4}));
        set(ConfigGUI.adelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,21}));
        set(ConfigGUI.rdelay,'String',sprintf('%f',path_atts{ConfigGUI.pathind+1,22}));
        ConfigGUI.pathsetcheck = false;
        p = findobj('tag','selectpath');
        p.Enable = 'on';
    end
    if ConfigGUI.node1set
        set(ConfigGUI.node1path, 'String', sprintf('%s (%i)',nodes_name{ind1+1,1},ind1));        
        p = findobj('tag','node1');
        p.Enable = 'on';        
        p = findobj('tag','node2');
        p.Enable = 'on';       
        ConfigGUI.node1set = false;
    elseif ConfigGUI.node2set
        set(ConfigGUI.node2path, 'String', sprintf('%s (%i)',nodes_name{ind1+1,1},ind1));
        p = findobj('tag','node1');
        p.Enable = 'on';        
        p = findobj('tag','node2');
        p.Enable = 'on';       
        ConfigGUI.node2set = false;
    end
    % Display information for the node
    delete(findobj('tag','mytooltip'))
    text(curX+xoffset,curY+yoffset,str,...
        'backgroundcolor',back_color,'tag','mytooltip','edgecolor',[0 0 0],...
        'hittest','off')
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