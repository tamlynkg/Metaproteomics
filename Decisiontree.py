import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

import warnings
warnings.filterwarnings('ignore')

from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.compose import ColumnTransformer

from sklearn.metrics import confusion_matrix, plot_confusion_matrix, accuracy_score, precision_score, recall_score, f1_score
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import OneHotEncoder, StandardScaler

from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import export_graphviz 
from sklearn.ensemble import ExtraTreesClassifier, BaggingClassifier, RandomForestClassifier,\
AdaBoostClassifier, GradientBoostingClassifier
import xgboost as xgb

def evaluation(y, y_hat, title = 'Confusion Matrix'):
    '''Takes in true and predicted values.
    The function prints out a classifcation report
    and a confusion matrix using seaborn's heatmap.
    The function will also print the recall, accuracy,
    precision, and f1 scores.'''
    cm = confusion_matrix(y, y_hat)
    precision = precision_score(y, y_hat)
    recall = recall_score(y, y_hat)
    accuracy = accuracy_score(y,y_hat)
    f1 = f1_score(y,y_hat)
    print('Recall: ', recall)
    print('Accuracy: ', accuracy)
    print('Precision: ', precision)
    print('F1: ', f1)
    print('\n')
    sns.heatmap(cm,  cmap= 'PuBu', annot=True, fmt='g', annot_kws=    {'size':20})
    plt.xlabel('predicted', fontsize=18)
    plt.ylabel('actual', fontsize=18)
    plt.title(title, fontsize=18)


df = pd.read_csv("v2_BV_proteins.csv")
df.head()

#Defining predictor and target features
X = df.drop(['BV_Status'], axis=1)
y = df.BV_Status

#Performing train test split
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)

#Defining numerical features for the StandardScaler
numerical = ['A0A067N8J8', 'A0A068EIT1', 'A0A068SI01','A0A177DGX3', 'A0A0B2UN42', 'A0A0C3C8H3', 'A0A0C3J1M2', 'A0A0D1CPW1', 'A0A0J0XQ73', 'A0A0K6GHA6', 'A0A0W7VM77', 'A0A137P973', 'A0A165KVL8', 'A0A178DXV7', 'A0A1B0SZV4', 'A0A1D8PFR4', 'B9WAZ4', 'A0A1I9WQJ7', 'A0A1V6RS99', 'A0A1X2H1E3', 'A0A1Y1W0Z6', 'A0A1Y1YSW4', 'A0A1Y2CHJ5', 'A0A1Y2GNC9', 'A0A2P4Z6X1', 'A0A2P4ZZC8', 'A5E2Z2', 'B3FE91', 'B6JZZ7', 'B6Q4U4', 'B6Q757', 'B7XNL8', 'C4XYH4', 'C4Y881', 'C6GJC9', 'P0CN98', 'G8ZUB2', 'H8WXM9', 'I4Y633', 'R9APA2', 'I4YD25', 'J7M8M3', 'K1W4Z9', 'M5EKD5', 'W0T5M8', 'S9VSV5', 'S9XAK4', 'U1I2V7', 'W3VSG0']
#Defining categorical features for the OneHotEncoder

#Instantiating Standard Scaler and OneHotEncoder pipelines
ss = Pipeline(steps=[('ss', StandardScaler())])


#Creating a preprocess column transformer to perform the scaling and encoding
preprocess = ColumnTransformer(
                    transformers=[
                        ('cont', ss, numerical),
                    ])

#Creating Pipeline with preprocess column transformer and a Decision Tree Classifier
dtree_pipe = Pipeline(steps=[
    ('preprocess', preprocess),
    ('classifier', DecisionTreeClassifier())
])


#Fitting the pipeline to the train split
dtree_pipe.fit(X_train, y_train)


train_acc = accuracy_score(y_train, dtree_pipe.predict(X_train))
test_acc = accuracy_score(y_test, dtree_pipe.predict(X_test))

print('Train Accuracy: {}'.format(train_acc))
print('Test Accuracy: {}'.format(test_acc))
print('\n')
evaluation(y_test, dtree_pipe.predict(X_test))
plt.show()


pred = dtree_pipe.predict(X_test)
#(y_test == 1) == (pred == 0)

false_positives = np.logical_and(y_test != pred, pred == 1)

X_test[false_positives]

#false_negatives = np.logical_and(y_test != pred, pred == 0)

#X_test[false_negatives]

export_graphviz(d, out_file ='tree.dot',
               feature_names =['BV.Status'])
