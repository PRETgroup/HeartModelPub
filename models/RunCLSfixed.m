% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
clear all;
path_var=pwd;
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
load(updatePara);
global timescale
%Prepare the parameters
if outputs.units == 2 
    filename='N3Cfg_second.mat'; 
    datafile='N3Data_second.mat'; % Doesnt solve properly
    pathsheet='Path_second';
    nodesheet='Node_second'; 
    assignin('base','solvertime',5);
    assignin('base','stepsize',0.0005);
    assignin('base','timescale','s');
    assignin('base','divider',1); % to be used with the N node ms/s setting in RR
elseif outputs.units == 1
    filename='N3Cfg.mat'; 
    datafile='N3Data.mat'; 
    pathsheet='Path'; 
    nodesheet='Node'; 
    assignin('base','solvertime',5000);
    assignin('base','stepsize',0.1);
    assignin('base','timescale','ms');
    assignin('base','divider',1000);
end
% contains all configurations of heart model
load(filename);
% contains all parameters of heart model
load(datafile);
% Specify the model name
modelName='CLSfixed';
if ~contains('models',path_var)
    path_var = [path_var, filesep 'models'];
end
% Specify the model path
mdl=[path_var,filesep, modelName];
% Specify the data save path
savepath=[path_var,filesep 'Cells.mat'];
% Extract the node classification data from the xlsx file
[~,~,nodes_raw]=xlsread('Heart_N3_second.xlsx',nodesheet);
[~,~,path_raw]=xlsread('Heart_N3_second.xlsx',pathsheet);
[~,~,probes_raw]=xlsread('Heart_N3_second.xlsx','Probe');

% Edit the network model
if outputs.editmodel
    global node_atts
    global path_atts
    global node_atts_copy
    global params
    global path_atts_copy
    global nodes_name
    global probes_name
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
    temp2 = probes_raw(:,1);
    assignin('base','probes_name',temp2);
    Heart_Editing_GUI(mdl,modelName,filename,savepath,nodes_name,probes_name,params,node_atts,node_atts_copy,path_atts,path_atts_copy,timescale);
end

% TO ADD: Somehow update the model ONLY IF the save and quit function was used in
% the Heart_Editing_GUI

% In the model, there should be a S-function to save data to the same structure of the GUI.
%Heart_GUI(mdl,modelName,filename,savepath,nodes_raw,probes_raw,timescale); 