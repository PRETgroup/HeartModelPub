% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
clear all;
%Prepare the parameters
% contains all configurations of heart model
filename='N3Cfg.mat'; % _second.mat';
% contains all parameters of heart model
datafile='N3Data.mat'; % _second.mat'; 
load(filename);
load(datafile);
path_var=pwd;
% Opening Main GUI which determines whether to edit model network
% structure, parameters, and add pacemaker
global outputs 
outputs = main_settings();
Heart_GUI_preset(outputs);
switch outputs.param
    case 'Normal'        
        updatePara='parasNormal.mat';
    case 'parasMulti' 
        updatePara='parasMulti.mat';
    case 'parasMulti2'
        updatePara='parasMulti2.mat';
    case 'parasMulti3'
        updatePara='parasMulti3.mat';
    otherwise 
        updatePara='parasNormal.mat';
end
load(updatePara);
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
[~,~,nodes_raw]=xlsread('Heart_N3_second.xlsx','Node_second');
[~,~,path_raw]=xlsread('Heart_N3_second.xlsx','Path_second');
[~,~,probes_raw]=xlsread('Heart_N3_second.xlsx','Probe');

% Edit the network model
if outputs.editmodel
    global node_atts
    global path_atts
    global node_atts_copy
    global params
    global path_atts_copy
    temp = nodes_raw(:,2:end);
    temp(:,end-2) = [];
    assignin('base','node_atts',temp);
    assignin('base','node_atts_copy',temp);
    assignin('base','path_atts',path_raw);
    assignin('base','path_atts_copy',path_raw);
    %du = 90;
    %pacing = 1500;
    %cn0 = 5;
    %cn1 = 5;
    Heart_Editing_GUI(mdl,modelName,filename,savepath,nodes_raw,probes_raw,params,node_atts,node_atts_copy,path_atts,path_atts_copy);
end
% In the model, there should be a S-function to save data to the same structure of the GUI.
Heart_GUI(mdl,modelName,filename,savepath,nodes_raw,probes_raw); 