%Load A123 DYN Data
% load('A123_DYN_50_P25.mat', 'DYNData') % 25°C
% load('A123_DYN_50_P35.mat', 'DYNData') % 35°C
% load('A123_DYN_50_P45.mat', 'DYNData') % 45°C
% load('A123_DYN_45_P15.mat', 'DYNData') % 15°C
 load('A123_DYN_45_P05.mat', 'DYNData') % 05°C

teste = DYNData.script1;

%Initial Conditions
T = 25; %Change to whatever temperature is of interest to you
k = 0;

%Variables
time = teste.time; %Time
current = teste.current; %Current 

%Initialize variables with true length
interations = length(time);
throttle = zeros(1,interations);
brake = zeros(1,interations);

%Functions to calculate KPI
%Separete Throttle signal and Brake signal
[throttle, brake] = signals(current,throttle,brake,interations,k);

%Brake KPI Functions
%Steps to generate KPIs Brake Aggression and Brake Release
[brake_speed] = bspeed(brake); 
[brake_aggression] = baggression(brake,brake_speed,interations,k);
[brake_release] = brelease(brake,brake_speed,interations,k);
[brake_aggression_kpi_mean, brake_aggression_kpi] = bmeanaggression(brake_aggression,interations,k);
[brake_release_kpi, brake_release_kpi_mean] = bmeanrelease(brake_release,interations,k);

%Throttle KPI Functions 
%Steps to generate KPIs Throttle Aggression and Throttle Release
[throttle_speed] = tspeed(throttle);
[throttle_aggression] = taggression(throttle,throttle_speed,interations,k);
[throttle_release] = trelease(throttle,throttle_speed,interations,k);
[throttle_aggression_kpi_mean, throttle_aggression_kpi] = tmeanaggression(throttle_aggression,interations,k);
[throttle_release_kpi, throttle_release_kpi_mean] = tmeanrelease(throttle_release,interations,k);

%Plot KPI Graphics
figure(01); %UDDS Current Signal
subplot(1,2,1)
plot(time, current)
%title('Current Signal UDDS Dynamic ')
title('Sinal de Corrente UDDS Dinâmico')
xlabel('Tempo (s)')
%xlabel('Time') 
ylabel('Sinal de Corrente UDDS (A)') 
%ylabel('Current UDDS Signal') 
legend({'Sinal UDDS'},'Location','southwest')

subplot(1,2,2) %Extract Throttle and Brake Signal
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

%Plot Brake Graphics
figure(02); 

subplot(2,2,1) %Brake Speed
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

subplot(2,2,2) %Brake Aggression
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

subplot(2,2,3) %Brake Release
plot(time, brake)
%title('Brake and Brake Release')
title('Freio e Liberação do Freio')
%xlabel('Time') 
xlabel('Tempo (s)')
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, brake_release)
%legend({'Brake','Brake Release'},'Location','southwest')
legend({'Freio','Liberação do Freio'},'Location','southwest')
hold off

subplot(2,2,4) %KPI Brake Agression and Brake Release
plot(time, brake_aggression_kpi_mean)
%title('KPI - Brake Aggression (Mean) and Brake Release (Mean)')
title('KPI - Agressividade do Freio e Liberação do Freio')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('KPI')
ylabel('KPI')
hold on
plot(time, brake_release_kpi_mean)
%legend({'Brake Aggression KPI','Brake Release KPI'},'Location','southwest')
legend({'KPI - Agressividade do Freio','KPI - Liberação do Freio'},'Location','southwest')
hold off


%Plot Throttle Graphics 
figure(03); 

subplot(2,2,1) %Throttle Speed
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

subplot(2,2,2) %Throttle Aggression
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

subplot(2,2,3) %Throttle Release
plot(time, throttle)
%title('Throttle and Throttle Release')
title('Acelerador e Liberação do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('Current / Current Derivate')
ylabel('Corrente (A) / Derivada da corrente')
hold on
plot(time, throttle_release)
%legend({'Throttle','Throttle Release'},'Location','southwest')
legend({'Acelerador','Liberação do Acelerador'},'Location','southwest')
hold off

subplot(2,2,4) %KPI Throttle Agression and Throttle Release
plot(time, throttle_aggression_kpi_mean)
%title('KPI - Throttle Aggression (Mean) and Throttle Release (Mean)')
title('KPI - Agressividade do Acelerador e Liberação do Acelerador')
%xlabel('Time') 
xlabel('Tempo (s)') 
%ylabel('KPI')
ylabel('KPI')
hold on
plot(time, throttle_release_kpi_mean)
%legend({'Throttle Aggression KPI','Throttle Release KPI'},'Location','southwest')
legend({'KPI - Agressividade do Acelerador','KPI - Liberação do Acelerador'},'Location','southwest')
hold off
