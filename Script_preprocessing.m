%EEGLAB scripts
%load('data_all_participants.mat')
S01=load('P01_S01_calibration.mat');
S02=load('P01_S02_calibration.mat');

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



