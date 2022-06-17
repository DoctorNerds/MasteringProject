% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o sinal de agressividade do acelerador filtrado dentro 
% dos parâmetros definidos
%
% Entradas: 
%        throttle = sinal de corrente de descarga da bateria
%        throttle_speed = derivada do sinal de corrente de descarga da
%        bateria
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saída:
%        throttle_agression = sinal filtrado de agresisvidade do acelerador

% Definição da função
function [throttle_aggression] = taggression(throttle,throttle_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    if (throttle(k) > 3) && (throttle_speed(k) > 3) && (throttle_speed(k) < 4.5),
        throttle_aggression(k) = throttle_speed(k); % armazena o sinal na variável de saída
    else   % se fora dos limites do filtro
        throttle_aggression(k) = 0; % armazena valor nulo na variável de saída
    end
end