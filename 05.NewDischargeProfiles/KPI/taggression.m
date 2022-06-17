% Algor�timo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna o sinal de agressividade do acelerador filtrado dentro 
% dos par�metros definidos
%
% Entradas: 
%        throttle = sinal de corrente de descarga da bateria
%        throttle_speed = derivada do sinal de corrente de descarga da
%        bateria
%        interations = n�mero de amostra de dados do sinal
%        k = n�mero da amostra
% Sa�da:
%        throttle_agression = sinal filtrado de agresisvidade do acelerador

% Defini��o da fun��o
function [throttle_aggression] = taggression(throttle,throttle_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    % if (throttle(k) > 0) && (throttle_speed(k) > 0) && (throttle_speed(k) < 5),
    if (throttle_speed(k) > 0.1),
        throttle_aggression(k) = throttle_speed(k); % armazena o sinal na vari�vel de sa�da
    else   % se fora dos limites do filtro
        throttle_aggression(k) = 0; % armazena valor nulo na vari�vel de sa�da
    end
end