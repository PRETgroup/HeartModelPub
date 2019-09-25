# HeartModelPub

This project includes pacemaker cell models [1], cardiomyocytes [2], the cardiac conduction system [3] and EGM generation [4], which are implemented in Matlab/Simulink. For C code generation and implementation, please refer to [5][6].
The complete original models were presented in the following papers:
	[1] Ai, Weiwei, et al. "A parametric computational model of the action potential of pacemaker cells." IEEE Transactions on Biomedical Engineering 65.1 (2017): 123-130.
	[2] Yip, Eugene, et al. "Towards the emulation of the cardiac conduction system for pacemaker validation." ACM Transactions on Cyber-Physical Systems 2.4 (2018): 32.
	[3] Ai, Weiwei, et al. "Cardiac Electrical Modeling for Closed-loop Validation of Implantable Devices." IEEE Transactions on Biomedical Engineering (2019).
	[4] Ai, Weiwei, et al. "An intracardiac electrogram model to bridge virtual hearts and implantable cardiac devices." 2017 39th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC). IEEE, 2017.
	[5] Allen, Nathan, et al. "Modular code generation for emulating the electrical conduction system of the human heart." Proceedings of the 2016 Conference on Design, Automation & Test in Europe. EDA Consortium, 2016.
	[6] Malik, Avinash, et al. "Modular compilation of hybrid systems for emulation and large scale simulation." ACM Transactions on Embedded Computing Systems (TECS) 16.5s (2017): 118.

## Getting Started

To set up, add all the library files to the search path for the current MATLAB® session by running the following in the Matlab command window:
>> setup_Heart

Running examples:
1. Pacemaker cell model
	Go to the directory <models>, open SAcell.slx (or CNcell.slx, HPScell.slx) and click "Run" in Simulink. 
	Once the simulation finishes, click the scope to view the output trace.

2. Apply external stimuli to a pacemaker cell and observe the overdrive suppression phenomenon. 
	Go to the directory <models>, and run the following in the Matlab command window:
	>> simAV_Trace
	>> Plottrace

3. Run a heart model without external pacing pulses
	Go to the directory <models>, open HeartExe.slx and click "Run" in Simulink. 
	Go to the directory <models>, and run the following in the Matlab command window:
	>> load('Cells.mat')
	>> plotCells
	Then the specified action potentials would be printed out.
	
4. Run a heart model with a pacemaker device (with errors)
	Go to the directory <models>, and run the following in the Matlab command window:
	>> RunCLS
	In the GUI, enter the simulation time (ms) in the box under "Stop" within Operations panel on the left.
	Click "Start" within Operations panel.
	The electrical activations of the cardiac conduction system is shown on the left (red triangles denote depolarization and blue ones indicate repolarization) and the EGMs are displayed on the right. 
	Click "Stop" within Operations panel and close the GUI window.
5. Run a heart model with a pacemaker device (error fixed)	
	Go to the directory <models>, and run the following in the Matlab command window:
	>> RunCLSfixed
	
6. Build a new heart model
	Refer to PreBuild.m. 

## Model description
 
1.The parameter files: 
	Heart_N3.xlsx, the parameters have been adjusted to fit TT Endo and Courtemanche model

2.Model Libs:
	-Node_N_V6.slx: pacemaker cell model, nodal type, update parameters at the beginning of the slow depolarization, compute t3 and t0 before updating, and compute d2 and d1 after updating;
	-Node_M_V4.slx, cardiac myocyte model with interface to path model, only update parameters before start new cycle (before enter q1);
	-Path_V3.slx, path model;
	-Node_NM_V4.slx, subsidiary pacemaker cell model
	-Electrode.slx, Compute the potential sensed by leads due to moving activation on a path
	-Sensing.slx, Combine and control all egm contents
	-Pre_eventsv1.slx, preprocess input signals
	-Ratesv1.slx, compute rates
	-Cnds_DDDv1.slx, monitor execution traces and check if the traces meet the specifications
	-PMTv1.slx, monitor the occurrence of PMT
	-PM_DDD_v1.slx, DDD mode pacemaker with errors
	-PM_DDD_v3.slx, DDD mode pacemaker without errors
	-HeartV9.slx, heart model

3.Scripts:
	-PreBuild.m, a demo showing automatically building a heart model. Please be aware that the version of excel files, libraries, and some parameters may need to modify. 
	-PreCfgfcn.m, Read parameters from the excel file given filenames and data range to;
		•	Generate configuration data for heart model building;
		•	Create a lookup table for parameters update
		•	Cfgports: input configuration of the demux connecting with the parameter input port
		•	Cfgdata: All the parameters
	-Buildmodel_fcn.m, automatically build a heart model provided that the parameters and the connection relations of cells and paths are available (node names, types and path names); Need to specify the library for the components
	-Heart_GUI.m, generate a UI and link to the model
	-SaveTrace_sfcn.m, update UI and save simulation traces
	-subtightplot.m, make the subplots close to each other, got it on-line.
	-genpp.m, generate new parameters

## History

October 4, 2019
	* Version 1 is posted on the public GitHub repository	

## Need-to-know
	* In the path model, only the voltage during q3 contribute to the activation of its neighbouring cells, which is an approximation.
	* If the action potential of a cardiomyocyte is greater than the VO during q3 location at given parameters, e.g., out of the physiological range, the output would be saturated to VO. A better saturation approach can be found in the references [5,6], which only caps the overshoot at the end of q2.
	* The models are implemented to facilitate parameterization. The parameters can be updated at run time. For fixed parameters application, the implementation can be simplified and please refer to the papers for the model descriptions.
	* The GUI is not fully tested.
	
LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.                                    

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                           

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA