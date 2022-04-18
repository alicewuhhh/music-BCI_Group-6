%% load all the files
clear all; close all; clc
saveLoc = '/Users/aliceqichaowu/Documents/GitHub/music-BCI_Group-6/dataset/class_concat/cross_val/';
dataLoc = '/Users/aliceqichaowu/Documents/GitHub/music-BCI_Group-6/dataset/raw_data';
cd(dataLoc)
files = dir('*.mat');
filenames_orig = {files(:).name};
filenames = cellfun(@(n) n(1:7),filenames_orig,'UniformOutput',false);
%%
% section find classes and codes
for f =1:length(files)
    load(sprintf(filenames_orig{f}),'calibration');
    stimcode=calibration.stimcode;
    stimpos=calibration.stimpos;
    data=calibration.data;

eeg_class1=[];
eeg_class2=[];
eeg_class3=[];

ind_1=find(stimcode==131);
ind_2=find(stimcode==132);
ind_3=find(stimcode==133);
for i=1:2
eeg_class1=[eeg_class1,data(4:17, stimpos(ind_1(i)):stimpos(ind_1(i)+1))];
eeg_class2=[eeg_class2,data(4:17, stimpos(ind_2(i)):stimpos(ind_2(i)+1))];
eeg_class3=[eeg_class3,data(4:17, stimpos(ind_3(i)):stimpos(ind_3(i)+1))];
end

epoch_class1 = zeros(length(eeg_class1), 1);
epoch_class2 = zeros(length(eeg_class2), 1);
epoch_class3 = zeros(length(eeg_class3), 1);

for i = 1:length(eeg_class1)
    epoch_class1(i,1) = i;
end
for j = 1:length(eeg_class2)
    epoch_class2(j,1) = j;
end
for k = 1:length(eeg_class3)
    epoch_class3(k,1) = k;
end

% preprocessing
% overlap = 448; %% 87.5% overlap
% win = 512; %% 128*4sec
% step = win-overlap;

overlap = 128*0.875;
win = 128;
step = win-overlap;

class1_signal = zeros(14*fix(length(eeg_class1)/step),win);
class2_signal = zeros(14*fix(length(eeg_class2)/step),win);
class3_signal = zeros(14*fix(length(eeg_class3)/step),win);

for i = 1:step:length(epoch_class1)/step
    class1_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class1(:,((i-1)*step + 1):((i-1)*step + win));
end
for i = 1:step:length(epoch_class2)/step
    class2_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class2(:,((i-1)*step + 1):((i-1)*step + win));
end
for i = 1:step:length(epoch_class3)/step
    class3_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class3(:,((i-1)*step + 1):((i-1)*step + win));
end

% filtering


% theta (4-7 Hz),alpha (8-13 Hz), low beta (14-21 Hz), high beta (22-29 Hz) and gamma (30-47 Hz).
% 70 features = 14 channel * 5 frequency bands 

% [Atheta,Btheta,Ctheta,Dtheta] = cheby2(1,20,[4 7]/64, 'bandpass'); % 64 = 128/2
% [Aalpha,Balpha,Calpha,Dalpha] = cheby2(1,20,[8 13]/64, 'bandpass');
% [Albeta,Blbeta,Clbeta,Dlbeta] = cheby2(1,20,[14 21]/64, 'bandpass');
% [Ahbeta,Bhbeta,Chbeta,Dhbeta] = cheby2(1,20,[22 29]/64, 'bandpass');
% [Agamma,Bgamma,Cgamma,Dgamma] = cheby2(1,20,[30 47]/64, 'bandpass');
[ztheta,ptheta,ktheta] = cheby2(1,20,[4 7]/64, 'bandpass');
[zalpha,palpha,kalpha] = cheby2(1,20,[8 13]/64, 'bandpass');
[zlbeta,plbeta,klbeta] = cheby2(1,20,[14 21]/64, 'bandpass');
[zhbeta,phbeta,khbeta] = cheby2(1,20,[22 29]/64, 'bandpass');
[zgamma,pgamma,kgamma] = cheby2(1,20,[30 47]/64, 'bandpass');
[sos_theta, g_theta] = zp2sos(ztheta,ptheta,ktheta);
[sos_alpha, g_alpha] = zp2sos(zalpha,palpha,kalpha);
[sos_lbeta, g_lbeta] = zp2sos(zlbeta,plbeta,klbeta);
[sos_hbeta, g_hbeta] = zp2sos(zhbeta,phbeta,khbeta);
[sos_gamma, g_gamma] = zp2sos(zgamma,pgamma,kgamma);

theta1_signalout = filtfilt(sos_theta, g_theta, class1_signal);
alpha1_signalout = filtfilt(sos_alpha, g_alpha, class1_signal);
lbeta1_signalout = filtfilt(sos_lbeta, g_lbeta, class1_signal);
hbeta1_signalout = filtfilt(sos_hbeta, g_hbeta, class1_signal);
gamma1_signalout = filtfilt(sos_gamma, g_gamma, class1_signal);

%%
theta2_signalout = filtfilt(sos_theta, g_theta, class2_signal);
alpha2_signalout = filtfilt(sos_alpha, g_alpha, class2_signal);
lbeta2_signalout = filtfilt(sos_lbeta, g_lbeta, class2_signal);
hbeta2_signalout = filtfilt(sos_hbeta, g_hbeta, class2_signal);
gamma2_signalout = filtfilt(sos_gamma, g_gamma, class2_signal);

%%
theta3_signalout = filtfilt(sos_theta, g_theta, class3_signal);
alpha3_signalout = filtfilt(sos_alpha, g_alpha, class3_signal);
lbeta3_signalout = filtfilt(sos_lbeta, g_lbeta, class3_signal);
hbeta3_signalout = filtfilt(sos_hbeta, g_hbeta, class3_signal);
gamma3_signalout = filtfilt(sos_gamma, g_gamma, class3_signal);

%%
class1_concat = zeros(length(alpha1_signalout)*5,win);
class2_concat = zeros(length(alpha2_signalout)*5,win);
class3_concat = zeros(length(alpha3_signalout)*5,win);

%% concatenate 5-frequency
step=14;

for i=1:length(alpha1_signalout)/step
    class1_concat(((i-1)*step*5 + 1):((i-1)*step*5 + step),:)=alpha1_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class1_concat(((i-1)*step*5 + 15):((i-1)*step*5 + step*2),:)=theta1_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class1_concat(((i-1)*step*5 + 29):((i-1)*step*5 + step*3),:)=lbeta1_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class1_concat(((i-1)*step*5 + 43):((i-1)*step*5 + step*4),:)=hbeta1_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class1_concat(((i-1)*step*5 + 57):((i-1)*step*5 + step*5),:)=gamma1_signalout(((i-1)*step + 1):((i-1)*step + step),:);
end  
for i=1:length(alpha2_signalout)/step
    class2_concat(((i-1)*step*5 + 1):((i-1)*step*5 + step),:)=alpha2_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class2_concat(((i-1)*step*5 + 15):((i-1)*step*5 + step*2),:)=theta2_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class2_concat(((i-1)*step*5 + 29):((i-1)*step*5 + step*3),:)=lbeta2_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class2_concat(((i-1)*step*5 + 43):((i-1)*step*5 + step*4),:)=hbeta2_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class2_concat(((i-1)*step*5 + 57):((i-1)*step*5 + step*5),:)=gamma2_signalout(((i-1)*step + 1):((i-1)*step + step),:);
end  
for i=1:length(alpha3_signalout)/step
    class3_concat(((i-1)*step*5 + 1):((i-1)*step*5 + step),:)=alpha3_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class3_concat(((i-1)*step*5 + 15):((i-1)*step*5 + step*2),:)=theta3_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class3_concat(((i-1)*step*5 + 29):((i-1)*step*5 + step*3),:)=lbeta3_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class3_concat(((i-1)*step*5 + 43):((i-1)*step*5 + step*4),:)=hbeta3_signalout(((i-1)*step + 1):((i-1)*step + step),:);
    class3_concat(((i-1)*step*5 + 57):((i-1)*step*5 + step*5),:)=gamma3_signalout(((i-1)*step + 1):((i-1)*step + step),:);
end

save([saveLoc filenames{f} 'class_concat.mat'],'class1_concat','class2_concat','class3_concat');

% class1_cc{f} = class1_concat;
% class2_cc{f} = class2_concat;
% class3_cc{f} = class3_concat;

end


