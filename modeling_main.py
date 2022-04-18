from dataloader import *
from model_bci import *
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim
from torch.utils import data
from torch.autograd import Variable
from util import *
from sklearn.model_selection import train_test_split
from tqdm import tqdm
import pandas as pd
#data_path,100,256,0,100

# def save_model(path, epoch, model, optimizer):
#     ckpt = {
#     "epoch" : epoch,
#     "model_state_dict" : model.state_dict(),
#     "optimizer_state_dict" : optimizer.state_dict(),
#     # "scheduler_state_dict" : scheduler.state_dict(),
#     }
#     print("saving model to:", path)
#     torch.save(ckpt,path)
data_path = '/Users/jiesun/Desktop/EMGclassification/pycode/deeplearning/irr_code/training_data.npy'
label_path = '/Users/jiesun/Desktop/EMGclassification/pycode/deeplearning/irr_code/modeling_label.npy'

data = np.load(data_path)
print(data.shape)
label = np.load(label_path,allow_pickle=True)
print(label.shape)

train,val,label_train,label_val = train_test_split(data,label,test_size = 0.15,random_state = 42)
train = torch.from_numpy(train)
print("instances number:", train.shape)
val = torch.from_numpy(val)
print("val instances number:", val.shape)
label_train = torch.from_numpy(label_train)
print("train_length_shape:", label_train.shape)
train_length = label_train.shape[0]
label_val = torch.from_numpy(label_val)
print("val_length_shape:", label_val.shape)
val_length = label_val.shape[0]

params = {'batch_size': 5,'shuffle': False}
trainset = torch.utils.data.TensorDataset(train,label_train)
valset = torch.utils.data.TensorDataset(val,label_val)
# data loader
train_loader = torch.utils.data.DataLoader(trainset,**params)
val_loader = torch.utils.data.DataLoader(valset,**params)
# print("length of train_loader:{}\n length of train_length:{} " .format(len(train_loader), train_length))
# input is added with window
input_size = 129
#set hidden size
hidden_size = 128
n_class = 2
learning_rate = 0.01
max_epochs = 100
middle_features = 128
model = Netone(num_classes = n_class,hidden_size = hidden_size,num_layers = 1,middle_feature = middle_features) #num_classes, hidden_size, num_layers, bidirectional, middle_feature
#model.cuda()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters())

# checkpoint = torch.load('/Users/jiesun/Desktop/EMGclassification/04-11-ai0501-irr-classification/cnn_lstm_irr_ep49.pt')
# epoch = checkpoint['epoch']
# model.load_state_dict(checkpoint['model_state_dict'])
# optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
# scheduler.load_state_dict(checkpoint['scheduler_state_dict'])

for epoch in range(max_epochs):
    correct_all = 0
    train_acc = []
    # loss_all = []
    total_loss = 0
    # batch_bar = tqdm(total=len(train_loader), dynamic_ncols=True, leave=False, position=0, desc='Train')

    for batch_idx, (batch_x, batch_y) in enumerate(tqdm(train_loader)):
        batch_x = Variable(batch_x.float())#.cuda()
        batch_y = batch_y.long()

        optimizer.zero_grad()
        output = model(batch_x)#,hidden = model(batch_x,None)
        # print("output of the model.shape: ", output.shape)
        _, predicted_train = torch.max(output.data, 1)
        # print("predicted label.shape", predicted_train.shape)
        # print(predicted_train)-[batch, 1] output.data-[batch, 7]probability
        # if predicted_train.shape[0] == batch_y.shape[0]:
        # print("length of predicted:", len(predicted_train))
        # print("length of batch_label:", len(batch_y))
        for i in range(len(predicted_train)):
            # print(batch_y[0,i,0])
            if predicted_train[i] == batch_y[i, 0]:
                correct_all += 1
        #     else:
        #         print("prediction:", predicted_train[i])
        #         print("label:", batch_y[i, 0])
        # print("num of correct predictions", correct_all)
        train_acc.append(correct_all / train_length)
        loss = criterion(output,batch_y.squeeze())#.float().reshape(-1, 1)
        # loss_all.append(loss.data.item())
        total_loss += loss

        loss.backward()
        optimizer.step()

    print('***********************************')
    print("Epoch {}/{}:, Train Loss {:.04f}, Learning Rate {:.04f}".format(
        epoch+1,
        max_epochs,
        float(total_loss / len(train_loader)),
        float(optimizer.param_groups[0]['lr'])))
    # print('Epoch:',(epoch+1, max_epochs))
    print('train_acc:',correct_all/train_length)
    # batch_bar.update()

    if epoch%1 == 0:
        # eval()
        num_correct = 0
        val_acc = []
        for batch_idx, (batch_x, batch_y) in enumerate(tqdm(val_loader)):
            batch_x = Variable(batch_x.float())
            batch_y = batch_y.long()
            # with torch.cuda.amp.autocast():
            output = model(batch_x)
            _, predicted_train = torch.max(output.data, 1)
            # num_correct += int((torch.argmax(out_1, axis=1) == y1).sum())
            for i in range(len(predicted_train)):
                # print(batch_y[0,i,0])
                if predicted_train[i] == batch_y[i, 0]:
                    num_correct += 1
                # else:
                    # print("prediction:", predicted_train[i])
                    # print("label:", batch_y[i, 0])
        val_acc.append([epoch, num_correct / val_length])
        print('val_acc:', num_correct / val_length)

    # batch_bar.close()

    # path = '/Users/jiesun/Desktop/EMGclassification/04-11-ai0501-irr-classification/cnn_lstm_irr_ep' + str(epoch) + ".pt"
    # save_model(path, epoch, model, optimizer)
#
# name = ['epoch', 'val_acc']
# test = pd.DataFrame(columns=name, data=val_acc)
# test.to_csv('/Users/jiesun/Desktop/EMGclassification/04-11-ai0501-irr-classification/val_acc.csv', encoding='gbk')
# val_acc.to_csv('/Users/jiesun/Desktop/EMGclassification/04-11-ai0501-irr-classification/val_acc.csv')
