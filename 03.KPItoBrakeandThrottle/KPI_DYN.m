% Algor�timo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Este algoritmo chama todas as fun��es definidas para separar os sinhas de
% brake e throttle do sinal de corrente UUDS de teste din�mico da bateria
% em laborat�rio e posteriormente as fun��es que retornar os KPIs de
% agressividade e libera��o do freio e tamb�m do acelerador

% Defini��o da fun��o

% Carregar aquivo A123 DYN com a temperatura selecionada
% load('A123_DYN_50_P25.mat', 'DYNData') % 25�C
load('A123_DYN_50_P35.mat', 'DYNData') % 35�C
% load('A123_DYN_50_P45.mat', 'DYNData') % 45�C
% load('A123_DYN_45_P15.mat', 'DYNData') % 15�C
% load('A123_DYN_45_P05.mat', 'DYNData') % 05�C 

teste = DYNData.script1;

% Condi��es iniciais
T = 25; % Mude para qualquer temperatura que for do seu interesse
k = 0;

%Vari�veis
time = teste.time; % tempo
current = teste.current; % corrente

% Inicializa as vari�veis com o tamanho real do sinal UDDS
interations = length(time);  % vari�vel para armazenar o n�mero de amostras
throttle = zeros(1,interations); % vari�vel para armazenar o sinal throttle
brake = zeros(1,interations);    % vari�vel para armazenar o sinal brake

% Fun��es para calcular os KPIs
% Separando os sinais de Throttle e Brake 
[throttle, brake] = signals(current,throttle,brake,interations,k);

% Fun��es para KPI de freio
% Passos para gerar os KPIs agressividade de freio e libera��o de freio
[brake_speed] = bspeed(brake); 
[brake_aggression] = baggression(brake,brake_speed,interations,k);
[brake_release] = brelease(brake,brake_speed,interations,k);
[brake_aggression_kpi_mean, brake_aggression_kpi] = bmeanaggression(brake_aggression,interations,k);
[brake_release_kpi, brake_release_kpi_mean] = bmeanrelease(brake_release,interations,k);

% Fun��es para KPI de acelerador 
% Passos para gerar os KPIs agressividade do acelerador e libera��o do
% acelerador
[throttle_speed] = tspeed(throttle);
[throttle_aggression] = taggression(throttle,throttle_speed,interations,k);
[throttle_release] = trelease(throttle,throttle_speed,interations,k);
[throttle_aggression_kpi_mean, throttle_aggression_kpi] = tmeanaggression(throttle_aggression,interations,k);
[throttle_release_kpi, throttle_release_kpi_mean] = tmeanrelease(throttle_release,interations,k);

% Plotando os gr�ficos de corrente de descarga e recarga da bateria
figure(01); % Sinal de corrente UDDS
subplot(1,2,1)
plot(time, current)
%title('Current Signal UDDS Dynamic ')
title('Sinal de Corrente UDDS Din�mico')
xlabel('Tempo (s)')
%xlabel('Time') 
ylabel('Sinal de Corrente UDDS (A)') 
%ylabel('Current UDDS Signal') 
legend({'Sinal UDDS'},'Location','southwest')

subplot(1,2,2) % Sinal de freio e acelerador extra�dos do sinal UDDS
plot(time, throttle)
%title('Throttle and Brake')
title('Acelerador e Freio')
%xlabel('Time') 
xlabel('Tempo (s)')
%ylabel('Current') 
ylabel('Corrente (A)')
hold on
plot(time, brake)
%legend({'Throttle','Brake'},'Location','southwest')
legend({'Acelerador','Freio'},'Location','southwest')
hold off

% Plotando os gr�ficos de freio
figure(02); 

subplot(2,2,1) % Derivada do sinal de freio, "velocidade do freio"
plot(time, brake)
%title('Brake and Brake Speed')
title('Freio e Velocidade do Freio')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, brake_speed)
%legend({'Brake','Brake Speed'},'Location','southwest')
legend({'Freio','Velocidade do Freio'},'Location','southwest')
hold off

subplot(2,2,2) % Agressividade de freio
plot(time, brake)
%title('Brake and Brake Aggression')
title('Freio e Agressividade do Freio')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, brake_aggression)
%legend({'Brake','Brake Aggression'},'Location','southwest')
legend({'Freio','Agressividade do freio'},'Location','southwest')
hold off

subplot(2,2,3) % Libera��o de freio
plot(time, brake)
%title('Brake and Brake Release')
title('Freio e Libera��o do Freio')
%xlabel('Time') 
xlabel('Tempo (s)')
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, brake_release)
%legend({'Brake','Brake Release'},'Location','southwest')
legend({'Freio','Libera��o do Freio'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e libera��o de freio
plot(time, brake_aggression_kpi_mean)
%title('KPI - Brake Aggression (Mean) and Brake Release (Mean)')
title('KPI - Agressividade do Freio e Libera��o do Freio')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('KPI')
ylabel('KPI')
hold on
plot(time, brake_release_kpi_mean)
%legend({'Brake Aggression KPI','Brake Release KPI'},'Location','southwest')
legend({'KPI - Agressividade do Freio','KPI - Libera��o do Freio'},'Location','southwest')
hold off

% Plotando os gr�ficos do acelerador 
figure(03); 

subplot(2,2,1) % Derivada do sinal do acelerador, "velocidade do acelerador"
plot(time, throttle)
%title('Throttle and Throttle Speed')
title('Acelerador e Velocidade do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, throttle_speed)
%legend({'Throttle','Throttle Speed'},'Location','southwest')
legend({'Acelerador','Velocidade do Acelerador'},'Location','southwest')
hold off

subplot(2,2,2) % Agressividade do acelerador
plot(time, throttle)
%title('Throttle and Throttle Aggression')
title('Acelerador e Agressividade do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)')
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, throttle_aggression)
%legend({'Throttle','Throttle Aggression'},'Location','southwest')
legend({'Acelerador','Agressividade do Acelerador'},'Location','southwest')
hold off

subplot(2,2,3) % Libera��o do acelerador
plot(time, throttle)
%title('Throttle and Throttle Release')
title('Acelerador e Libera��o do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, throttle_release)
%legend({'Throttle','Throttle Release'},'Location','southwest')
legend({'Acelerador','Libera��o do Acelerador'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e libera��o do acelerador
plot(time, throttle_aggression_kpi_mean)
%title('KPI - Throttle Aggression (Mean) and Throttle Release (Mean)')
title('KPI - Agressividade do Acelerador e Libera��o do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('KPI')
ylabel('KPI')
hold on
plot(time, throttle_release_kpi_mean)
%legend({'Throttle Aggression KPI','Throttle Release KPI'},'Location','southwest')
legend({'KPI - Agressividade do Acelerador','KPI - Libera��o do Acelerador'},'Location','southwest')
hold off