% Algorítimo SPKF
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
% Management Systems, Volume II, Equivalent-Circuit Methods," Artech House, 
% 2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% runSPKF: Executa um filtro de Kalman ponto-sigma para os dados dinâmicos
% E2 salvos e um modelo de célula E2

% Carrega o arquivo modelo correspondente a célula deste tipo
load A123model.mat

% Carrega os dados de teste da célula para serem usados para este 
% experimento em lote.
% Contém a variável "DYNData" na qual o campo "script1" é o de interesse.
% Este contém sub campos: time, current, voltage, soc

% load('A123_DYN_45_P05'); T = 05; % 05°C
% load('A123_DYN_45_P15'); T = 15; % 15°C
load('A123_DYN_50_P25'); T = 25; % 25°C
% load('A123_DYN_50_P30'); T = 25; %25°C
% load('A123_DYN_50_P35'); T = 35; % 35°C
% load('A123_DYN_50_P45'); T = 45; % 45°C

time    = DYNData.script1.time(:);   deltat = time(2)-time(1);
time    = time-time(1); % tempo inicial em 0
current = DYNData.script1.current(:); % discarga > 0; carga < 0.
voltage = DYNData.script1.voltage(:);
soc     = DYNData.script1.soc(:);

% Reserve armazenamento para resultados computados, para plotagem
sochat = zeros(size(soc));
socbound = zeros(size(soc));

% Valores de covariância
SigmaX0 = diag([1e-6 1e-8 2e-4]); % incerteza do estado inicial
SigmaV = 2e-1; % Incerteza do sensor de tensão, equação de saída
SigmaW = 2e-1; % Incerteza do sensor de corrente, equação de estado

% Cria a estrutura "spkfData" e inicializa as variáveis usando a primeira
% medição de tensão e primeira medição de temperatura
spkfData = initSPKF(voltage(1),T,SigmaX0,SigmaV,SigmaW,model);

% Agora, entre no loop para o restante do tempo, onde vamos atualizar o
% SPKF
hwait = waitbar(0,'Computing...'); 
for k = 1:length(voltage), 
  vk = voltage(k); % tensão "medida"
  ik = current(k); % corrente "medida"
  Tk = T;          % temperatura "medida"
  
  % Atualize o SOC (e outros estados)
  [sochat(k),socbound(k),spkfData] = iterSPKF(vk,ik,Tk,deltat,spkfData);
  % atualize periodicamente a barra de espera, mas não tão frequente 
  % (procedimento lento)
  if mod(k,1000)==0,
    waitbar(k/length(current),hwait);
  end;
end
close(hwait);

% Plotar estimativa do SOC
figure(1); clf; plot(time/60,100*soc,'k',time/60,100*sochat,'b'); hold on
plot([time/60; NaN; time/60],[100*(sochat+socbound); NaN; 100*(sochat-socbound)],'r');
%title('SOC estimation using SPKF'); xlabel('Time (min)'); ylabel('SOC (%)');
title('Estimando o SOC com o SPKF'); xlabel('Tempo (min)'); ylabel('SOC (%)');
%legend('Truth','Estimate','Bounds'); 
legend('Real','Estimado','Margem de 5%'); 
grid on; ylim([0 120])

% Exibir erro de estimativa RMS na janela de comando
fprintf('RMS SOC estimation error = %g%%\n',sqrt(mean((100*(soc-sochat)).^2)));

% Plotar erro de estimativa e limites
figure(2); clf; plot(time/60,100*(soc-sochat),'b'); hold on
plot([time/60; NaN; time/60],[100*socbound; NaN; -100*socbound],'r');
%title('SOC estimation errors using SPKF');
title('Erro da estimativa de SOC utilizando o SPKF');
%xlabel('Time (min)'); ylabel('SOC error (%)'); ylim([-6 6]); 
xlabel('Tempo (min)'); ylabel('Erro (%)'); ylim([-6 6]); 
set(gca,'ytick',-6:2:6);
%legend('SPKF error','location','northwest'); 
legend('Erro','location','northwest');
grid on

% Mostrar limites de erro na janela de comando
ind = find(abs(soc-sochat)>socbound);
fprintf('Percent of time error outside bounds = %g%%\n',...
        length(ind)/length(soc)*100);
