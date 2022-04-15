%EEGLAB scripts
%load('data_all_participants.mat')
S01=load('P01_S01_calibration.mat');
% S02=load('P01_S02_calibration.mat');

% section find classes and codes
codes=S01.calibration.stimcode;
index=S01.calibration.stimpos;


eeg_class1=[];
eeg_class2=[];
eeg_class3=[];

ind_1=find(codes==131);
ind_2=find(codes==132);
ind_3=find(codes==133);
for i=1:2
eeg_class1=[eeg_class1,S01.calibration.data(4:17, index(ind_1(i)):index(ind_1(i)+1))];
eeg_class2=[eeg_class2,S01.calibration.data(4:17, index(ind_2(i)):index(ind_2(i)+1))];
eeg_class3=[eeg_class3,S01.calibration.data(4:17, index(ind_3(i)):index(ind_3(i)+1))];
end

%%
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

%% preprocessing
overlap = 448; %% 87.5% overlap
win = 512; %% 128*4sec
step = win-overlap;

class1_signal = zeros(14*fix(length(eeg_class1)/step),win);
class2_signal = zeros(14*fix(length(eeg_class2)/step),win);
class3_signal = zeros(14*fix(length(eeg_class3)/step),win);

for i = 1:step:length(epoch_class1)/step
    class1_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class1(:,((i-1)*step + 1):((i-1)*step + win));
end
for i = 1:step:length(epoch_class2)/step
    class2_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class1(:,((i-1)*step + 1):((i-1)*step + win));
end
for i = 1:step:length(epoch_class3)/step
    class3_signal(((i-1)*14 + 1):((i-1)*14 + 14),:) = eeg_class1(:,((i-1)*step + 1):((i-1)*step + win));
end

%% filtering
% theta (4-7 Hz),alpha (8-13 Hz), low beta (14-21 Hz), high beta (22-29 Hz) and gamma (30-47 Hz).
% 70 features = 14 channel * 5 frequency bands 
[Atheta,Btheta,Ctheta,Dtheta] = cheby2(1,20,[4 7]/64, 'bandpass'); % 64 = 128/2
[Aalpha,Balpha,Calpha,Dalpha] = cheby2(1,20,[8 13]/64, 'bandpass');
[Albeta,Blbeta,Clbeta,Dlbeta] = cheby2(1,20,[14 21]/64, 'bandpass');
[Ahbeta,Bhbeta,Chbeta,Dhbeta] = cheby2(1,20,[22 29]/64, 'bandpass');
[Agamma,Bgamma,Cgamma,Dgamma] = cheby2(1,20,[30 47]/64, 'bandpass');

% bpfilter = designfilt('bandpassiir','FilterOrder',2, ...
%      'StopbandFrequency1',4,'StopbandFrequency2',47, ...
%      'StopbandAttenuation',20,'SampleRate',128);
sos_theta = ss2sos(Atheta,Btheta,Ctheta,Dtheta);
sos_alpha = ss2sos(Aalpha,Balpha,Calpha,Dalpha);
sos_lbeta = ss2sos(Albeta,Blbeta,Clbeta,Dlbeta);
sos_hbeta = ss2sos(Ahbeta,Bhbeta,Chbeta,Dhbeta);
sos_gamma = ss2sos(Agamma,Bgamma,Cgamma,Dgamma);

theta1_signalout = filtfilt(sos_theta, class1_signal);
alpha1_signalout = filtfilt(sos_alpha, class1_signal);
lbeta1_signalout = filtfilt(sos_lbeta, class1_signal);
hbeta1_signalout = filtfilt(sos_hbeta, class1_signal);
gamma1_signalout = filtfilt(sos_gamma, class1_signal);

sos_theta = ss2sos(Atheta,Btheta,Ctheta,Dtheta);
fvt = fvtool(sos,bpfilter,'Fs',128);
legend(fvt,'cheby2','designfilt')