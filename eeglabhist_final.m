% EEGLAB history file generated on the 13-Apr-2022
% ------------------------------------------------

EEG.etc.eeglabvers = '2021.1'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_importdata('dataformat','array','nbchan',0,'data','eeg_class2','srate',128,'subject','S01','pnts',0,'xmin',0,'chanlocs','chanlocs_14.loc');
EEG.setname='final_history';
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',50,'plotfreqz',1);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 0, 1, 1);
figure; pop_spectopo(EEG, 0, [0      39382.8125], 'EEG' , 'freq', [10], 'plotchan', 0, 'percent', 20, 'icacomps', [1:14], 'nicamaps', 5, 'freqrange',[2 25],'electrodes','off');
