clear
clc

load minutes.mat % if minutes changes you need to update this variables
load parms_name.mat

%% import file txt
addpath(genpath(cd));
files = uipickfiles('FilterSpec','*.mat');

for parm = 1:length(parms_name)
    
    matrice = zeros(length(minutes),length(files));
    
    for num_file = 1:length(files)
    
    %retrieve files and names
    [filepath,name] = fileparts(files{num_file});
    load(files{num_file});    
    sub_names{num_file} = name; %all names for saving later in the table columns
    
        for min = 1:length(minutes)

            matrice(min,num_file) = Analysis.(minutes{min}).(parms_name{parm});
            
        end
        
    end
    
    % convert to table and replace each column as subject name 
    t = array2table(matrice);
    t.Properties.VariableNames = sub_names;
    t.Properties.RowNames = minutes;    

    Path_saveFile = [pwd '/HRV_Analysis.xlsx']; %change 
    writetable(t,Path_saveFile, 'Sheet', parms_name{parm},'WriteRowNames',true);

    
end

