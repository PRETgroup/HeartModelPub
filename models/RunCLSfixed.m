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
%% Run the GUI
% Specify the model name
modelName='CLSfixed';
% Specify the model path
mdl=[path_var,filesep, modelName];
% Specify the data save path
savepath=[path_var,filesep 'Cells.mat'];
% In the model, there should be a S-function to save data to the same structure of the GUI.
Heart_GUI(mdl,modelName,filename,savepath); 