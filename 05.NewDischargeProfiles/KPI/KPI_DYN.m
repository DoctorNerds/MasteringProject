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

% Carregar aquivo CALCE A123 FUDS com a temperatura selecionada
% load('A123_DYN_50_P25.mat', 'DYNData') % 25�C
load('CALCE_A123_FUDS_30', 'DYNData') % 35�C
% load('A123_DYN_50_P45.mat', 'DYNData') % 45�C
% load('A123_DYN_45_P15.mat', 'DYNData') % 15�C
% load('A123_DYN_45_P05.mat', 'DYNData') % 05�C

teste = DYNData.script1;

% Condi��es iniciais
T = 30; % Mude para qualquer temperatura que for do seu interesse
k = 0;

%Vari�veis
time = teste.time; % tempo
current = teste.current; % corrente 

% Inicializa as vari�veis com o tamanho real do sinal FUDS
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
figure(01); % Sinal de corrente FUDS
subplot(1,2,1)
plot(time, current)
title('Current Signal FUDS')
xlabel('Time') 
ylabel('Current UDDS Signal') 
legend({'FUDS'},'Location','southwest')

subplot(1,2,2) % Sinal de freio e acelerador extra�dos do sinal FUDS
plot(time, throttle)
title('Throttle and Brake')
xlabel('Time') 
ylabel('Current') 
hold on
plot(time, brake)
legend({'Throttle','Brake'},'Location','southwest')
hold off

% Plotando os gr�ficos de freio
figure(02); 
subplot(2,2,1) % Derivada do sinal de freio, "velocidade do freio"
plot(time, brake)
title('Brake and Brake Speed')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_speed)
legend({'Brake','Brake Speed'},'Location','southwest')
hold off

subplot(2,2,2) % Agressividade de freio
plot(time, brake)
title('Brake and Brake Aggression')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_aggression)
legend({'Brake','Brake Aggression'},'Location','southwest')
hold off

subplot(2,2,3) % Libera��o de freio
plot(time, brake)
title('Brake and Brake Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_release)
legend({'Brake','Brake Release'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e libera��o de freio
plot(time, brake_aggression_kpi_mean)
title('KPI - Brake Aggression (Mean) and Brake Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, brake_release_kpi_mean)
legend({'Brake Aggression KPI','Brake Release KPI'},'Location','southwest')
hold off

% Plotando os gr�ficos do acelerador 
figure(03); 
subplot(2,2,1) % Derivada do sinal do acelerador, "velocidade do acelerador"
plot(time, throttle)
title('Throttle and Throttle Speed')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_speed)
legend({'Throttle','Throttle Speed'},'Location','southwest')
hold off

subplot(2,2,2) % Agressividade do acelerador
plot(time, throttle)
title('Throttle and Throttle Aggression')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_aggression)
legend({'Throttle','Throttle Aggression'},'Location','southwest')
hold off

subplot(2,2,3) % Libera��o do acelerador
plot(time, throttle)
title('Throttle and Throttle Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_release)
legend({'Throttle','Throttle Release'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e libera��o do acelerador
plot(time, throttle_aggression_kpi_mean)
title('KPI - Throttle Aggression (Mean) and Throttle Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, throttle_release_kpi_mean)
legend({'Throttle Aggression KPI','Throttle Release KPI'},'Location','southwest')
hold off