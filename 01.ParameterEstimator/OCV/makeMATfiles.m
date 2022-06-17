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

% makeMATfiles:
% O objetivo deste script é transformar os dados do Excel da célula A123
% escolhida e transformá-los em arquivos ".mat" para facilitar sua
% utilização
clear all; close all 

cellIDs = {'A123'}; % Identificação da célula A123
order = [-25 -15 -5 5 15 25 35 45]; % Temperaturas de cada teste

% Cabeçalhos de coluna do Excel para procurar e converter para ".mat"
headers = {'Test_Time(s)','Step_Index','Current(A)','Voltage(V)',...
           'Charge_Capacity(Ah)','Discharge_Capacity(Ah)'};
% Cabeçalhos de coluna MATLAB correspondentes do arquivo Excel         
fields  = {'time','step','current','voltage','chgAh','disAh'};
% Nomes para os quatro scripts de teste diferentes
stepFields = {'script1','script2','script3','script4'};

for theID = 1:length(cellIDs),    % Loop varrendo todos os topos de célula (nesta aplicação só temos A123)
  data = [];                      % Inicializa a variável de dados vazia
  for theFile = 1:length(order),  % Loop varrendo todas as temperaturas (-25, -15, -5, 5, 15, 25, 35, 45)
    dirname = cellIDs{theID};     % nome da pasta que vamos procurar os dados
    ind = find(dirname == '_');   % lógica para se houver um "_", excluir
    if ~isempty(ind), dirname = dirname(1:ind-1); end
    if order(theFile) < 0,        % se a temperatura for negativa, então
      OCVPrefix = sprintf('%s_OCV/%s_OCV_N%02d',... % procure por este arquivo (nomenclatura para temperaturas negativas)
        dirname,cellIDs{theID},abs(order(theFile)));
    else                          % se a temperatura for positiva, então
      OCVPrefix = sprintf('%s_OCV/%s_OCV_P%02d',... % procure por este arquivo (nomenclatura para temperaturas positivas)
        dirname,cellIDs{theID},order(theFile));
    end

    for theScript = 1:4,          % processa os dados para todos os 4 scripts
      OCVData = [];               % Inicializa a variável de dados OCV vazia
      for theField = 1:length(fields), % inicializa os campos vazios
        OCVData.(fields{theField}) = [];
        chargeData.(fields{theField}) = [];
      end

      OCVFile = sprintf('%s_S%d.xlsx',OCVPrefix,theScript); % cria o nome do arquivo
      [~,sheets] = xlsfinfo(OCVFile);   % obtém os nomes das planilhas no arquivo
      fprintf('Reading %s\n',OCVFile);  % mensagem na tela enquanto o processo é realizado
      for theSheet = 1:length(sheets),  % loop varrendo todas as planilhas
        if strcmp(sheets{theSheet},'Info'), continue; end % ignora "Info"
        fprintf('  Processing sheet %s\n',sheets{theSheet}); % status exibido na tela
        [num,txt,raw] = xlsread(OCVFile,sheets{theSheet}); % lendo o arquivo de dados
        for theHeader = 1:length(headers), % analisar dados que nos importam neste trabalho
          ind = strcmp(txt,headers{theHeader}); % sobre
          OCVData.(fields{theHeader}) = [OCVData.(fields{theHeader});
            num(:,ind == 1)];
        end
      end
      data.(stepFields{theScript}) = OCVData; % salva na estrutura
    end
    outFile = sprintf('%s.mat',OCVPrefix); % cria o arquivo ".mat"
    OCVData = data;
    save(outFile,'OCVData');               % salva o arquivo ".mat"
  end
end