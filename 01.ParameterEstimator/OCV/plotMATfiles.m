% Algorítimo OCV
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo aplicado neste projeto está protegido por direitos autorais
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
% Essa função lê o arquivo ".mat" gerado pela função makeMATfiles.m
% e plota graficamente as tensões geradas 

clear all; close all 

cellIDs = {'A123'}; % Identificadores para cada célula (neste caso apenas a A123 que foi utilizada no projeto)
order = [-25 -15 -5 5 15 25 35 45];             % Temperaturas de teste definidas 
% Nomes para os quatro scripts de teste diferentes
stepFields = {'script1','script2','script3','script4'};

for theID = 1:length(cellIDs),    % Loop varrendo todos os topos de célula (nesta aplicação só temos A123)
  data = [];                      % Inicializa a variável de dados vazia
  for theFile = 1:length(order),  % Loop varrendo todas as temperaturas (-25, -15, -5, 5, 15, 25, 35, 45)
    if order(theFile) < 0,        % se a temperatura for negativa, então
      OCVPrefix = sprintf('%s_OCV/%s_OCV_N%02d',... % procure por este arquivo (nomenclatura para temperaturas negativas)
        cellIDs{theID},cellIDs{theID},abs(order(theFile)));
    else                          % se a temperatura for positiva, então
      OCVPrefix = sprintf('%s_OCV/%s_OCV_P%02d',... % procure por este arquivo (nomenclatura para temperaturas positivas)
        cellIDs{theID},cellIDs{theID},order(theFile));
    end
    inFile = sprintf('%s.mat',OCVPrefix); % cria o nome do arquivo
    if ~exist(inFile,'file'),
      error(['File "%s" not found in current folder.\n' ...
        'Please change folders so that "%s" is in the current '...
        'folder and re-run plotMATfiles.'],inFile,inFile); % mensagem se erro
    end    
    load(inFile);                 % lê o arquivo

    figure                        % cria uma nova figura
    for theScript = 1:4,          % plota os dados de cada script
      subplot(2,2,theScript);
      data = OCVData.(stepFields{theScript});
      plot(data.time,data.current);
      xlabel('Tempo (s)')
      %ylabel('Tensão (V)') % comando utilizado quando plotamos a tensão
      %(V) no eixo y
      ylabel('Corrente (A)')
      title(sprintf('Teste OCV - parte %d',theScript),'interpreter','none');
      %title(sprintf('%s - step
      %%d',OCVPrefix,theScript),'interpreter','none'); % comando utilizado
      %%em outra plotagem
    end
  end
end