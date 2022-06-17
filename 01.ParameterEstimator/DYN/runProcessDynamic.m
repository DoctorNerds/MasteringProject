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
% -------------------------------------------------------------------------
% script runProcessDynamic
%
% RUNPROCESSDYNAMIC: lê os arquivos de dados correspondentes aos testes
% dinêmicos da célula, executa PROCESSDYNAMIC e então salva o resultado
% do modelo ESC. Ele se baseia no SETUPDYNDATA para fornecer a lista de 
% dados a ser processados


close all
setupDynData; % obtém a lista de dados a serem processados
numpoles = 1; % número de pares R-C no modelo final

for indID = 1:length(cellIDs), % Loop varrendo todos os tipos de célula (nesta aplicação só temos A123)
  cellID = cellIDs{indID};     % obtém a célula identidicada
  
  % Leia o arquivo OCV, previamente processado pelo runProcessOCV
  modelFile = sprintf('../OCV/%smodel-ocv.mat',cellID);
  if ~exist(modelFile,'file'),
    error(['File "%s" not found.\n' ...
      'Please change folders so that "%s" points to a valid model '...
      'file and re-run runProcessDynamic.'],modelFile,modelFile); 
  end
  load(modelFile);
  
  % Leia o arquivo de dados MAT
  data = zeros([0 length(mags{indID} > 0)]); dataInd = 0;
  for indTemps = 1:length(mags{indID}), % leia todas as temperaturas
    theMag = mags{indID}(indTemps);     % máxima taxa-C no arquivo de dados * 10
    if theMag < 0,                      % omita esses arquivos de dados
      continue 
    else                                % armazene estes dados em "data"
      dataInd = dataInd + 1;
    end
    if temps(indTemps) < 0, % se a temperatura for negativa, então
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_N%02d',... % nomenclatura para temperaturas negativas
        cellID,cellID,theMag,abs(temps(indTemps)));
    else                    % se a temperatura for positiva, então
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_P%02d',... % nomenclatura para temperaturas positivas
        cellID,cellID,theMag,temps(indTemps));
    end
    inFile = sprintf('%s.mat',DYNPrefix);
    if ~exist(inFile,'file'),
      error(['File "%s" not found.\n' ...
        'Please change folders so that "%s" points to a valid data '...
        'file and re-run runProcessDynamic.'],inFile,inFile); 
    end
    fprintf('Loading %s\n',inFile); load(inFile);        
    data(dataInd).temp    = temps(indTemps); % armazena temperatura
    data(dataInd).script1 = DYNData.script1; % armazena os dados de cada
    data(dataInd).script2 = DYNData.script2; % um dos três scripts
    data(dataInd).script3 = DYNData.script3;
  end
  
  model = processDynamic(data,model,numpoles,1); % faz o "heavy lifting"
  modelFile = sprintf('%smodel.mat',cellID); % salva o modelo otimizado
  save(modelFile,'model');                   % neste arquivo
  
  % Plota os resultados de tensão do modelo à 25°C, mais o erro RMS de 
  % estimação de tensão entre 5% e 95% de SOC da célula
  figure(10+indID);
  indTemps = find(temps == 25);
  [vk,rck,hk,zk,sik,OCV] = simCell(data(indTemps).script1.current,...
    temps(indTemps),1,model,1,zeros(numpoles,1),0);
  tk = (1:length(data(indTemps).script1.current))-1;
  plot(tk,data(indTemps).script1.voltage,tk,vk);
  verr = data(indTemps).script1.voltage - vk';
  v1 = OCVfromSOCtemp(0.95,temps(indTemps),model);
  v2 = OCVfromSOCtemp(0.05,temps(indTemps),model);
  N1 = find(data(indTemps).script1.voltage<v1,1,'first'); 
  N2 = find(data(indTemps).script1.voltage<v2,1,'first');
  if isempty(N1), N1=1; end; if isempty(N2), N2=length(verr); end
  rmserr=sqrt(mean(verr(N1:N2).^2));
  fprintf('RMS error of simCell @ 25 degC = %0.2f (mv)\n',rmserr*1000);
end