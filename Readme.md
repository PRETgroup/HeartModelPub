# HeartModelPub

This project includes pacemaker cell models [1], cardiomyocytes [2,3], the cardiac conduction system [3] and EGM generation [4], which are implemented in Matlab/Simulink. We have demonstrated the in-silico validation of a DDD mode pacemaker with the virtual physiological heart model in the closed-loop [5]. For C code generation and implementation using Piha, please refer to [6][7].

The complete original models were presented in the following papers:

    [1] Ai, Weiwei, et al. "A parametric computational model of the action potential of pacemaker cells." IEEE Transactions on Biomedical Engineering 65.1 (2017): 123-130.
    
    [2] Yip, Eugene, et al. "Towards the emulation of the cardiac conduction system for pacemaker validation." ACM Transactions on Cyber-Physical Systems 2.4 (2018): 32.
    
    [3] Ai, Weiwei, et al. "Cardiac electrical modeling for closed-loop validation of implantable devices." IEEE Transactions on Biomedical Engineering 67.2 (2019): 536-544.
    
    [4] Ai, Weiwei, et al. "An intracardiac electrogram model to bridge virtual hearts and implantable cardiac devices." 2017 39th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC). IEEE, 2017.
    
    [5] Ai, Weiwei, et al. "Closing the loop: Validation of implantable cardiac devices with computational heart models." IEEE journal of biomedical and health informatics 24.6 (2019): 1579-1588.
    
    [6] Allen, Nathan, et al. "Modular code generation for emulating the electrical conduction system of the human heart." Proceedings of the 2016 Conference on Design, Automation & Test in Europe. EDA Consortium, 2016.
    
    [7] Malik, Avinash, et al. "Modular compilation of hybrid systems for emulation and large scale simulation." ACM Transactions on Embedded Computing Systems (TECS) 16.5s (2017): 118.


When using these models, please cite the original publications.

This repository provides running examples showing: 
  1. Cardiac cell model simulation: SAcell.slx, CNcell.slx, HPScell.slx, AV.slx;
  2. Cardiac conduction system (heart model) simulation: HeartExe.slx; and
  3. The closed-loop device testing using the heart model: CLSfixed.slx.

## Getting Started

 * To set up, add all the library files to the search path for the current MATLAB® session by running the following in the Matlab command window:\
   \>\> setup_Heart

 * Run model simulations:
	
     All the running examples are under the directory <models>, firstly go to the directory by clicking the folder or running the following in the Matlab command window:\
   \>\> cd models
	
	  * __Automaticity simulation of pacemaker cell models__	  
		 In the folder, there are three pacemaker cell models:\
                   1) SA node model: "SAcell.slx"\
                   2) AV node model: "CNcell.slx"\
                   3) His-Purkinje fibre cell: "HPScell.slx". \
		 Pacemaker cells can initiate action potentials without external stimulation. 
                 To simulate the models:
		 
		 1) Open a cell model, such as "SAcell.slx" , and run the simulation using the Matlab commands:\
	             \>\> open('SAcell.slx')\
	             \>\> sim('SAcell.slx')\
		 Alternatively, you can interactively open the models and click "Run" button in Simulink.
		 
		 2) Once the simulation finishes, click the scope to view the output trace.
	
	  * __Overdrive suppression simulation: apply external stimuli to a pacemaker cell and observe the overdrive suppression phenomenon__  
		 The model "AV.slx" is connected with a pulse, and the script "simAV_Trace.m" is provided to simulate the model.
		 
		 1) Run the following in the Matlab command window:\
	             \>\> simAV_Trace
		 
		 2) Once the simulation finishes, "Plottrace.m" can be used to plot the simulation traces:\
	             \>\> Plottrace
	
	  * __Run a heart model without external pacing pulses__
	  
		 1) Open HeartExe.slx and click "Run" in Simulink, or run the following in the Matlab command window:\
	             \>\> open('HeartExe.slx')\
	             \>\> sim('HeartExe.slx')
		
		 2) Once the simulation finishes, the specified action potentials can be printed out by running the following in the Matlab command window:\
	             \>\> load('Cells.mat')\
	             \>\> plotCells
		
	  * __Run a heart model with a pacemaker device__
	
		 1) Run the following in the Matlab command window:\
	             \>\> RunCLSfixed
		 
		 2) In the GUI, enter the simulation time (ms) in the box under "Stop" within Operations panel on the left.
		 
		 3) Click "Start" within Operations panel.\
		 The electrical activations of the cardiac conduction system is shown on the left (red triangles denote depolarization and blue ones indicate repolarization) and the EGMs are displayed on the right.
		 
		 4) Click "Stop" within Operations panel and close the GUI window.
		 
      * __Build a new heart model__
         - Refer to PreBuild.m. 

## Model description
 
* __The parameter files__:
  - Heart_N3.xlsx, the parameters of the heart model
  - Heart_N3_second.xlsx, parameters of the heart model V2?

* __Model Libs__:
  - Node_N_V6.slx: pacemaker cell model, nodal type, update parameters at the beginning of the slow depolarization, compute t3 and t0 before updating, and compute d2 and d1 after updating;	
  - Node_M_V4.slx, cardiac myocyte model with interface to path model, only update parameters before start new cycle (before enter q1);	
  - Path_V3.slx, path model;	
  - Node_NM_V4.slx, subsidiary pacemaker cell model;	
  - Electrode.slx, Compute the potential sensed by leads due to moving activation on a path;	
  - Sensing.slx, Combine and control all EGM contents;
  - Pre_eventsv1.slx, preprocess input signals;	
  - Ratesv1.slx, compute rates;	
  - Cnds_DDDv1.slx, monitor execution traces and check if the traces meet the specifications;	
  - PMTv1.slx, monitor the occurrence of PMT;
  - PM_DDD_v3.slx, DDD mode pacemaker;	
  - HeartV9.slx, heart model.

* __Scripts__:
   - PreBuild.m, a demo showing automatically building a heart model.
   	  
   - PreCfgfcn.m, Read parameters from the excel file given filenames and data range to;
     - Generate configuration data for heart model building;
     - Create a lookup table for parameters update;
     - Cfgports: input configuration of the demux connecting with the parameter input port;
     - Cfgdata: All the parameters;   	 	
   - Buildmodel_fcn.m, automatically build a heart model provided that the parameters and the connection relations of cells and paths are available (node names, types and path names);
     - Need to specify the library for the components.	 
   - Heart_GUI.m, generate a UI and link to the model.	 
   - SaveTrace_sfcn.m, update UI and save simulation traces.	 
   - subtightplot.m, make the subplots close to each other, got it on-line.	 
   - genpp.m, generate new parameters.
      
## Acknowledgment
 1. The cardiomyocytes model [2] is based on the work [8] and the initial Simulink implementaion is from the Oxford group [9].
 2. The initial topology of the cardiac conduction system [3] is from the work [10].
 3. The DDD pacemaker is modified based on a published model [11].

    [8] Ye, Pei, et al. "Modelling excitable cells using cycle-linear hybrid automata." IET systems biology 2.1 (2008): 24-32.
    
    [9] Chen, Taolue, et al. "Quantitative verification of implantable cardiac pacemakers over hybrid heart models." Information and Computation 236 (2014): 87-101.
    
    [10] Jiang, Zhihao, Miroslav Pajic, and Rahul Mangharam. "Cyber–physical modeling of implantable cardiac medical devices." Proceedings of the IEEE 100.1 (2011): 122-137.
    
    [11] Pajic, Miroslav, et al. "From verification to implementation: A model translation tool and a pacemaker case study." 2012 IEEE 18th Real Time and Embedded Technology and Applications Symposium. IEEE, 2012.

## Need-to-know
* In the path model, only the voltage during q3 contribute to the activation of its neighbouring cells, which is an approximation.
* If the action potential of a cardiomyocyte is greater than the VO during q3 location at given parameters, e.g., out of the physiological range, the output would be saturated to VO. A better saturation approach can be found in the references [5,6], which only saturates the overshoot at the end of q2.
* The models are implemented to facilitate parameterization. The parameters can be updated at run time. For fixed parameters application, the implementation can be simplified. Please refer to the papers [1-4] for the model descriptions.
* The GUI is not fully tested.

## History

October 9, 2019
* Version 1 is posted on the public GitHub repository

Copyright 2019 Weiwei Ai, wai484@aucklanduni.ac.nz, The University of Auckland.	

## LICENSE 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
