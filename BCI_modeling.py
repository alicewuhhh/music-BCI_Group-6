import numpy as np
import pandas as pd
import matplotlib.pyplot as plt  # plotting

# Functions from sklearn
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
from sklearn.ensemble import BaggingClassifier, RandomForestClassifier
from sklearn.multiclass import OneVsRestClassifier

df_orig = np.load("/Users/aliceqichaowu/Documents/GitHub/music-BCI_Group-6/dataset/training_data.npy")
np.shape(df_orig) ##first 80 is class 1, last 79 is class 2
df = df_orig.reshape([159,70*512])
class1=df[0:80,:]
class_1=class1.reshape([80*35840,1])
print(class_1.shape)
class2=df[80:None,:]
class_2=class2.reshape([79*35840,1])
print(class_2.shape)
X=np.concatenate((class_1, class_2), axis=0)
print(X.shape)

label_class_1=np.ones([2867200, 1])
label_class_2=2*np.ones([2831360, 1])
y=np.concatenate((label_class_1, label_class_2), axis=0)
# print(label_class_1[1:5,:],label_class_2[1:5,:])
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20, random_state=0)
print(X_train.shape,y_train.shape)

## feature normalization
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# print(X_test.shape)


#Create a SVM Classifier
# svm = svm.LinearSVC(kernel='linear') # Linear Kernel
svm = OneVsRestClassifier(SVC(kernel='linear', probability=True, class_weight='balanced'), n_jobs=-1)
#Train the model using the training sets
svm.fit(X_train, y_train.ravel())

#Predict the response for test dataset
y_pred = svm.predict(X_test)

from datetime import datetime as dt

start = dt.now()
# process stuff
running_secs = (dt.now() - start).seconds
msg = "Execution took: %s secs (Wall clock time)" % running_secs
print(msg)

from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.metrics import precision_score, recall_score, f1_score
## confusion matrix
print('Confusion matrix: [[tn fp]')
print('                   [fn tp]]')
print(confusion_matrix(y_test, y_pred))
print('The SVM Model Accuracy is ' + str(accuracy_score(y_test, y_pred)))

