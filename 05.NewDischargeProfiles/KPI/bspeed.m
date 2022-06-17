% Algorítimo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna a derivada da funçao brake, sinal de corrente de
% recarga da bateri,a do sinal original de teste dinâmico
%
% Entrada: 
%        brake = sinal de corrente de recarga da bateria
% Saída:
%        brake_speed = derivada do sinal brake

% Definição da função
function [brake_speed] = bspeed(brake)

brake_speed = diff(brake);       % calcula a derivada da função brake
% brake_speed(36880)=0; %Training data : A123_DYN_50_P25
% brake_speed(36814)=0; %Test data : A123_DYN_50_P35
brake_speed(7486)=0; %Test data : CALCE_A123_FUDS_30
end
