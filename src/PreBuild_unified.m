function PreBuild_unified(second,arrays)
arguments
    second = true;
    arrays = 'NaN';
end
%%
% Read in user inputs for the reading of excel file and saving of model
% (loop ensures the user puts in the correct information for it to work)
if ~isstruct(arrays)
    while(1)
        answer = dialogoptions();
        if isempty(answer)
            empty_answer = questdlg('Do you really want to cancel?', ...
                'Cancel Model Creation','Yes','No','Yes');
            switch empty_answer
                case 'Yes'
                    return
                case 'No'
            end
        elseif ischeck(answer)
            break
        end
    end
    filexls=answer{1}; % The excel file name
    % contains all configurations of heart model, which will be used to build a new heart model
    filename=answer{2};
    % contains all parameters of heart model, which will be used for simulation
    datafile=answer{3};
    % The name of the heart model
    HeartModel=answer{4};
    % Specify the range of reading
    Noderange=answer{5};
    Node_P_range= answer{6}; % the parameter names
    Pathrange= answer{7};
    Path_P_range= answer{8};% the parameter names
    Proberange= answer{9};
    Standalone = ismember(lower(answer{10}),{'true','1','yes'});
else
    while(1)
        answer = dialogoptions_sml();
        if isempty(answer)
            empty_answer = questdlg('Do you really want to cancel?', ...
                'Cancel Model Creation', ...
                'Yes (revert to original model)','No (continue with creation)',...
                'Yes (revert to original model)');
            switch empty_answer
                case 'Yes (revert to original model)'
                    return
                case 'No'
            end
        elseif ischeck_sml(answer)
            break
        end
    end
    % The name of the heart model
    HeartModel=answer{1};
    % contains all configurations of heart model, which will be used to build a new heart model
    filename=answer{2};
    % contains all parameters of heart model, which will be used for simulation
    datafile=answer{3};
    filexls = 'NaN';
    Noderange = 'NaN';
    Node_P_range = 'NaN';
    Pathrange = 'NaN';
    Path_P_range = 'NaN';
    Proberange = 'NaN';
    Standalone = false;
end
[Node,Node_name,Node_pos,Path,Path_name,...
    Probe,Probe_name,Probe_pos,cfgports]=PreCfgfcn_unified(filexls,...
        Noderange,Node_P_range,Pathrange,Path_P_range,Proberange,filename,datafile,second,arrays);

%% Choose Nodes/Path library and build a heart model,which will be saved to the systempath.
rootPath=pwd;% may result in errors if running file from within 'src'
path_var=[rootPath,filesep 'models']; % the path where the model will be saved
% TO ADD: Confirm Libs_unified and add it in here instead of either library
if second
    folder='Libs_second';
else
    folder='Libs';
end
library = [rootPath,filesep 'Lib' filesep folder];% the components library path
node_n = append(folder,'/Node_N_V6'); % The N type cell model library
node_m = append(folder,'/Node_M_V4'); % The M type cell model library
node_nm = append(folder,'/Node_NM_V4'); % The NM type cell model library
path = append(folder,'/Path_V3'); % The path model library
probe=append(folder,'/Electrode'); % The EGM generation model library
Buildmodel_fcn(HeartModel,filename,node_n,node_m,node_nm,...
    path,probe,path_var,library,Standalone);
% If this function was started from Heart_Editing then incorporate it into
% CLSfixed
if isstruct(arrays)
    load_system(HeartModel)
    c = load_system('CLSfixed.slx'); %how to guarantee it is a nopace/pace
    replace_block(c,'Name','Heart', append(HeartModel,'/Heart'),'noprompt')
    replace_block(c,'Name','Heart1', append(HeartModel,'/Heart'),'noprompt')
    save_system(c,[path_var, filesep, 'CLSfixed_current.slx'])    
end
end

function answer = dialogoptions()
%popup box for the user defined inputs
prompt = {'Enter input excel file name:','Cfg file name:',...
    'Data file name:', 'Heart model name:', 'Node range:',...
        'Node Parameter range:', 'Path range:',...
        'Path Parameter range:','Probe range:', 'Standalone Heart:'};
dlgtitle = 'Input';
fieldsize = [1 30; 1 30; 1 30; 1 30; 1 20; 1 20; 1 20; 1 20; 1 20; 1 20];
definput = {'Heart_N3_second.xlsx','N3Cfg_example.mat',...
    'N3Data_example.mat','Heart_example', 'A2:AW44'...
        'D1:AW1','A2:O55','E1:O1','A2:E9', 'Yes'}; %A2:E9 throws errors (TO DEBUG)
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
end

function answer = dialogoptions_sml()
%popup box for the user defined inputs
prompt = {'Heart model name:','Cfg file name:','Data file name:'};
dlgtitle = 'Input';
fieldsize = [1 30; 1 30; 1 30];
definput = {'Heart_example','N3Cfg_example.mat','N3Data_example.mat'};
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
end

function result=ischeck(cell_array)
% Function to check if the inputs are correct
for idx=1:length(cell_array)
    if isnumeric(cell_array{idx}) || isempty(cell_array{idx})
        f =msgbox("Invalid Value: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return 
    elseif idx ==1 && ~exist(char(cell_array{idx}),'file')
        f = msgbox("File does not exist: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return 
    elseif (idx >1 && idx <4) && ~contains(cell_array{idx},'.mat')
        f = msgbox("File error: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return 
    elseif (idx >4 && idx <length(cell_array)) && ~contains(cell_array{idx},':')
        f = msgbox("Range incomprehensible: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return
    elseif (idx ==(length(cell_array))) && ~ismember(lower(cell_array{idx}),...
            {'true','1','yes','false','0','no'})
        f = msgbox("Response incomprehensible: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return
    end
end
result = true;
end

function result=ischeck_sml(cell_array)
% Function to check if the inputs are correct for the smaller version
for idx=1:length(cell_array)
    if isnumeric(cell_array{idx}) || isempty(cell_array{idx})
        f =msgbox("Invalid Value: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return 
    elseif (idx >1) && ~contains(cell_array{idx},'.mat')
        f = msgbox("File error: "+cell_array{idx},"Error","error");
        result = false;
        waitfor(f);
        return 
    end
end
result = true;
end