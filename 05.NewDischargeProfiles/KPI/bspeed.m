% Algor�timo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna a derivada da fun�ao brake, sinal de corrente de
% recarga da bateri,a do sinal original de teste din�mico
%
% Entrada: 
%        brake = sinal de corrente de recarga da bateria
% Sa�da:
%        brake_speed = derivada do sinal brake

% Defini��o da fun��o
function [brake_speed] = bspeed(brake)

brake_speed = diff(brake);       % calcula a derivada da fun��o brake
% brake_speed(36880)=0; %Training data : A123_DYN_50_P25
% brake_speed(36814)=0; %Test data : A123_DYN_50_P35
brake_speed(7486)=0; %Test data : CALCE_A123_FUDS_30
end
