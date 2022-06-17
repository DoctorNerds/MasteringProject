% Algorítimo DYN
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

close all

% Chama a função "setupDynData.m"
setupDynData
% Nomes para os três scripts de teste diferentes
stepFields = {'script1','script2','script3'}; % 

for indID = 1:length(cellIDs), % Loop varrendo todos os topos de célula (nesta aplicação só temos A123)
  cellID = cellIDs{indID};

  % Lê os arquivos de dados
  data = zeros([0 length(mags{indID} > 0)]); dataInd = 0;
  for indTemps = 1:length(mags{indID}), % loop varrendo todas as temperaturas (-25, -15, -5, 5, 15, 25, 35, 45)
    theMag = mags{indID}(indTemps);     % se não existir dados, pule
    if theMag < 0, 
      continue 
    else                                
      dataInd = dataInd + 1;
    end
    if temps(indTemps) < 0,             % se a temperatura for negativa, então
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_N%02d',... % nomenclatura para temperaturas negativas
        cellID,cellID,theMag,abs(temps(indTemps)));
    else                                % se a temperatura for positiva, então
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_P%02d',... % pnomenclatura para temperaturas positivas
        cellID,cellID,theMag,temps(indTemps));
    end
    inFile = sprintf('%s.mat',DYNPrefix); % cria o nome do arquivo
    if ~exist(inFile,'file'),
      error(['File "%s" not found in current folder.\n' ...
        'Please change folders so that "%s" is in the current '...
        'folder and re-run plotMATfiles.'],inFile,inFile); 
    end    
    fprintf('Loading %s\n',inFile); load(inFile);  % mensagem na tela      

    figure % cria uma nova figura
    for theScript = 1:3, % plota os dados de cada script
      subplot(1,3,theScript);
      data = DYNData.(stepFields{theScript});
      t = (data.time - data.time(1))/3600;
      plot(t,data.voltage); % plota o gráfico da tensão para cada script
      xlabel('Tempo (s)')
      %ylabel('Corrente (A)') % legenda para quando plotamos a corrente
      ylabel('Tensão (V)')
      title(sprintf('Teste DYN - parte %d',theScript),'interpreter','none');
      %title(sprintf('%s - step %d',DYNPrefix,theScript),'interpreter','none');
    end
  end
end