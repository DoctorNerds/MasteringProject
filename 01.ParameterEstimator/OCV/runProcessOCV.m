% Algor�timo OCV
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo aplicado neste projeto est� protegido por direitos autorais
% de Gregory L. Plett:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2015 by Gregory L. Plett of the University of Colorado 
% Colorado Springs (UCCS). This work is licensed under a Creative Commons 
% Attribution-NonCommercial-ShareAlike 4.0 Intl. License, v. 1.0.
% It is provided "as is", without express or implied warranty, for 
% educational and informational purposes only.
% This file is provided as a supplement to: Plett, Gregory L., "Battery
% Management Systems, Volume I, Battery Modeling," Artech House, 2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   runProcessOCV:
%   O objetivo deste script � ler os dados dos testes em laborat�rio OCV
%   feitos para a c�lula A123 em v�rias temperaturas diferentes e chama a
%   fun��o "processOCV.m" para criar a rela��o OCV e ent�o salva o modelo
%   em um arquivo

clear all
cellIDs = {'A123'}; % Identifica��o da c�lula A123
temps = {[-25 -15 -5 5 15 25 35 45]}; % Temperaturas de cada teste
% tens�o m�xima e m�nima de cada c�lula, usado para plotar os resultados       
minV = [2.00];
maxV = [3.75];

% --------------------------------------------------------------------
% Carrega e processa os dados de teste
% --------------------------------------------------------------------
for theID = 1:length(cellIDs), % Loop varrendo todos os topos de c�lula (nesta aplica��o s� temos A123)
  dirname = cellIDs{theID}; cellID = dirname;
  ind = find(dirname == '_'); % l�gica para se houver um "_", excluir
  if ~isempty(ind), dirname = dirname(1:ind-1); end
  OCVDir = sprintf('%s_OCV',dirname); % local onde vamos encontrar os arquivos
  if ~exist(OCVDir,'dir'),
    error(['Folder "%s" not found in current folder.\n' ...
      'Please change folders so that "%s" is in the current '...
      'folder and re-run runProcessOCV.'],OCVDir,OCVDir); 
  end
  
  filetemps = temps{theID}(:);  % arquivos de cada temperatura
  numtemps = length(filetemps); % n�mero de conjunto de dados
  data = zeros([0 numtemps]);   % Inicializa a vari�vel de dados vazia

  for k = 1:numtemps,           % Loop varrendo todas as temperaturas (-25, -15, -5, 5, 15, 25, 35, 45)
    if filetemps(k) < 0,        % se a temperatura for negativa, ent�o
      filename = sprintf('%s/%s_OCV_N%02d.mat',... % procure por este arquivo (nomenclatura para temperaturas negativas)
        OCVDir,cellID,abs(filetemps(k)));
    else                        % se a temperatura for positiva, ent�o
      filename = sprintf('%s/%s_OCV_P%02d.mat',... % procure por este arquivo (nomenclatura para temperaturas positivas)
        OCVDir,cellID,filetemps(k));
    end
    load(filename);             % Leia o arquivo de dados OCV
    data(k).temp = filetemps(k);       % salvando a temperatura de teste
    data(k).script1 = OCVData.script1; % salvando os 4 scripts
    data(k).script2 = OCVData.script2;
    data(k).script3 = OCVData.script3;
    data(k).script4 = OCVData.script4;
  end
  
  % chamando a fun��o "processOCV" para fazer o processamento dos dados
  model = processOCV(data,cellID,minV(theID),maxV(theID),1);
  save(sprintf('%smodel-ocv.mat',cellID),'model'); % salvando o arquivo
end