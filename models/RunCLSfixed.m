% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
clear all;
bdclose('all');
path_var=pwd;
if ~contains('models',path_var)
    path_var = [path_var, filesep 'models'];
end
warning('off','all')
% Opening Main GUI which determines whether to edit model network
% structure, parameters, and add pacemaker
global outputs 
outputs = main_settings();
Heart_GUI_preset(outputs);
switch outputs.param
    case 'Normal'        %1
        updatePara='parasNormal.mat';
    case 'parasMulti' %2
        updatePara='parasMulti.mat';
    case 'parasMulti2' %3
        updatePara='parasMulti2.mat';
    case 'parasMulti3' %4
        updatePara='parasMulti3.mat';
    otherwise 
        updatePara='parasNormal.mat';
end
%Prepare the parameters
if outputs.units == 2 
    filename='N3Cfg_second.mat'; 
    datafile='N3Data_second.mat';
    pathsheet='Path_second';
    nodesheet='Node_second'; 
    assignin('base','solvertime',5); % solving time for the GUI cells 
    assignin('base','stepsize',0.0005); % step size for solving the GUI cells 
    assignin('base','period',0.001); % clk in CLSfixed Period(secs) 
    assignin('base','timescale','sec'); % time scale for GUI plots and Sensing/Chart[3]
    assignin('base','buffer',0.599); % for Libs_unified/Path_V3/Path Buffer_i and Buffer_j
    assignin('base','unit_conversion',1); % to be used with the N node ms/s setting in RR
elseif outputs.units == 1
    filename='N3Cfg.mat'; 
    datafile='N3Data.mat'; 
    pathsheet='Path'; 
    nodesheet='Node'; 
    assignin('base','solvertime',5000);
    assignin('base','stepsize',0.1);
    assignin('base','period',1);
    assignin('base','timescale','msec');
    assignin('base','buffer',599);
    assignin('base','unit_conversion',1000);
end
% Extract the node classification data from the xlsx file
[~,~,nodes_raw]=xlsread('Heart_N3_second.xlsx',nodesheet);
[~,~,path_raw]=xlsread('Heart_N3_second.xlsx',pathsheet);
[~,~,probes_raw]=xlsread('Heart_N3_second.xlsx','Probe');
% Edit the network model
if outputs.editmodel
    global node_atts
    global node_atts_copy
    global path_atts
    global path_atts_copy
    global params
    global nodes_name 
    global probes_name %is just the entire probes information set
    temp = nodes_raw(:,2:end);
    temp(:,end-2) = [];
    temp(end,:) = [];
    assignin('base','node_atts',temp);
    assignin('base','node_atts_copy',temp);
    assignin('base','path_atts',path_raw);
    assignin('base','path_atts_copy',path_raw);

    temp1 = nodes_raw(:,1:2);
    temp1(end,:) = [];
    assignin('base','nodes_name',temp1);
    temp2 = probes_raw(2:end,1:5);
    assignin('base','probes_name',temp2);
    Heart_Editing_GUI(filename,nodes_name,probes_name,params,node_atts,node_atts_copy,path_atts,path_atts_copy,timescale);
end

% TO DEBUG: _pace and _nopace functionality: test with other parameter sets
% 05/08/25: tested successfully 
% TO ADD: switching CLSfixed to Libs_unified base


% contains all configurations of heart model
load(filename);
% contains all parameters of heart model
load(datafile);
% Load in the new parameter range
load(updatePara);
% Specify the model name
models={'CLSfixed', 'CLSfixed_pace', 'CLSfixed_nopace'};
modelName = models{outputs.pacemaker};
% Specify the model path
mdl=[path_var,filesep, modelName];
% Specify the data save path
savepath=[path_var,filesep 'Cells.mat'];

% In the model, there should be a S-function to save data to the same structure of the GUI.
Heart_GUI(mdl,modelName,filename,savepath,nodes_raw,probes_raw,timescale); 