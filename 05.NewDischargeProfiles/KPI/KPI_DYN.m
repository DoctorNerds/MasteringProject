% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Este algoritmo chama todas as funções definidas para separar os sinhas de
% brake e throttle do sinal de corrente UUDS de teste dinâmico da bateria
% em laboratório e posteriormente as funções que retornar os KPIs de
% agressividade e liberação do freio e também do acelerador

% Definição da função

% Carregar aquivo CALCE A123 FUDS com a temperatura selecionada
% load('A123_DYN_50_P25.mat', 'DYNData') % 25°C
load('CALCE_A123_FUDS_30', 'DYNData') % 35°C
% load('A123_DYN_50_P45.mat', 'DYNData') % 45°C
% load('A123_DYN_45_P15.mat', 'DYNData') % 15°C
% load('A123_DYN_45_P05.mat', 'DYNData') % 05°C

teste = DYNData.script1;

% Condições iniciais
T = 30; % Mude para qualquer temperatura que for do seu interesse
k = 0;

%Variáveis
time = teste.time; % tempo
current = teste.current; % corrente 

% Inicializa as variáveis com o tamanho real do sinal FUDS
interations = length(time);  % variável para armazenar o número de amostras
throttle = zeros(1,interations); % variável para armazenar o sinal throttle
brake = zeros(1,interations);    % variável para armazenar o sinal brake

% Funções para calcular os KPIs
% Separando os sinais de Throttle e Brake 
[throttle, brake] = signals(current,throttle,brake,interations,k);

% Funções para KPI de freio
% Passos para gerar os KPIs agressividade de freio e liberação de freio
[brake_speed] = bspeed(brake); 
[brake_aggression] = baggression(brake,brake_speed,interations,k);
[brake_release] = brelease(brake,brake_speed,interations,k);
[brake_aggression_kpi_mean, brake_aggression_kpi] = bmeanaggression(brake_aggression,interations,k);
[brake_release_kpi, brake_release_kpi_mean] = bmeanrelease(brake_release,interations,k);

% Funções para KPI de acelerador 
% Passos para gerar os KPIs agressividade do acelerador e liberação do
% acelerador
[throttle_speed] = tspeed(throttle);
[throttle_aggression] = taggression(throttle,throttle_speed,interations,k);
[throttle_release] = trelease(throttle,throttle_speed,interations,k);
[throttle_aggression_kpi_mean, throttle_aggression_kpi] = tmeanaggression(throttle_aggression,interations,k);
[throttle_release_kpi, throttle_release_kpi_mean] = tmeanrelease(throttle_release,interations,k);

% Plotando os gráficos de corrente de descarga e recarga da bateria
figure(01); % Sinal de corrente FUDS
subplot(1,2,1)
plot(time, current)
title('Current Signal FUDS')
xlabel('Time') 
ylabel('Current UDDS Signal') 
legend({'FUDS'},'Location','southwest')

subplot(1,2,2) % Sinal de freio e acelerador extraídos do sinal FUDS
plot(time, throttle)
title('Throttle and Brake')
xlabel('Time') 
ylabel('Current') 
hold on
plot(time, brake)
legend({'Throttle','Brake'},'Location','southwest')
hold off

% Plotando os gráficos de freio
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

subplot(2,2,3) % Liberação de freio
plot(time, brake)
title('Brake and Brake Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_release)
legend({'Brake','Brake Release'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e liberação de freio
plot(time, brake_aggression_kpi_mean)
title('KPI - Brake Aggression (Mean) and Brake Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, brake_release_kpi_mean)
legend({'Brake Aggression KPI','Brake Release KPI'},'Location','southwest')
hold off

% Plotando os gráficos do acelerador 
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

subplot(2,2,3) % Liberação do acelerador
plot(time, throttle)
title('Throttle and Throttle Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_release)
legend({'Throttle','Throttle Release'},'Location','southwest')
hold off

subplot(2,2,4) % KPIs de agressividade e liberação do acelerador
plot(time, throttle_aggression_kpi_mean)
title('KPI - Throttle Aggression (Mean) and Throttle Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, throttle_release_kpi_mean)
legend({'Throttle Aggression KPI','Throttle Release KPI'},'Location','southwest')
hold off