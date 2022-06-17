% Algorítimo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna a derivada da funçao throttle, sinal de corrente de
% descarga da bateria do sinal original de teste dinâmico
%
% Entrada: 
%        throttle = sinal de corrente de descarga da bateria
% Saída:
%        throttle_speed = derivada do sinal throttle

% Definição da função
function [throttle_speed] = tspeed(throttle)

throttle_speed = diff(throttle);    % calcula a derivada da função throttle
% throttle_speed(36880)=0; %Training data : A123_DYN_50_P25
% throttle_speed(36814)=0; %Test data : A123_DYN_50_P35
throttle_speed(7486)=0; %Test data : CALCE_A123_FUDS_30
end
