concat1=load('P05_class1_concat.mat');
concat2=load('P05_class2_concat.mat');
concat3=load('P05_class3_concat.mat');

P05_class1_feats = zeros(length(class1_concat),512);
P05_class3_feats = zeros(length(class3_concat),512);

%% baseline vector construction
step = 70;
baseline = zeros(70,512);
for i=1:length(class2_concat)/step
   baseline = baseline + class2_concat(((i-1)*step + 1):((i-1)*step + step),:);
end
baseline = baseline/i;

%% standarization
for j=1:length(class1_concat)/step
    P05_class1_feats(((j-1)*step + 1):((j-1)*step + step),:) = class1_concat(((j-1)*step + 1):((j-1)*step + step),:) - baseline;
end
for k=1:length(class3_concat)/step
    P05_class3_feats(((k-1)*step + 1):((k-1)*step + step),:) = class3_concat(((k-1)*step + 1):((k-1)*step + step),:) - baseline;
end
