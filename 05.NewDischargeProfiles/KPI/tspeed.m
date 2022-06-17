% Algor�timo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna a derivada da fun�ao throttle, sinal de corrente de
% descarga da bateria do sinal original de teste din�mico
%
% Entrada: 
%        throttle = sinal de corrente de descarga da bateria
% Sa�da:
%        throttle_speed = derivada do sinal throttle

% Defini��o da fun��o
function [throttle_speed] = tspeed(throttle)

throttle_speed = diff(throttle);    % calcula a derivada da fun��o throttle
% throttle_speed(36880)=0; %Training data : A123_DYN_50_P25
% throttle_speed(36814)=0; %Test data : A123_DYN_50_P35
throttle_speed(7486)=0; %Test data : CALCE_A123_FUDS_30
end
