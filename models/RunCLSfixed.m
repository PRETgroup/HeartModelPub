% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
clear;
%Prepare the parameters
% contains all configurations of heart model
filename='N3Cfg.mat'; 
% contains all parameters of heart model
datafile='N3Data.mat'; 
load(filename);
load(datafile);
path_var=pwd;
% Contains all the range of new parameters for run-time update
updatePara='parasMulti.mat';
load(updatePara);
%% Parameter settings
% parasMulti:
% Bradycardia+AV block+premature ventricular complex (PVC), RBBB (slow velocity):
% % SA BCL=1400; the automaticity of Node 24 (RBB) enabled (para48=0); path 10 backward enabled (para7=1.0); Path 15 cv=0.04, path 27 cv=0.4; 
% parasMulti2: PVC introduces PMT
% Bradycardia+AV block+premature ventricular complex (PVC), RBBB (complete blockage, i.e.,cv=0):
% % SA BCL=1400; the automaticity of Node 24 (RBB) enabled (para48=0); path 10 backward enabled (para7=1.0); Path 15 cv=0.04, path 27 cv=0;
% parasMulti3: extra VP introduces AVNRT
% % SA BCL=814; CS BCL=1194 enabled (para48=0); path 10 backward enabled (para7=0.8); ppR5
% cfg=[814,1194,2,0,0.100000000000000,0.250000000000000,278,0.0146200000000000,0.00872000000000000,2300,2,1,0.100000000000000,0.250000000000000,1.100000000000000,0.0700000000000000,0.0700000000000000,0.0700000000000000,0.0700000000000000];
%%parasNormal Normal but slight AV delay compared to device AVI.
%% Run the GUI
% Specify the model name
modelName='CLSfixed';
% Specify the model path
mdl=[path_var,filesep, modelName];
% Specify the data save path
savepath=[path_var,filesep 'Cells.mat'];
% In the model, there should be a S-function to save data to the same structure of the GUI.
Heart_GUI(mdl,modelName,filename,savepath); 