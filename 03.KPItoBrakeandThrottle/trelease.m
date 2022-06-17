% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o sinal de liberação do acelerador filtrado dentro dos
% parâmetros definidos
%
% Entradas: 
%        throttle = sinal de corrente de descarga da bateria
%        throttle_speed = derivada do sinal de corrente de descarga da
%        bateria
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saída:
%        throttle_release = sinal filtrado de liberação do acelerador

% Definição da função
function [throttle_release] = trelease(throttle,throttle_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    if (throttle(k) > 4.5) && (throttle_speed(k) < -4.5) && (throttle_speed(k)> -5.0),
        throttle_release(k) = (-1)*throttle_speed(k);  % inverte e armazena o sinal na variável de saída
    else   % se fora dos limites do filtro
        throttle_release(k) = 0;    % armazena valor nulo na variável de saída
    end
end