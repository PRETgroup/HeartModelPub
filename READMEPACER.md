# HeartModelPub

![pacer LOGO ](./images/pacer2.png)

HeartModelPub provides a computational heart model for simulating cardiac electrophysiology and testing implantable pacemaker devices in closed-loop scenarios.

HeartModelPub includes:

- Pacemaker cell models [[1]](https://doi.org/10.1109/tbme.2017.2695537)  
- Cardiomyocytes [[2]](https://doi.org/10.1145/3134845) ,[[3]](https://doi.org/10.1109/tbme.2019.2917212) 
- Cardiac conduction system [[3]](https://doi.org/10.1109/tbme.2019.2917212)
- Electrogram (EGM) signal generation [[4]](https://doi.org/10.1109/embc.2017.8037237)

All models are implemented in MATLAB/Simulink, allowing modular configuration, parameter tuning, and closed-loop simulations.

We have demonstrated in-silico validation of a DDD mode pacemaker using the virtual physiological heart model in the closed loop [[5]](https://doi.org/10.1109/jbhi.2019.2947007)
For C code generation and implementation using Piha, refer to [[6]](https://dl.acm.org/doi/10.5555/2971808.2971959),[[7]](https://dl.acm.org/doi/abs/10.1145/3126536).

Last updated: November 28, 2025.

>© Copyright 2025 Weiwei Ai, wai484@aucklanduni.ac.nz, The University of Auckland 

>   Licensed under the Apache License, Version 2.0 (the "License");you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
>
>   Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
>   See the License for the specific language governing permissions and limitations under the License.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

[![View on MATLAB File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://au.mathworks.com/matlabcentral/fileexchange/154301-heartmodelpub/)

[![View on GitHub](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/PRETgroup/HeartModelPub)

---

## Table of Contents

1. [Introduction](#introduction)
   - [Background](#background)
   - [Model Descriptions](#model-descriptions)
       - [Model Libraries](#Model-Libraries)
       - [Scripts](#Scripts)
       - [Parameter files ](#Parameter-files)
   
2. [Getting Started](#getting-started)
   - [Setup Instructions](#Add-the-library-files-to-the-path) 
   - [Run model simulations](#Run-model-simulations)
   
3. [Cell Models](#cell-models)
   - [Cell Types Overview](#cell-types-overview)
   - [Pacemaker Cells (Type N)](#pacemaker-cells-type-n)
   - [Myocytes (Type M)](#myocytes-type-m)
   - [Subsidiary Pacemakers (Type NM)](#subsidiary-pacemakers-type-nm)

4. [Heart Model](#heart-model)
 
5. [Device Testing & Validation](#device-testing--validation)
   - [Closed-Loop Validation](#closed-loop-validation)
   - [DDD Pacemaker Mode](#ddd-pacemaker-mode)

6. [Examples & Tutorials](#examples--tutorials)
   - [Example 1: Simple Pacemaker Cell](#example-1-simple-pacemaker-cell)
   - [Example 2: Overdrive Suppression](#example-2-overdrive-suppression)
   - [Example 3: Heart Simulation](#example-3-heart-simulation)
   - [Example 4: Closed-Loop Device Testing](#example-4-closed-loop-device-testing)
   - [Example 5: Custom Model Building](#example-5-custom-model-building)

7. [Need-to-Know](#need-to-know)

8. [References](#references)

9. [Acknowledgment](#Acknowledgment)

10. [License History](#License-history)
---

## Introduction

The core objective of this work is the development of a flexible, efficient, and verifiable computational pacemaker cell model that is essential for designing real-time virtual hearts. These virtual hearts are intended for the closed-loop validation of cardiac devices. The proposed framework supports device testing within an in-silico closed-loop context of patient physiology.

### Background

Traditional biophysically-based heart models rely on coupled differential equations, making them computationally costly to solve and unsuitable for real-time emulation or formal verification. 
To overcome this challenge while retaining dynamic physiological features, the models utilize the Hybrid Automaton (HA) formalism. 
HA models retain computational efficiency while supporting the modeling of continuous membrane voltage evolution and distinct action potential phases.

The heart is represented as an abstracted network of nodes (regional tissue clusters) connected by edges.

![Abstracted heart model ](./images/Abstracted_heart_model.png)[[3]](https://doi.org/10.1109/tbme.2019.2917212)

### Model Descriptions

The heart model is organized into libraries, models, and scripts. Each component is designed for specific role.  
- The **Lib/** folder contains the core component libraries, including cellular models (pacemaker, myocyte, and subsidiary pacemaker cells), conduction paths, EGM sensing modules, and pacemaker devices, with separate versions for millisecond- and second-based simulations. 
- The **models/**  provides pre-built examples, ranging from single-cell pacemaker models to full heart simulations, allowing users to quickly run simulations or test specific scenarios. 
- For more detailed or high-resolution variants, the **models_refine/**  contains complex heart models with increased numbers of nodes and paths. 
- The **src/**  hosts all utility scripts, including automatic model builders, configuration processors, GUI tools, plotting functions, and parameter generators, enabling users to customize and automate simulations. 

#### Model Libraries

Two versions of library exist: **Libs.slx** & **Libs_second.slx** (Seconds) Same components but adapted for second based simulation for hardware integration ([Notes on Modification from Milliseconds (ms) to Seconds](#notes-on-modification-from-milliseconds-ms-to-seconds)).

#### Model Libraries

| Model | Description |
|-------|-------------|
| **Node_N_V6.slx** | - Nodal pacemaker cell model<br>- Updates parameters at the beginning of slow depolarization  <br>- Computes t3 and t0 before updating<br>- Computes d2 and d1 after updating |
| **Node_M_V4.slx** | - Cardiac myocyte cell model<br>- Parameters updated only at the start of a new cycle (before entering q1)<br>- Interfaces with path model |
| **Node_NM_V4.slx** | - Subsidiary pacemaker cell<br>- Hybrid nodal–muscle cell enabling both pacemaker and fast-response behaviours |
| **Path_V3.slx** | - Electrical conduction path model<br>- Simulates the propagation of action potentials between cardiac cells |
| **Electrode.slx** | - Computes the potential sensed by pacemaker leads due to moving activation along a path |
| **Sensing.slx** | - EGM signal combination and control module |
| **Pre_eventsv1.slx** | - Preprocesses and conditions input signals |
| **Ratesv1.slx** | - Computes atrial/ventricular instantaneous rates<br>- Provides rate-dependent variables |
| **Cnds_DDDv1.slx** | - Monitors execution traces<br>- Checks compliance with pacemaker specifications |
| **PMTv1.slx** | - Pacemaker-mediated tachycardia detector<br>- Identifies PMT loops<br>- Monitors retrograde conduction and atrial tracking |
| **PM_DDD_v3.slx** | - Dual-chamber pacemaker model (DDD mode) |
| **HeartV9.slx** | - Full heart model integrating nodes, myocytes, and conduction paths |

#### Scripts

| Script | Description |
|--------|-------------|
| **PreBuild.m** | - Demo showing automatic building of a heart model |
| **PreCfgfcn.m** | - Reads parameters from an Excel file using filenames and data range<br>- Generates configuration data for heart model building<br>- Creates a lookup table for parameter updates<br>- **Cfgports**: Input configuration for the demux connecting to the parameter input port<br>- **Cfgdata**: All the parameters |
| **Buildmodel_fcn.m** | - Automatically builds a heart model using available parameters and connection relations of cells and paths (node names, types, path names)<br>- Requires specifying the component library |
| **Heart_GUI.m** | - Generates a UI and links it to the model |
| **SaveTrace_sfcn.m** | - Updates the UI and saves simulation traces |
| **subtightplot.m** | - Makes the subplots close to each other<br>- Utility script obtained online |
| **genpp.m** | - Generates new parameters |

#### Parameter files  

| File | Description |
|------|-------------|
| **Heart_N3.xlsx** | Contains the parameters of the heart model with simulation time in **milliseconds** |
| **Heart_N3_second.xlsx** | Contains the parameters of the heart model with simulation time in **seconds** |

#### Notes on Modification from Milliseconds (ms) to Seconds

The model was originally developed using **milliseconds (ms)** as the simulation time.  
For hardware integration, it has been modified to use **seconds (s)**. The key modifications are:

- **Node_N_V6 / Automaton / function rr=RR(...) / line 27:**   `y =bff'*2*pi*pt`: removed `/1000` in **Libs_second.slx**.
- **Sensing / Chart and Sensing / Chart3:**  
  Use `temporalCount(msec)` and `after(3,msec)` in **Libs_second.slx**.  
  In **Libs.slx**, the original code uses `temporalCount(sec)` and `after(3,sec)`.
- **Libs_second / Path_V3 / Path (Buffer_i and Buffer_j):**  
  Thresholds changed: `tbi >= 599` → `tbi >= 0.599`, `tbj >= 599` → `tbj >= 0.599`.  
  Note: This only affects action potentials where APD > 600 ms.
- **CLK Modules (inputs to Sensing, Pre_eventsv1, Ratesv1, Cnds_DDDv1, PMTv1, PM_DDD_v3):**  
  Set `Period(secs) = 0.001`.
- **Timing parameters of sensing and pacemaker modules:**  
  Remain the same (use ms).
- Use **Heart_N3_second.xlsx**, which contains modified parameters for simulation time in seconds.


## Getting Started  

### Add the library files to the path

Before running any simulations, add all library files to the MATLAB® search path for the current session. This ensures that all models, scripts, and utility functions are accessible. Run:
```matlab
>> setup_Heart
```
### Run model simulations  

All the running examples are under the directory *models* or *models_refine*, firstly go to the directory by clicking the folder or running the following in the Matlab command window:     
```matlab
>> cd models
```
**1. Automaticity simulation of pacemaker cell models**  

Pacemaker cells can initiate action potentials without external stimulation.

 In the folder, there are three pacemaker cell models: <BR/>(1) SA node model "**SAcell.slx**",<BR/>(2) AV node model "**CNcell.slx**", and <BR/> (3) His-Purkinje fibre cell "**HPScell.slx**".

 To simulate the models: <BR/> 1.Open a cell model and click "Run" button in Simulink or run the simulation using the Matlab commands:

```matlab
>> open('SAcell.slx') 
>> sim('SAcell.slx')
```
2.Once the simulation finishes, click the scope to view the output trace. 	
 	
**2. Overdrive suppression simulation**

If a pacemaker cell is depolarized at a higher frequency than its intrinsic rate, its automaticity may be suppressed, which is known as overdrive suppression.
![Overdrive suppression ](./images/Overdrive_suppression.png)
Here an external stimuli is applied to a pacemaker cell to demonstrate this effect.  
The model **AV.slx** is preconfigured with a pulse input, and the script **simAV_Trace.m** is provided to run the simulation.

1.Run the following in the Matlab command window:  
```matlab
>> simAV_Trace
```
2.Once the simulation finishes, **Plottrace.m** can be used to plot the simulation traces:       
```matlab
>> Plottrace 
```
**3. Run a heart model without external pacing pulses**	  

This section describes how to simulate the full heart model operating under its intrinsic rhythm, without any external pacing stimulation.

1.Open HeartExe.slx and click "Run" in Simulink, or run the following in the Matlab command window:     
```matlab
>>open('HeartExe.slx')
>>sim('HeartExe.slx')
```
2.Once the simulation finishes, the specified action potentials can be printed out by running the following in the Matlab command window:          
```matlab
>> load('Cells.mat')     
>> plotCells
```
![action_potentials ](./images/action_potentials.png)

**4. Run a heart model with a pacemaker device**   
   1. Run the following in the Matlab command window:         
    >> RunCLSfixed     	     
   2. In the GUI, enter the simulation time (ms) in the box under "Stop" within Operations panel on the left.     		 
   3. Click "Start" within Operations panel.      
The electrical activations of the cardiac conduction system is shown on the left (red triangles denote depolarization and blue ones indicate repolarization) and the EGMs are displayed on the right.    		 
   4. Click "Stop" within Operations panel and close the GUI window.         
5. Build a new heart model     
     Refer to PreBuild.m.   


## References
 **Pacemaker cell models**:  
[1] Ai, Weiwei, et al. "A parametric computational model of the action potential of pacemaker cells." IEEE Transactions on Biomedical Engineering 65.1 (2017): 123-130.  
**Cardiomyocytes**:     
[2] Yip, Eugene, et al. "Towards the emulation of the cardiac conduction system for pacemaker validation." ACM Transactions on Cyber-Physical Systems 2.4 (2018): 32.  
**Cardiac conduction system**:  
[3] Ai, Weiwei, et al. "Cardiac electrical modeling for closed-loop validation of implantable devices." IEEE Transactions on Biomedical Engineering 67.2 (2019): 536-544.  
**EGM generation**:     
[4] Ai, Weiwei, et al. "An intracardiac electrogram model to bridge virtual hearts and implantable cardiac devices." 2017 39th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC). IEEE, 2017.  
**Closed loop validation**:     
[5] Ai, Weiwei, et al. "Closing the loop: Validation of implantable cardiac devices with computational heart models." IEEE journal of biomedical and health informatics 24.6 (2019): 1579-1588.  
**C code generation and implementation**:   
[6] Allen, Nathan, et al. "Modular code generation for emulating the electrical conduction system of the human heart." Proceedings of the 2016 Conference on Design, Automation & Test in Europe. EDA Consortium, 2016.  
[7] Malik, Avinash, et al. "Modular compilation of hybrid systems for emulation and large scale simulation." ACM Transactions on Embedded Computing Systems (TECS) 16.5s (2017): 118.  
**Other foundational work**:    
[8] Ye, Pei, et al. "Modelling excitable cells using cycle-linear hybrid automata." IET systems biology 2.1 (2008): 24-32.  
[9] Chen, Taolue, et al. "Quantitative verification of implantable cardiac pacemakers over hybrid heart models." Information and Computation 236 (2014): 87-101.  
[10] Jiang, Zhihao, Miroslav Pajic, and Rahul Mangharam. "Cyber–physical modeling of implantable cardiac medical devices." Proceedings of the IEEE 100.1 (2011): 122-137.  
[11] Pajic, Miroslav, et al. "From verification to implementation: A model translation tool and a pacemaker case study." 2012 IEEE 18th Real Time and Embedded Technology and Applications Symposium. IEEE, 2012.   
## Acknowledgment
1. The cardiomyocytes model [2] is based on the work [8] and the initial Simulink implementaion is from the Oxford group [9].
2. The initial topology of the cardiac conduction system [3] is from the work [10].
3. The DDD pacemaker is modified based on a published model [11].
## Need-to-know
* In the path model, only the voltage during q3 contribute to the activation of its neighbouring cells, which is an approximation.
* If the action potential of a cardiomyocyte is greater than the VO during q3 location at given parameters, e.g., out of the physiological range, the output would be saturated to VO. A better saturation approach can be found in the references [5,6], which only saturates the overshoot at the end of q2.
* The models are implemented to facilitate parameterization. The parameters can be updated at run time. For fixed parameters application, the implementation can be simplified. Please refer to the papers [1-4] for the model descriptions.
* The GUI is not fully tested.
## License History
* October 9, 2019  
Version 1 is posted on the public GitHub repository. Copyright 2019 Weiwei Ai, wai484@aucklanduni.ac.nz, The University of Auckland, under license GPL version 
* July 29, 2025  
Change the license to Apache-2.0





