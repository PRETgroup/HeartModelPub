1.The parameter files: 
Heart_N3.xlsx, the parameters have been adjusted to fit TT Endo and Courtemanche model

2.Model Libs:

-Node_N_V6.slx: pacemaker cell model, nodal type,based on Node_N_V3.slx, update parameters at the beginning of the slow depolarization, compute t3 and t0 before updating, and compute d2 and d1 after updating;

-Node_M_V3.slx, ardiac myocyte model with interface to path model, only update parameters before start new cycle (before enter q1);

-Path_V3.slx, path model;

-Node_NM_V6.slx, subsidiary pacemaker cell model

-Electrode.slx, Compute the potential sensed by leads due to moving activation on a path

-Sensing.slx, Combine and control all egm contents

-Pre_eventsv1.slx, preprocess input signals

-Ratesv1.slx, compute rates

-Cnds_DDDv1.slx, monitor execution traces and check if the traces meet the specifications

-PMTv1.slx, monitor the occurrence of PMT

-PM_DDD_v1.slx, DDD mode pacemaker with errors

-PM_DDD_v3.slx, DDD mode pacemaker without errors


3.Scripts:

-PreBuild.m, a demo showing automatically building a heart model. Please be aware that the version of excel files, libraries, and some parameters may need to modify. 

-PreCfgfcn.m, Read parameters from the excel file given filenames and data range to;
•	Generate configuration data for heart model building;
•	Create lookup table for parameters update
•	Cfgports: input configuration of the demux connecting with the parameter input port
•	Cfgdata: All the parameters

-Buildmodel_fcn.m, automatically build a heart model provided that the parameters and the connection relations of cells and paths are available (node names, types and path names); Need to specify the library for the components

-Heart_GUI.m, generate a UI and link to the model

-SaveTrace_sfcn.m, update UI and save simulation traces

-heatmapdata.m, export activation sequences to generate a heat map

-subtightplot.m, make the subplots close to each other, got it on-line.

-plotTrace.m, plot traces

-ActMap.m, compute the activation time of critical paths.

-genpp.m, generate new parameters

4.Usage of models and scripts
	4.0	Add all the library files to the search path for the current MATLAB® session.
		
	4.1	Build a new heart model
		Refer to PreBuild.m. 

	4.2	Run a model with the virtual heart
		(1).	Note: the model should be able to initialize all parameters of the heart model at t=0! 
			
		(2).	Load all the data into the workspace of Matlab for simulation
			E.g.,
			%Prepare the parameters
			% contains all configurations of heart model, which will be used to build a new heart model
			filename='N3Cfg.mat'; 
			% contains all parameters of heart model, which will be used for simulation
			datafile='N3Data.mat'; 
			load(filename);
			load(datafile);

		(3).	Run the model
			1)	With GUI
			----------for GUI operation-------
			% Specify the model name
			modelName='CLS';
			% Specify the model path
			mdl=[path_var,filesep,modelName];
			% Specify the data save path
			savepath=[path_var,filesep 'Cells.mat'];
			% In the model, there should be a S-function to save data to the same structure of the GUI.
			Heart_GUI(mdl,modelName,filename,savepath); % In the model, there should be a S-function to save data to the same structure of the GUI.
			% Via the GUI
			Specify the simulation time and Press Start in the Operations panel of the GUI
			-----------end-------------

			2)	Without GUI
			Run the model 

	4.3	Update parameters during simulation
		(1).	Creat variables: 
			a.	ppNode=[NodeNumber, ParaNumber, ParaValue, ParaMin, ParaMax]; 
			b.	ppPath=[ PathNumber, ParaNumber, ParaValue, ParaMin, ParaMax];

		(2).	Run genpp.m to generate:
			a.	pNode=Port number for node parameters; 
			b.	pPath= Port number for path parameters; 
			c.	pp=all parameters (nodes and paths); 
			d.	pRange=all parameter ranges;

		(3).	During the model initialization, call the function:

			function [Hcfg,Node_lookup,Path_lookup]  = LoadInit
			%#codegen
			coder.extrinsic('evalin');
			Hcfg1=zeros(1,2191); % The total number of cfg ports
			Hcfg1=evalin('base', 'cfgdata');
			Hcfg=Hcfg1'; % All the parameter inputs
			end

		(4).	During simulation, update the parameters:

			%% Get the index of the parameter
			function pUpdate(Nodein,Pathin, Parasin)
			%#codegen
			coder.extrinsic('evalin');
			Nodein =zeros(1,4); % The total number of cell cfg ports
			Nodein =evalin('base', 'pNode');
			Pathin =zeros(1,6); % The total number of path cfg ports
			Pathin =evalin('base', 'pPath');
			for n=1:length(Nodein)
    			Heart(Nodein(n))=Parasin(n);
			end 
			for n=1:length(Pathin)
    				Heart(Pathin(n))=Parasin(n+length(Nodein));
			end 
			end





