clear
clc

%% import file txt
addpath(genpath(cd));
Fs = 100;       %Frequency
files = uipickfiles('FilterSpec','*.txt');

for num_file = 1:length(files)
    
    [filepath,name] = fileparts(files{num_file});
    
    % load and cut the matrix and names of the variables
    
    [HandGrip,Names] = Import_Porta_Press_Data(files{num_file});
    
    %column 6 is the RR interval
    RR_intero = HandGrip(:,6);        
           
    %% Array index every sixty seconds for 10 min
    timing = 0:60:(60*10);
    %timing(1) = 1;
    
    %find locations every 60s roughly
    [~, index] = ismember(timing,ceil(HandGrip(:,1)));
    ind_zero = find(~index);        
    if (ind_zero == length(index))
          index(ind_zero) = length(RR_intero);
    end

    % in case try other combinations
    if(~isempty( find(~index,1) ) )
        [~, index] = ismember(timing,floor(HandGrip(:,1)));
    end
    
    if(~isempty( find(~index,1) ) )
        [~, index] = ismember(timing,round(HandGrip(:,1)));
    end
    
    if(~isempty( find(~index,1) ) )
        ind_zero = find(~index);
        
        if (ind_zero == length(index))
            index(ind_zero) = length(RR_intero);
        else            
            index(ind_zero) = index(ind_zero-1) + 60; %attenzione !!
        end
    end
   
    %index(1) = 1;    
    minuto = 0:1:10;
    
    %% calculate parameters every min
    for loc = 2:length(timing)
        
        %RR =   HRV.RRfilter(RR_intero(index(loc-1):index(loc)), 0.15);
        RR = (RR_intero(index(loc-1):index(loc)));
        Analysis.(['minute'+ string(minuto(loc))]).RR = RR;
        
        Analysis.(['minute'+ string(minuto(loc))]).HR =   HRV.HR(RR);
        Analysis.(['minute'+ string(minuto(loc))]).sd =   HRV.SDSD(RR);
        Analysis.(['minute'+ string(minuto(loc))]).sdnn =  HRV.SDNN(RR);
        Analysis.(['minute'+ string(minuto(loc))]).rmssd = HRV.RMSSD(RR); %rimuove 10%
        Analysis.(['minute'+ string(minuto(loc))]).rrhrv = HRV.rrHRV(RR);
        
        [hrv_pNNx,hrv_NNx] =    HRV.pNNx(RR,100,60); %%<-- non funzia
        Analysis.(['minute'+ string(minuto(loc))]).hrv_pNNx = hrv_pNNx;
        Analysis.(['minute'+ string(minuto(loc))]).hrv_NNx = hrv_NNx;
        
        Analysis.(['minute'+ string(minuto(loc))]).hrv_pNN50 = HRV.pNN50(RR);
        
        [TRI,TINN] = HRV.triangular_val(RR);
        Analysis.(['minute'+ string(minuto(loc))]).TRI = TRI;
        Analysis.(['minute'+ string(minuto(loc))]).TINN = TINN;
        
        %TRI = HRV.TRI(RR(1:60))
        Analysis.(['minute'+ string(minuto(loc))]).alpha =  HRV.DFA(RR);
        Analysis.(['minute'+ string(minuto(loc))]).cdim =   HRV.CD(RR);
        Analysis.(['minute'+ string(minuto(loc))]).apen =   HRV.ApEn(RR);
        
        %fft
        [pLF,pHF,LFHFratio,VLF,LF,HF,f,Y,NFFT] =   HRV.fft_val_fun(RR,Fs);
        
        Analysis.(['minute'+ string(minuto(loc))]).pLF = pLF;
        Analysis.(['minute'+ string(minuto(loc))]).pHF = pHF;
        Analysis.(['minute'+ string(minuto(loc))]).LFHFratio = LFHFratio;
        Analysis.(['minute'+ string(minuto(loc))]).VLF = VLF;
        Analysis.(['minute'+ string(minuto(loc))]).LF = LF;
        Analysis.(['minute'+ string(minuto(loc))]).HF = HF;
        
        [SD1,SD2,SD1SD2ratio] = HRV.returnmap_val(RR);
        Analysis.(['minute'+ string(minuto(loc))]).SD1 = SD1;
        Analysis.(['minute'+ string(minuto(loc))]).SD2 = SD2;
        Analysis.(['minute'+ string(minuto(loc))]).SD1SD2ratio = SD1SD2ratio;
        %numbers 4 Ale
        Analysis.(['minute'+ string(minuto(loc))]).fiSYS = mean(HandGrip(index(loc-1):index(loc),2));
        Analysis.(['minute'+ string(minuto(loc))]).fiDIA = mean(HandGrip(index(loc-1):index(loc),3));
        Analysis.(['minute'+ string(minuto(loc))]).fiMAP = mean(HandGrip(index(loc-1):index(loc),4));
        Analysis.(['minute'+ string(minuto(loc))]).IBI = mean(HandGrip(index(loc-1):index(loc),6));
        Analysis.(['minute'+ string(minuto(loc))]).SV = mean(HandGrip(index(loc-1):index(loc),7));
        Analysis.(['minute'+ string(minuto(loc))]).CO = mean(HandGrip(index(loc-1):index(loc),8));
        Analysis.(['minute'+ string(minuto(loc))]).EJT = mean(HandGrip(index(loc-1):index(loc),9));
        Analysis.(['minute'+ string(minuto(loc))]).TPR = mean(HandGrip(index(loc-1):index(loc),10));
        
        % other calculations
        deltaIBI = diff(HandGrip(index(loc-1):index(loc),6)) * 1000; %from s to ms
        deltaSys = diff(HandGrip(index(loc-1):index(loc),2));
        
        Analysis.(['minute'+ string(minuto(loc))]).BaroRecGain = mean(abs(deltaIBI)) / mean(abs(deltaSys));
        
    end
    
    %% calculate parameters in 3 steps (Baseline 3', Handgrip 5', Rest 2')
    mean_min = [1,4,9,11];
    index = index(mean_min);
    for loc = 2:length(mean_min)
    
        RR = (RR_intero(index(loc-1):index(loc)));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).RR = RR;
        
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).HR =   HRV.HR(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).sd =   HRV.SDSD(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).sdnn =  HRV.SDNN(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).rmssd = HRV.RMSSD(RR); %rimuove 10%
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).rrhrv = HRV.rrHRV(RR);
        
        %[hrv_pNNx,hrv_NNx] =    HRV.pNNx(RR,100,60); %%<-- non funzia
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).hrv_pNNx = hrv_pNNx;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).hrv_NNx = hrv_NNx;
        
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).hrv_pNN50 = HRV.pNN50(RR);
        
        [TRI,TINN] = HRV.triangular_val(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).TRI = TRI;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).TINN = TINN;
        
        %TRI = HRV.TRI(RR(1:60))
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).alpha =  HRV.DFA(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).cdim =   HRV.CD(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).apen =   HRV.ApEn(RR);
        
        %fft
        [pLF,pHF,LFHFratio,VLF,LF,HF,f,Y,NFFT] =   HRV.fft_val_fun(RR,Fs);
        
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).pLF = pLF;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).pHF = pHF;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).LFHFratio = LFHFratio;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).VLF = VLF;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).LF = LF;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).HF = HF;
        
        [SD1,SD2,SD1SD2ratio] = HRV.returnmap_val(RR);
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).SD1 = SD1;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).SD2 = SD2;
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).SD1SD2ratio = SD1SD2ratio;
        %numbers 4 Ale
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).fiSYS = mean(HandGrip(index(loc-1):index(loc),2));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).fiDIA = mean(HandGrip(index(loc-1):index(loc),3));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).fiMAP = mean(HandGrip(index(loc-1):index(loc),4));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).IBI = mean(HandGrip(index(loc-1):index(loc),6));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).SV = mean(HandGrip(index(loc-1):index(loc),7));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).CO = mean(HandGrip(index(loc-1):index(loc),8));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).EJT = mean(HandGrip(index(loc-1):index(loc),9));
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).TPR = mean(HandGrip(index(loc-1):index(loc),10));
        
        % other calculations
        deltaIBI = diff(HandGrip(index(loc-1):index(loc),6)) * 1000; % s to ms;
        deltaSys = diff(HandGrip(index(loc-1):index(loc),2));
        
        Analysis.(['mean_min'+ string(mean_min(loc)-1)]).BaroRecGain = mean(abs(deltaIBI)) / mean(abs(deltaSys));
    end
    
    %% save data and struct var
    if ~exist([filepath '/HRV_Elaborated/'], 'dir')
        mkdir([filepath '/HRV_Elaborated/'])
    end
    
    Path_saveFile= [filepath '/HRV_Elaborated/' name '.mat'];
    save(Path_saveFile,'Analysis','-mat');
    
    
    
    clear Analysis
        
end