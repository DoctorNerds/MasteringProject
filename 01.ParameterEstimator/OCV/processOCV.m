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
% --------------------------------------------------------------------
% função = processOCV(data,cellID,minV,maxV,savePlots)
% 
% Entradas:
%   data = dados de teste de célula
%   cellID = identificador do tipo de célula
%   minV = tensão mínima definida para relação OCV
%   maxV = tensão máxima definida para relação OCV
%   savePlots = 0 or 1 ... defina como "1" para salvar gráficos como arquivos 
% Output:
%   model = estrutura dos dados
%
% Nota técnica: O algoritmo "makeMATfiles.m" deve ser codado antes
%  
% A seguir as etapas de cada um dos 4 scripts do teste OCV:
%   Script 1 (câmara térmica ajustada para temperatura de teste):
%     Step 1: Repouso a @100% SOC para aclimatar à temperatura de teste
%     Step 2: Descarga com taxa baixa (ca. C/30) até a tensão mínima
%     Step 3: Repouso
%   Script 2 (câmara térmica ajustada para 25°C):
%     Step 1: Repouso a @0% SOC para aclimatar à 25°C
%     Step 2: Descarga para a tensão mínima (ca. C/3)
%     Step 3: Repouso
%     Step 4: Tensão constante igual a Vmín
%     Steps 5-7: Aplicar um perfil de corrente oscilatório utilizado em desmagnetização 
%     para minimizar o efeito da histerese
%     Step 8: Repouso
%     Step 9: Tensão constante em Vmin por 15 minutos
%     Step 10: Repouso
%   Script 3 (câmara térmica ajustada para temperatura de teste):
%     Step 1: Repouso a @0% SOC para aclimatar à temperatura de teste
%     Step 2: Carregar com taxa baixa (ca. C/30) até a tensão máxima
%     Step 3: Repouso
%   Script 4 (câmara térmica ajustada para 25°C):
%     Step 1: Repouso a @100% SOC para aclimatar à 25°C
%     Step 2: Carrega para a tensão máxima (ca. C/3)
%     Step 3: Repouso
%     Step 4: Tensão constante igual a Vmáx
%     Steps 5-7: Aplicar um perfil de corrente oscilatório utilizado em desmagnetização 
%     para minimizar o efeito da histerese
%     Step 8: Repouso
%     Step 9: Tensão constante em Vmáx por 15 minutos
%     Step 10: Repouso
% 

function model=processOCV(data,cellID,minV,maxV,savePlots)
  filetemps = [data.temp]; filetemps = filetemps(:);
  numtemps = length(filetemps); 
  
  % Primeiro procura por testes à 25°C para calcular a eficiência de 
  % Coulomb e a capacidade nesta temperatura antes de continuar
  % (necessário)
  ind25 = find(filetemps == 25); 
  if isempty(ind25),
    error('Must have a test at 25degC');
  end
  not25 = find(filetemps ~= 25);

  % ------------------------------------------------------------------
  % Processa dados à 25°C para encontrar a relação entre OCV e eta25
  % ------------------------------------------------------------------
  SOC = 0:0.005:1; % define os pontos de saída para esta etapa de SOC
  filedata = zeros([0 length(data)]);
  eta = zeros(size(filetemps)); % eficiência de Coulomn
  Q   = zeros(size(filetemps)); % capacidade total aparente da bateria
  k = ind25;

  totDisAh = data(k).script1.disAh(end) + ... % calcula o total de Ah
             data(k).script2.disAh(end) + ... % que foram descarregados
             data(k).script3.disAh(end) + ...
             data(k).script4.disAh(end);
  totChgAh = data(k).script1.chgAh(end) + ... % calcula o total de Ah
             data(k).script2.chgAh(end) + ... % que foram carregados
             data(k).script3.chgAh(end) + ...
             data(k).script4.chgAh(end);
  eta25 = totDisAh/totChgAh; eta(k) = eta25;  % calcula a eficiência de Coulomb À 25°C
  data(k).script1.chgAh = data(k).script1.chgAh*eta25; % ajusta o valor de
  data(k).script2.chgAh = data(k).script2.chgAh*eta25; % carga em Ah por eta25
  data(k).script3.chgAh = data(k).script3.chgAh*eta25; % em todos os scripts
  data(k).script4.chgAh = data(k).script4.chgAh*eta25;

  % capacidade da célula à 25°C (deve ser essencialmente a 
  % mesma em todas as temperaturas, mas estamos computando-as 
  % individualmente para verificar isso)
  Q25 = data(k).script1.disAh(end) + data(k).script2.disAh(end) - ...
        data(k).script1.chgAh(end) - data(k).script2.chgAh(end);
  Q(k) = Q25;
  indD  = find(data(k).script1.step == 2);        % etapa de descarga lenta
  IR1Da = data(k).script1.voltage(indD(1)-1) - ... % queda de tensão i*R no 
          data(k).script1.voltage(indD(1));        % início da descarga
  IR2Da = data(k).script1.voltage(indD(end)+1) - ... % o mesmo que no final
          data(k).script1.voltage(indD(end));      % da descarga
  indC  = find(data(k).script3.step == 2);    % etapa de carregamento lento
  IR1Ca = data(k).script3.voltage(indC(1)) - ...   % queda de tensão i*R no
          data(k).script3.voltage(indC(1)-1);      % início da carga
  IR2Ca = data(k).script3.voltage(indC(end)) - ... % o mesmo que no final
          data(k).script3.voltage(indC(end)+1);    % da carga
  IR1D = min(IR1Da,2*IR2Ca); IR2D = min(IR2Da,2*IR1Ca);      % definindo as 
  IR1C = min(IR1Ca,2*IR2Da); IR2C = min(IR2Ca,2*IR1Da);    % bordas/limites
  
  blend = (0:length(indD)-1)/(length(indD)-1); 
  IRblend = IR1D + (IR2D-IR1D)*blend(:);       
  disV = data(k).script1.voltage(indD) + IRblend;
  disZ = 1 - data(k).script1.disAh(indD)/Q25;    % calculando o SOC 
  disZ = disZ + (1 - disZ(1));                   % em cada ponto
  filedata(k).disZ = disZ; 
  filedata(k).disV = data(k).script1.voltage(indD);
  
  blend = (0:length(indC)-1)/(length(indC)-1); 
  IRblend = IR1C + (IR2C-IR1C)*blend(:);       
  chgV = data(k).script3.voltage(indC) - IRblend; 
  chgZ = data(k).script3.chgAh(indC)/Q25;      % calculando o SOC
  chgZ = chgZ - chgZ(1);                       % em cada ponto
  filedata(k).chgZ = chgZ; 
  filedata(k).chgV = data(k).script3.voltage(indC);

  % Calculando a diferença de tensão entre carga e descarga à @50% SOC
  % força a curva compensada i*R para passar a meio caminho entre 
  % cada carga e descarga neste ponto
  deltaV50 = interp1(chgZ,chgV,0.5) - interp1(disZ,disV,0.5); 
  ind = find(chgZ < 0.5);
  vChg = chgV(ind) - chgZ(ind)*deltaV50;
  zChg = chgZ(ind);
  ind = find(disZ > 0.5);
  vDis = flipud(disV(ind) + (1 - disZ(ind))*deltaV50);
  zDis = flipud(disZ(ind));
  filedata(k).rawocv = interp1([zChg; zDis],[vChg; vDis],SOC,...
                               'linear','extrap');
                           
  % "rawocv" agora tem nosso melhor palpite do verdadeiro OCV nesta 
  % temperatura
  filedata(k).temp = data(k).temp;
  
  % ------------------------------------------------------------------
  % Processando as outras temperaturas para encontrar a relação entre
  % OCV e eta (eficiência de Coulomb) 
  % Tudo o que se segue é igual a 25°C, exceto que precisamos
  % compensam diferentes eficiências coulombicas eta em diferentes
  % temperaturas
  % ------------------------------------------------------------------
  
  for k = not25',
    data(k).script2.chgAh = data(k).script2.chgAh*eta25;
    data(k).script4.chgAh = data(k).script4.chgAh*eta25;    
    eta(k) = (data(k).script1.disAh(end) + ...
              data(k).script2.disAh(end) + ...
              data(k).script3.disAh(end) + ...
              data(k).script4.disAh(end) - ...
              data(k).script2.chgAh(end) - ...
              data(k).script4.chgAh(end))/ ...
             (data(k).script1.chgAh(end) + ...
              data(k).script3.chgAh(end));
    data(k).script1.chgAh = eta(k)*data(k).script1.chgAh;         
    data(k).script3.chgAh = eta(k)*data(k).script3.chgAh;         

    Q(k) = data(k).script1.disAh(end) + data(k).script2.disAh(end) ...
           - data(k).script1.chgAh(end) - data(k).script2.chgAh(end);
    indD = find(data(k).script1.step == 2); 
    IR1D = data(k).script1.voltage(indD(1)-1) - ...
            data(k).script1.voltage(indD(1));
    IR2D = data(k).script1.voltage(indD(end)+1) - ...
            data(k).script1.voltage(indD(end));
    indC = find(data(k).script3.step == 2);
    IR1C = data(k).script3.voltage(indC(1)) - ...
            data(k).script3.voltage(indC(1)-1);
    IR2C = data(k).script3.voltage(indC(end)) - ...
            data(k).script3.voltage(indC(end)+1);
    IR1D = min(IR1D,2*IR2C); IR2D = min(IR2D,2*IR1C);
    IR1C = min(IR1C,2*IR2D); IR2C = min(IR2C,2*IR1D);

    blend = (0:length(indD)-1)/(length(indD)-1);
    IRblend = IR1D + (IR2D-IR1D)*blend(:);
    disV = data(k).script1.voltage(indD) + IRblend;
    disZ = 1 - data(k).script1.disAh(indD)/Q25;
    disZ = disZ + (1 - disZ(1));
    filedata(k).disZ = disZ; 
    filedata(k).disV = data(k).script1.voltage(indD);
    
    blend = (0:length(indC)-1)/(length(indC)-1);
    IRblend = IR1C + (IR2C-IR1C)*blend(:);
    chgV = data(k).script3.voltage(indC) - IRblend;
    chgZ = data(k).script3.chgAh(indC)/Q25;
    chgZ = chgZ - chgZ(1);
    filedata(k).chgZ = chgZ; 
    filedata(k).chgV = data(k).script3.voltage(indC);

    deltaV50 = interp1(chgZ,chgV,0.5) - interp1(disZ,disV,0.5);
    ind = find(chgZ < 0.5);
    vChg = chgV(ind) - chgZ(ind)*deltaV50;
    zChg = chgZ(ind);
    ind = find(disZ > 0.5);
    vDis = flipud(disV(ind) + (1 - disZ(ind))*deltaV50);
    zDis = flipud(disZ(ind));
    filedata(k).rawocv = interp1([zChg; zDis],[vChg; vDis],SOC,...
                                 'linear','extrap');
  
    filedata(k).temp = data(k).temp;
  end

  % ------------------------------------------------------------------
  % Usando os dados SOC versus OCV disponíveis em cada temperatura
  % para calcular uma relação OCV0 e OCVrel
  % ------------------------------------------------------------------
  % Primeiro, compile as voltagens e temperaturas em matrizes únicas
  Vraw = []; temps = []; 
  for k = 1:numtemps,
    if filedata(k).temp > 0,
      Vraw = [Vraw; filedata(k).rawocv]; 
      temps = [temps; filedata(k).temp]; 
    end
  end
  numtempskept = size(Vraw,1);

  % use os mínimos quadrados lineares para determinar o melhor valor para 
  % OCV à 0°C e em seguida a mudança de OCV por grau 
  OCV0 = zeros(size(SOC)); OCVrel = OCV0;
  H = [ones([numtempskept,1]), temps];
  for k = 1:length(SOC),
    X = H\Vraw(:,k); % fit OCV(z,T) = 1*OCV0(z) + T*OCVrel(z)
    OCV0(k) = X(1); 
    OCVrel(k) = X(2);
  end
  model.OCV0 = OCV0;
  model.OCVrel = OCVrel;
  model.SOC = SOC;

  % ------------------------------------------------------------------
  % Faça SOC0 e SOCrel
  % Faça o mesmo tipo de análise para encontrar SOC como uma função de OCV
  % ------------------------------------------------------------------
  z = -0.1:0.01:1.1; % test soc vector
  v = minV-0.01:0.01:maxV+0.01;
  socs = [];
  for T = filetemps',
    v1 = OCVfromSOCtemp(z,T,model);
    socs = [socs; interp1(v1,z,v)]; 
  end

  SOC0 = zeros(size(v)); SOCrel = SOC0; 
  H = [ones([numtemps,1]), filetemps]; 
  for k = 1:length(v),
    X = H\socs(:,k); % fit SOC(v,T) = 1*SOC0(v) + T*SOCrel(v)
    SOC0(k) = X(1); 
    SOCrel(k) = X(2);
  end
  model.OCV = v;
  model.SOC0 = SOC0;
  model.SOCrel = SOCrel;
  
  % ------------------------------------------------------------------
  % Salvando outros dados na estrutura
  % ------------------------------------------------------------------
  model.OCVeta = eta;
  model.OCVQ = Q;
  model.name = cellID;
  
  % ------------------------------------------------------------------
  % Plotando alguns dados
  % ------------------------------------------------------------------
  for k = 1:numtemps, 
    figure;
    plot(100*SOC,OCVfromSOCtemp(SOC,filedata(k).temp,model),...
         100*SOC,filedata(k).rawocv); hold on
    xlabel('SOC (%)'); ylabel('OCV (V)'); ylim([minV-0.1 maxV+0.1]);
    %title(sprintf('%s OCV relationship at temp = %d',...
    title(sprintf('%s relação OCV e SOC na temperatura = %d °C',...
      cellID,filedata(k).temp)); xlim([0 100]);
    err = filedata(k).rawocv - ...
          OCVfromSOCtemp(SOC,filedata(k).temp,model);
    rmserr = sqrt(mean(err.^2));
    %text(2,maxV-0.15,sprintf('RMS error = %4.1f (mV)',...
    text(2,maxV-0.15,sprintf('erro RMS = %4.1f (mV)',...
      rmserr*1000),'fontsize',14);
    plot(100*filedata(k).disZ,filedata(k).disV,'k--','linewidth',1);
    plot(100*filedata(k).chgZ,filedata(k).chgV,'k--','linewidth',1);
    %legend('Model prediction','Approximate OCV from data',...
    legend('Predição do modelo','OCV aproximado dos dados',...
           'Dados medidos','location','southeast');
           %'Raw measured data','location','southeast');
    
    if savePlots,
      if ~exist('OCV_FIGURES','dir'), mkdir('OCV_FIGURES'); end
        if filetemps(k) < 0,
          filename = sprintf('OCV_FIGURES/%s_N%02d.png',...
            cellID,abs(filetemps(k)));
        else
          filename = sprintf('OCV_FIGURES/%s_P%02d.png',...
            cellID,filetemps(k));
        end
        print(filename,'-dpng')
    end
  end
end