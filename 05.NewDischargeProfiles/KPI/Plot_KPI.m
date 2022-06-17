% Algorítimo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Este algoritmo plota os mesmos gráficos do "KPI_DYN.m", porém de forma
% individual para melhor vizualização e utilização na construção das
% imagens enviadas para o documento do mestrado

% Definição da função

% Plotando os gráficos de corrente de descarga e recarga da bateria
figure(01); % Sinal de corrente FUDS
plot(time, current)
title('Current Signal FUDS')
xlabel('Time') 
ylabel('Current FUDS Signal') 
legend({'FUDS'},'Location','southwest')

figure(02); % Sinal de freio e acelerador extraídos do sinal FUDS
plot(time, throttle)
title('Throttle and Brake')
xlabel('Time') 
ylabel('Current') 
hold on
plot(time, brake)
legend({'Throttle','Brake'},'Location','southwest')
hold off

% Plotando os gráficos de freio
figure(03); 
plot(time, brake) % Derivada do sinal de freio, "velocidade do freio"
title('Brake and Brake Speed')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_speed)
legend({'Brake','Brake Speed'},'Location','southwest')
hold off

figure(04);  % Agressividade de freio
plot(time, brake)
title('Brake and Brake Aggression')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_aggression)
legend({'Brake','Brake Aggression'},'Location','southwest')
hold off

figure(05); % Liberação de freio
plot(time, brake)
title('Brake and Brake Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, brake_release)
legend({'Brake','Brake Release'},'Location','southwest')
hold off

figure(06); % KPIs de agressividade e liberação de freio
plot(time, brake_aggression_kpi_mean)
title('KPI - Brake Aggression (Mean) and Brake Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, brake_release_kpi_mean)
legend({'Brake Aggression KPI','Brake Release KPI'},'Location','southwest')
hold off

% Plotando os gráficos do acelerador
figure(07); 
plot(time, throttle) % Derivada do sinal do acelerador, "velocidade do acelerador"
title('Throttle and Throttle Speed')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_speed)
legend({'Throttle','Throttle Speed'},'Location','southwest')
hold off

figure(08);  % Agressividade do acelerador
plot(time, throttle)
title('Throttle and Throttle Aggression')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_aggression)
legend({'Throttle','Throttle Aggression'},'Location','southwest')
hold off

figure(09); % Liberação do acelerador
plot(time, throttle)
title('Throttle and Throttle Release')
xlabel('Time') 
ylabel('Current / Current Derivate')
hold on
plot(time, throttle_release)
legend({'Throttle','Throttle Release'},'Location','southwest')
hold off

figure(10); % KPIs de agressividade e liberação do acelerador
plot(time, throttle_aggression_kpi_mean)
title('KPI - Throttle Aggression (Mean) and Throttle Release (Mean)')
xlabel('Time') 
ylabel('KPI')
hold on
plot(time, throttle_release_kpi_mean)
legend({'Throttle Aggression KPI','Throttle Release KPI'},'Location','southwest')
hold off