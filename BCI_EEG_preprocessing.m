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
