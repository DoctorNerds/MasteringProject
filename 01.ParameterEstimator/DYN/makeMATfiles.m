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
% makeMATfiles:
% O objetivo deste script é transformar os dados do Excel da célula A123
% escolhida e transformá-los em arquivos ".mat" para facilitar sua
% utilização

setupDynData; % chama esta função para obter a lista de arquivos a serem processados
% Cabeçalhos de coluna do Excel para procurar e converter para ".mat"
headers = {'Test_Time(s)','Step_Index','Current(A)','Voltage(V)',...
           'Charge_Capacity(Ah)','Discharge_Capacity(Ah)'};
% Cabeçalhos de coluna MATLAB correspondentes do arquivo Excel         
finFields = {'time','step','current','voltage','chgAh','disAh'};
% Nomes para os scripts de teste
stepFields = {'script1','script2'};
% Defina skipDone como "1" para pular o processamento se o arquivo ".mat" 
% já existir ou "0" para reprocessar o arquivo
skipDone = 0;

for indID = 1:length(cellIDs),      % Loop varrendo todos os tipos de célula (nesta aplicação só temos A123)
  for indTemps = 1:length(temps),   % Loop varrendo todas as temperaturas (-25, -15, -5, 5, 15, 25, 35, 45)
    if indTemps > length(mags{indID}), break, end % pule se não houver dados
    theMag = mags{indID}(indTemps); % taxa C relativa do arquivo de dados
    if theMag < 0, continue, end    % pule se não houver dados
    data = [];                      % limpe a estrutura de dados
    if temps(indTemps) < 0, % Use este nome de arquivo para temperaturas negativas
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_N%02d',...
        cellIDs{indID},cellIDs{indID},theMag,abs(temps(indTemps)));
    else                    % Use este nome de arquivo para temperaturas positivas
      DYNPrefix = sprintf('%s_DYN/%s_DYN_%02d_P%02d',...
        cellIDs{indID},cellIDs{indID},theMag,temps(indTemps));
    end
    OUTFile = sprintf('%s.mat',DYNPrefix); % nome do arquivo de saída
    if exist(OUTFile,'file') && skipDone, 
      fprintf('Skipping %s: already done\n',OUTFile); 
      continue
    end
    DYNFile1 = sprintf('%s_S1.xlsx',DYNPrefix); % arquivo de entrada, script 1
    DYNFile2 = sprintf('%s_S2.xlsx',DYNPrefix); % arquivo de entrada, script 2
    if ~exist(DYNFile1,'file'), 
      fprintf('Skipping %s: Missing source data\n',DYNFile1); 
      continue
    end
    if ~exist(DYNFile2,'file'), 
      fprintf('Skipping %s: Missing source data\n',DYNFile2); 
      continue
    end
      
    for theScript = 1:2, % processando ambos os scripts
      scriptData = [];   % limpando a estrutura de dados para o script
      for theField = 1:length(finFields), % inicializando os campos de saída
        scriptData.(finFields{theField}) = [];
      end

      DYNFile = sprintf('%s_S%d.xlsx',DYNPrefix,theScript); 
      [~,sheets] = xlsfinfo(DYNFile); % obtendo os nomes da planilha
      fprintf('Reading %s\n',DYNFile); 
      for theSheet = 1:length(sheets), % processando todas as planilhas
        if strcmp(sheets{theSheet},'Info'), continue; end % exceto "Info"
        fprintf('  Processing sheet %s\n',sheets{theSheet});
        [num,txt,raw] = xlsread(DYNFile,sheets{theSheet}); % lendo os dados
        for theHead = 1:length(headers), % selecionando os dados desejados
          ind = strcmp(txt,headers{theHead}); % armazenando os dados
          scriptData.(finFields{theHead}) = ... 
            [scriptData.(finFields{theHead}); num(:,ind == 1)];
        end
      end
      DYNData.(stepFields{theScript}) = scriptData; % salvando os dados
    end 

    % Fazendo um processo de interpolação mais rápido
    ind = find(diff(DYNData.script1.time)<=0); 
    DYNData.script1.time(ind+1)=[];              
    DYNData.script1.voltage(ind+1)=[];          
    DYNData.script1.current(ind+1)=[]; 
    DYNData.script1.chgAh(ind+1)=[];
    DYNData.script1.disAh(ind+1)=[];
    DYNData.script1.step(ind+1)=[];

    % Interpolando dados medidos brutos em incrementos de 1 s
    ind = find(DYNData.script1.step == 2,1); % mantém o step 2 e os últimos 300s do step 1 
    t1=DYNData.script1.time(ind) - 300; t2=DYNData.script1.time(end); 
    DYNData.script1.current = -interp1(DYNData.script1.time,... 
      DYNData.script1.current,t1:t2,'linear'); % 1-s i(t)
    DYNData.script1.voltage = interp1(DYNData.script1.time,...
      DYNData.script1.voltage,t1:t2,'linear'); % 1-s v(t)
    DYNData.script1.chgAh = interp1(DYNData.script1.time,...
      DYNData.script1.chgAh,t1:t2,'linear'); % 1-s v(t)
    DYNData.script1.disAh = interp1(DYNData.script1.time,...
      DYNData.script1.disAh,t1:t2,'linear'); % 1-s v(t)
    DYNData.script1.step = interp1(DYNData.script1.time,...
      DYNData.script1.step,t1:t2,'nearest'); % 1-s v(t)
    DYNData.script1.time = t1:t2;

    % O mesmo para os dados do script 2
    ind = find(diff(DYNData.script2.time)<=0); 
    DYNData.script2.time(ind+1)=[];    
    DYNData.script2.voltage(ind+1)=[]; 
    DYNData.script2.current(ind+1)=[]; 
    DYNData.script2.chgAh(ind+1)=[];
    DYNData.script2.disAh(ind+1)=[];
    DYNData.script2.step(ind+1)=[];
    t1=DYNData.script2.time(1); t2=DYNData.script2.time(end);    
    DYNData.script2.current = -interp1(DYNData.script2.time,...
      DYNData.script2.current,t1:t2,'linear'); % 1-s i(t)
    DYNData.script2.voltage = interp1(DYNData.script2.time,...
      DYNData.script2.voltage,t1:t2,'linear'); % 1-s v(t)
    DYNData.script2.chgAh = interp1(DYNData.script2.time,...
      DYNData.script2.chgAh,t1:t2,'linear'); % 1-s v(t)
    DYNData.script2.disAh = interp1(DYNData.script2.time,...
      DYNData.script2.disAh,t1:t2,'linear'); % 1-s v(t)
    DYNData.script2.step = interp1(DYNData.script2.time,...
      DYNData.script2.step,t1:t2,'nearest'); % 1-s v(t)
    DYNData.script2.time = t1:t2;

    % Dividindo o step 2 em duas partes
    % Procure o período mais longo de carga e divida exatamente antes disso
    % flagI é 0 se descarregando ou "step" se carregando
    flagI = (DYNData.script2.current < 0).*DYNData.script2.step; 
    starts = find([1 diff(flagI)]); % encontrando o ponto de início de cada run
    runs = diff(find(diff(flagI))); % encontrando o tamanho de todos os runs
    splitInd = starts(find(runs == max(runs))+1);

    DYNData.script3.time = DYNData.script2.time(splitInd:end);
    DYNData.script2.time(splitInd:end) = [];
    DYNData.script3.voltage = DYNData.script2.voltage(splitInd:end);
    DYNData.script2.voltage(splitInd:end) = [];
    DYNData.script3.current = DYNData.script2.current(splitInd:end);
    DYNData.script2.current(splitInd:end) = [];
    DYNData.script3.chgAh = DYNData.script2.chgAh(splitInd:end) - ...
                            DYNData.script2.chgAh(splitInd);    
    DYNData.script2.chgAh(splitInd:end) = [];
    DYNData.script3.disAh = DYNData.script2.disAh(splitInd:end) - ...
                            DYNData.script2.disAh(splitInd);
    DYNData.script2.disAh(splitInd:end) = [];
    DYNData.script3.step = DYNData.script2.step(splitInd:end);
    DYNData.script2.step(splitInd:end) = [];

    save(OUTFile,'DYNData'); % salvando os dados
  end 
end 