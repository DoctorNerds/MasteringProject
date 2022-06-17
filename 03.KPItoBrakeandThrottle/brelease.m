% Algor�timo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna o sinal de libera��o de freio filtrado dentro dos
% par�metros definidos
%
% Entradas: 
%        brake = sinal de corrente de recarga da bateria
%        brake_speed = derivada do sinal de corrente de recarga da
%        bateria
%        interations = n�mero de amostra de dados do sinal
%        k = n�mero da amostra
% Sa�da:
%        brake_release = sinal filtrado de libera��o do freio

% Defini��o da fun��o
function [brake_release] = brelease(brake,brake_speed,interations,k)

for k = 1:interations, % loop para filtrar o sinal dentro das amostras
    if (brake(k) > 3.5) && (brake_speed(k) < -2.5) && (brake_speed(k) > -3.0),
        brake_release(k) = (-1)*brake_speed(k);  % inverte e armazena o sinal na vari�vel de sa�da
    else   % se fora dos limites do filtro
        brake_release(k) = 0;    % armazena valor nulo na vari�vel de sa�da
    end
end