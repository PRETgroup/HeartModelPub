% Copyright 2019 Weiwei Ai.
% This program is released under license GPL version 3.
%%
%%Read excel data; If 'N3Cfg.mat' and 'N3Data.mat' already exist, this part
%%can be skipped.
filexls='Heart_N3_second'; % The excel file name
% Specify the range of reading
Noderange='A2:AW44';
Node_P_range='D1:AW1'; % the parameter names
Pathrange='A2:O55';
Path_P_range='E1:O1'; % the parameter names
Proberange='A2:E9';
% contains all configurations of heart model, which will be used to build a new heart model
filename='N3Cfg_second.mat'; 
% contains all parameters of heart model, which will be used for simulation
datafile='N3Data_second.mat'; 
[Node,Node_name,Node_pos,Path,Path_name,Probe,Probe_name,Probe_pos,cfgports]=PreCfgfcn_second(filexls,Noderange,Node_P_range,Pathrange, Path_P_range, Proberange,filename,datafile);

%% Choose Nodes/Path library and build a heart model,which will be saved to the systempath.
rootPath='C:\Users\wai484\OneDrive - The University of Auckland\Documents\HeartModelPub';% change it according to your directory structure
path_var=[rootPath,filesep 'models']; % the path where the model will be saved
library = [rootPath,filesep 'Lib' filesep 'Libs_second'];% the components library path
node_n = 'Libs_second/Node_N_V6'; % The N type cell model library
node_m = 'Libs_second/Node_M_V4'; % The M type cell model library
node_nm = 'Libs_second/Node_NM_V4'; % The NM type cell model library
path = 'Libs_second/Path_V3'; % The path model library
probe='Libs_second/Electrode'; % The EGM generation model library
HeartModel='HeartV10'; % The name of the heart model
Buildmodel_fcn(HeartModel,filename,node_n,node_m,node_nm,path,probe,path_var,library);
