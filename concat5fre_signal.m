%%load 3-class 5-frequency 14-channel data
alpha1_signal=load('alpha1_signalout.mat');
alpha2_signal=load('alpha2_signalout.mat');
alpha3_signal=load('alpha3_signalout.mat');

theta1_signal=load('theta1_signalout.mat');
theta2_signal=load('theta2_signalout.mat');
theta3_signal=load('theta3_signalout.mat');

lbeta1_signal=load('lbeta1_signalout.mat');
lbeta2_signal=load('lbeta2_signalout.mat');
lbeta3_signal=load('lbeta3_signalout.mat');

hbeta1_signal=load('hbeta1_signalout.mat');
hbeta2_signal=load('hbeta2_signalout.mat');
hbeta3_signal=load('hbeta3_signalout.mat');

gamma1_signal=load('gamma1_signalout.mat');
gamma2_signal=load('gamma2_signalout.mat');
gamma3_signal=load('gamma3_signalout.mat');

class1_concat = zeros(length(alpha1_signalout)*5,512);
class2_concat = zeros(length(alpha2_signalout)*5,512);
class3_concat = zeros(length(alpha3_signalout)*5,512);

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