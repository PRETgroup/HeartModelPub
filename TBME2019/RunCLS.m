% It sets the required paths in the environment. 
cd ..;
path_var=pwd;
addpath(path_var);
%Prepare the parameters
% contains all configurations of heart model, which will be used to build a new heart model
filename='N3Cfg.mat'; 
% contains all parameters of heart model, which will be used for simulation
datafile='N3Data.mat'; 
load(filename);
load(datafile);
% Add the libraries to the search path
cd('Lib');
path_var=pwd;
addpath(path_var);
%
cd ..;
cd('TBME2019');
path_var=pwd;
% Contains all the range of new parameters for run-time update
updatePara='parasAVNRT.mat';
load(updatePara);
%% Run the GUI
% Specify the model name
modelName='CLS';
% Specify the model path
mdl=[path_var,filesep,modelName];
% Specify the data save path
savepath=[path_var,filesep 'Cells.mat'];
% In the model, there should be a S-function to save data to the same structure of the GUI.
Heart_GUI(mdl,modelName,filename,savepath); 