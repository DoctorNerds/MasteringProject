% Algorítimo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o sinal de agressividade de freio filtrado dentro dos
% parâmetros definidos
%
% Entradas: 
%        brake = sinal de corrente de recarga da bateria
%        brake_speed = derivada do sinal de corrente de recarga da
%        bateria
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saída:
%        brake_agression = sinal filtrado de agresisvidade do freio

% Definição da função
function [brake_aggression] = baggression(brake,brake_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    % if (brake(k) > 0) && (brake_speed(k) > 0) && (brake_speed(k) < 5),
    if (brake_speed(k) > 0.1)
        brake_aggression(k) = brake_speed(k); % armazena o sinal na variável de saída 
    else   % se fora dos limites do filtro
        brake_aggression(k) = 0; % armazena valor nulo na variável de saída
    end
end
