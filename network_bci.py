from __future__ import print_function
import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim
from torch.utils import data
# from torchvision import datasets, transforms
from torch.autograd import Variable
import time
import numpy as np
import os
from copy import deepcopy
from itertools import chain
from sklearn.model_selection import train_test_split


class Net(nn.Module):
    def __init__(self, num_classes, hidden_size, num_layers, middle_feature):
        super(Net, self).__init__()
        self.num_classes = num_classes
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.bidirectional = True
        self.middle_feature = middle_feature

        self.embedding = nn.Sequential(
            nn.Conv2d(1, 2, kernel_size=(3, 1), padding=(1, 0), stride=1),
            nn.ReLU(),
            nn.Conv2d(2, 4, kernel_size=(3, 1), padding=(1, 0), stride=1),
            nn.ReLU())

        self.embedding_dim = 129 * 4

        self.BiLSTM = nn.LSTM(input_size=self.embedding_dim,
                              hidden_size=self.hidden_size,
                              num_layers=self.num_layers,
                              dropout=0.2,
                              bidirectional=self.bidirectional)

        self.MLP = nn.Sequential(
            nn.Linear(self.hidden_size, self.middle_feature),
            nn.ReLU(),
            nn.Linear(self.middle_feature, num_classes)
        )

    def forward(self, datas):
        batch, t, f = datas.shape
        print('input:', batch, f, t)
        datas = datas.view(batch, 1, f, t)
        print('reshape:', datas.size())
        embedded_datas = self.embedding(datas)
        print('after conv:', embedded_datas.size())
        embedded_datas = embedded_datas.permute(3, 0, 1, 2).view(t, batch, -1)
        print('before lstm:', embedded_datas.size())
        out, _ = self.BiLSTM(embedded_datas)
        # print('after lstm:',out.size())
        # out, _ =pad_packed_sequence(out)
        # out = out[-1,:,:]
        print('reshape:', out.size())
        out = self.MLP(out)
        return out


class Netone(nn.Module):
    def __init__(self, num_classes, hidden_size, num_layers, middle_feature):
        super(Netone, self).__init__()
        self.num_classes = num_classes
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.bidirectional = True
        self.middle_feature = middle_feature
        self.embedding_dim = 128
        inputsize = 512

        # self.embedding = nn.Sequential(
        #     nn.Conv2d(1, 2, kernel_size=(128, 1), padding=0, stride=(4,1)),
        #     # nn.Conv1d(70, 256, kernel_size=1, stride=1),
        #     nn.LeakyReLU(),
        #     # nn.Conv1d(256, 512, kernel_size=1, stride=1),
        #     nn.Conv2d(2, 4, kernel_size=(2, 1), padding=0, stride=1),
        #     nn.LeakyReLU())
        self.embedding = nn.Sequential(
            nn.Conv1d(inputsize, 4 * inputsize, kernel_size=1, padding=0),
            nn.BatchNorm1d(4 * inputsize, eps=1e-6),
            nn.LeakyReLU(),
            nn.Conv1d(4 * inputsize, self.embedding_dim, kernel_size=1, padding=0),
            nn.BatchNorm1d(self.embedding_dim, eps=1e-6),
            nn.LeakyReLU())

        # self.embedding_dim = 1281
        # self.embedding_dim = 256
        # h0 = 256 num_layers = 1

        self.BiLSTM = nn.LSTM(input_size=self.embedding_dim,
                              hidden_size=self.hidden_size,
                              num_layers=self.num_layers,
                              dropout=0.2,
                              batch_first= True,
                              bidirectional=self.bidirectional)

        self.MLP = nn.Sequential(
            nn.Linear(self.hidden_size*2, self.middle_feature),
            nn.ReLU(),
            nn.Linear(self.middle_feature, num_classes)
        )  # remove the mlp and generate the irritation state at each time step
        # self.classification = nn.Sequential(
        #     nn.Linear(256, 2048),
        #     nn.LeakyReLU(),
        #     nn.Linear(2048, num_classes))
        # self.classification = nn.Linear(512, 41)
        self.lsm = nn.LogSoftmax(dim=2)

    def forward(self, datas):
        batch, f, t = datas.shape
        # print('input:', batch, f, t)  # data = [batch, 1281, 54] overall patient data = [5746, 1281, 54]
        # embedded_datas = datas.view(t,batch,f)#t,batch,f
        # datas = datas.view(batch, 1, t, f)  # [N, C, H, W]
        datas = datas.permute(0, 2, 1)
        embedded_datas = self.embedding(datas)
        # print('after conv:', embedded_datas.size())  # [20, 4, 54, 1281]
        # embedded_datas = embedded_datas.reshape(batch, -1, f*4)
        # print('before lstm:', embedded_datas.size())
        out, _ = self.BiLSTM(embedded_datas.permute(0, 2, 1))
        # print('after lstm:', out.size())
        # out, _ =pad_packed_sequence(out)
        # out = out[-1, :, :]  # 20,512
        # out = out.view(out.shape[1],out.shape[0],out.shape[2])
        # out = self.MLP(out)
        # out = self.classification(embedded_datas)
        # print('after classification:', out.size())
        # out = self.lsm(out)
        # print('after logsoftmax:', out.size())
        flatten = nn.Flatten()
        # print(flatten(out).size())
        out = flatten(out)
        classification = nn.Linear(out.shape[1], 2)
        out = classification(out)

        return out