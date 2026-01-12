function updateGUIplots(t,u)
% Code in MathWorks plotting subsystem
% coder.extrinsic('evalin');
% appObj = evalin('base','objHeartApp');
% funObj = 'updateGraphs';
% % Write new values
% feval(funObj,appObj,t,u);

% Link to GUI
global ConfigGUI
c = gcbh
q=get_param(c,"Name")
%Config=get_param(gcbh,'UserData')
Config=evalin('base','get_param(gcbh,"UserData")')
Config=ConfigGUI
temp=[t;u];
Config.cells=horzcat(Config.cells,temp);
% Update node status
% Update the color of nodes according to the value of v;
ed=(Config.NumNodes-1)*Config.EachNode;
%Config.node_pos=scatter(Config.TOP_axe,u(4:EachNode:ed+4),u(5:EachNode:ed+5),70,u(2:EachNode:ed+2),'filled','LineWidth',2,'Marker','o');
c=u(2:Config.EachNode:ed+2);
set(Config.node_pos,'XData',Config.Node_pos(:,1),'YData',Config.Node_pos(:,2),'CData',c);
% Update wavefront
st=Config.NumNodes*Config.EachNode;
ed=(Config.NumPaths-1)*Config.EachPath+Config.NumNodes*Config.EachNode;
xd1=u(st+1:Config.EachPath:ed+1);
yd1=u(st+2:Config.EachPath:ed+2);
xd2=u(st+3:Config.EachPath:ed+3);
yd2=u(st+4:Config.EachPath:ed+4);
xr1=u(st+5:Config.EachPath:ed+5);
yr1=u(st+6:Config.EachPath:ed+6);
xr2=u(st+7:Config.EachPath:ed+7);
yr2=u(st+8:Config.EachPath:ed+8);
set(Config.wave_posdi,'XData',xd1,'YData',yd1);
set(Config.wave_posdj,'XData',xd2,'YData',yd2);
set(Config.wave_posri,'XData',xr1,'YData',yr1);
set(Config.wave_posrj,'XData',xr2,'YData',yr2);
drawnow limitrate;
% Update egms
st=Config.NumPaths*Config.EachPath+Config.NumNodes*Config.EachNode;
% Get the handle to the line that currently needs updating
LineHandles={Config.aegm,Config.vegm};
LineAxes={Config.AEGM,Config.VEGM};
stoptime = evalin('base','stoptime');
sTime = t;
for i=1:2
    thisLineHandle = LineHandles{i};
    % Get the simulation time and the block data
    data = u(st+i);
    newXLim = [max(0,sTime-stoptime) max(stoptime,sTime)];
    set(LineAxes{i},'Xlim',newXLim);
    addpoints(thisLineHandle,t,data);
    drawnow update;
end
% Update events
st=st+2;
% Get the handle to the line that currently needs updating
LineHandles={Config.aget,Config.vget,Config.ap,Config.vp,Config.as,Config.vs,Config.ar,Config.vr};
LineAxes={Config.GET,Config.P,Config.S,Config.R};
for i=1:4
    thisLineHandle = LineHandles{i*2-1};
    % Get the simulation time and the block data
    data1 = u(st+i*2-1);
    data2=-u(st+i*2);
    newXLim = [max(0,sTime-stoptime) max(stoptime,sTime)];
    set(LineAxes{i},'Xlim',newXLim);
    addpoints(thisLineHandle,t,data1);
    thisLineHandle = LineHandles{i*2};
    addpoints(thisLineHandle,t,data2);
    drawnow update;
end
set_param(gcbh,'UserData',Config);
end