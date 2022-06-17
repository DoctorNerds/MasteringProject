% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o sinal de liberação de freio filtrado dentro dos
% parâmetros definidos
%
% Entradas: 
%        brake = sinal de corrente de recarga da bateria
%        brake_speed = derivada do sinal de corrente de recarga da
%        bateria
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saída:
%        brake_release = sinal filtrado de liberação do freio

% Definição da função
function [brake_release] = brelease(brake,brake_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    if (brake(k) > 3.5) && (brake_speed(k) < -2.5) && (brake_speed(k) > -3.0),
        brake_release(k) = (-1)*brake_speed(k);  % inverte e armazena o sinal na variável de saída
    else   % se fora dos limites do filtro
        brake_release(k) = 0;    % armazena valor nulo na variável de saída
    end
end