# Algorítimo RNA - Novos resultados com outros perfis de corrente
# Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
# Este algoritmo é de autoria do aluno Fábio Mori
###############################################################################
# Este algoritmo teve como base de desenvolvimento teve como base o 
# conhecimento adiquirido durante a realização das matérias:
# MITx - 6.00.1x
# Introduction to Computer Science and Programming Using Python
# MITx - 6.86x
# Machine Learning with Python-From Linear Models to Deep Learning
# IBM - DL0120EN
# Deep Learning with Tensorflow
# Todas estas matérias foram feitas pela plataforma edX
###############################################################################
# Rede Neural Artificial para estimar o SOC
# Baseado nos dados simulados em laboratório da célula A123
# Este código implementa a ede neural artificial profunda
# Dados de entrada: SOC estimado pelo SPKF e KPI dos dados UDDS
# Dado de saída: SOC estimado pela RNA

import _pickle as cPickle, gzip
import numpy as np
from tqdm import tqdm
import torch
import torch.autograd as autograd
import torch.nn.functional as F
import torch.nn as nn
import matplotlib.pyplot as plt
import sys
sys.path.append("..")
import utils
from utils import *
from train import batchify_data, run_epoch, train_model, spkf_parameters

def main():
    # Carregar os dados de treinamento e teste
    # X: SOC SPKF, KPI BA, KPI BR, KPI TA, KPI TR
    # Y: SOC REAL
    num_classes = 10
    X_train = np.loadtxt('../Datasets/x35.txt')
    y_train = np.loadtxt('../Datasets/y35.txt')
    X_test = np.loadtxt('../Datasets/calce30_x3.txt')
    y_test = np.loadtxt('../Datasets/calce30_y.txt')
    
##############################################################################  
    # Vetores do eixo x para plotar os gráficos
    time_train = len(y_train) + 1
    train = np.arange(1, time_train, 1)
    time_test = len(y_test) + 1
    test = np.arange(1, time_test, 1) 
    
 
    # Plotando os dados y de treinamento e teste de entrada da Rede Neural
    plt.plot(train, y_train, 'r', label='train')
    plt.plot(test, y_test, 'b', label='test')
    plt.title('Neural Networks Output')
    plt.ylabel('SOC')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
   
    # Plotando os dados X de treinamento de entrada da Rede Neural 
    plt.plot(train, X_train[:,0], 'b', label='train')
    plt.plot(train, X_train, 'b', label='train')
    plt.title('Neural Networks Input')
    plt.ylabel('SOC')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    plt.plot(train, X_train[:,1], 'r', label='Aggression train')
    plt.plot(train, X_train[:,2], 'b', label='Release train')
    plt.title('Neural Networks Input')
    plt.ylabel('Brake KPI')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    plt.plot(train, X_train[:,3], 'r', label='Aggression train')
    plt.plot(train, X_train[:,4], 'b', label='Release train')
    plt.title('Neural Networks Input')
    plt.ylabel('Throttle KPI')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    # Plotando os dados X de teste de entrada da Rede Neural     
    plt.plot(test, X_test[:,0], 'b', label='test')
    plt.title('Neural Networks Input')
    plt.ylabel('SOC')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    plt.plot(test, X_test[:,1], 'r', label='Aggression test')
    plt.plot(test, X_test[:,2], 'b', label='Release test')
    plt.title('Neural Networks Input')
    plt.ylabel('Brake KPI')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    plt.plot(test, X_test[:,3], 'r', label='Aggression test')
    plt.plot(test, X_test[:,4], 'b', label='Release test')
    plt.title('Neural Networks Input')
    plt.ylabel('Throttle KPI')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
##############################################################################

    # Dividir os dados de treinamento em validação (10%) e treinamento (90%)
    dev_split_index = int(9 * len(X_train) / 10)
    X_val = X_train[dev_split_index:]
    y_val = y_train[dev_split_index:]
    X_train = X_train[:dev_split_index]
    y_train = y_train[:dev_split_index]
    
    # Randomizar os dados de treinamento para inserir na rede
#    permutation = np.array([i for i in range(len(X_train))])    
#    np.random.shuffle(permutation)                            #MODIFICAR
#    X_train = [X_train[i] for i in permutation]             
#    y_train = [y_train[i] for i in permutation]           
    
    # Dividindo os dados em batches para o treinamento
    batch_size_train = 128
    batch_size_test = 1                                         
    train_batches = batchify_data(X_train, y_train, batch_size_train)
    val_batches = batchify_data(X_val, y_val, batch_size_train)
    test_batches = batchify_data(X_test, y_test, batch_size_test) 


##############################################################################
    # Definindo modelo sequencial da Rede Neural Artifical Profunda
    model = nn.Sequential(
               nn.Linear(5, 100),
               nn.Hardtanh(),      
               nn.Linear(100, 100),     # camada oculta 1
               nn.Hardtanh(),      
               nn.Linear(100, 1),
            )
    lr=0.1
    momentum=0
##############################################################################

    # Treinando o modelo com os batches de validação e treinamento no modelo
    train_model(train_batches, val_batches, model, lr=lr, momentum=momentum)
    
    # Validando o modelo com os dados de teste UDDS A123 a 25°C
    # Calculando loss, error, accuracy e SOC estimado do modelo
    loss, accuracy, error, sochat = run_epoch(test_batches, model.eval(), None)
    print ("Loss on test set:"  + str(loss) + " Accuracy on test set: " + str(accuracy))
    
    loss_spkf, accuracy_spkf, error_spkf = spkf_parameters(X_test[:,0], y_test)
    print ("Loss on SPKF set:"  + str(loss_spkf) + " Accuracy on SPKF set: " + str(accuracy_spkf))

    sochat = np.concatenate( sochat, axis=0 )
##############################################################################    
   # Plotando os resultados da Rede Neural Artificial Profunda 
    plt.plot(range(len(error)), error)
    plt.ylabel('Loss Function')
    plt.xlabel('Iteration number')
    plt.show()
    
    plt.plot(range(len(error)), sochat)
    plt.ylabel('SOC Function')
    plt.xlabel('Iteration number')
    plt.show()
    
    #plt.plot(range(len(test)), y_test, 'r', label='Real SOC')
    plt.plot(range(len(y_test)), y_test, 'r', label='Real SOC')
    #plt.plot(range(len(test)), sochat, 'b', label='ANN SOC Estimator')
    plt.plot(range(len(sochat)), sochat, 'b', label='ANN SOC Estimator')
    #plt.plot(range(len(test)), X_test[:,0], 'g', label='SPKF SOC Estimator')
    #plt.plot(range(len(y_test)), X_test[:,0], 'g', label='SPKF SOC Estimator')
    
    plt.title('Neural Networks Output')
    plt.ylabel('SOC')
    plt.xlabel('time')
    plt.legend(framealpha=1, frameon=True);
    plt.show()
    
    plt.plot(range(len(error)), sochat)
    plt.ylabel('SOC Function')
    plt.xlabel('Iteration number')
    plt.show()   
############################################################################## 
    
if __name__ == '__main__':
    # Especifique o "seed" para o comportamento determinístico e, em seguida, embaralhe.
    np.random.seed(12321)  # para reprodutibilidade
    torch.manual_seed(12321)  # para reprodutibilidade
    main()
