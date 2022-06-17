% Algor�timo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna a o sinal separado de throttle e brake,
% correspondentes ao sinal positivo de descarga da bateria e negativo de
% recarga da bateria, respectivamente, do sinal original do perfil UDDS de
% teste din�mico da bateria em laborat�rio
%
% Entrada: 
%        current = sinal de corrente UDDS de teste din�mico da bateria em
%        laborat�rio
%        throttle = vetor linha nulo com comprimento igual ao n�mero de
%        amostras do sinal UDDS
%        brake = vetor linha nulo com o comprimento igual ao n�mero de
%        amostras do sinal UDDS
%        interations = n�mero de amostra de dados do sinal
%        k = n�mero da amostra
% Sa�da:
%        throttle = sinal de corrente de descarga da bateria
%        brake = sinal de corrente de recarga da bateria

% Defini��o da fun��o
function [throttle, brake] = signals(current,throttle,brake,interations,k)

for k = 1:interations,         % loop para percorrer todas as amostras
    if current(k) > 0,         % sinal de corrente for positivo, descarga
        throttle(k) = current(k); % armazena o valor na vari�vel throttle
        brake(k) = 0;             % armazena zero na vari�vel brake
    else                       % sinal de corrente for negativo, recarga
        throttle(k) = 0;          % armazena zero na vari�vel throttle
        brake(k) = (-1)*current(k); % armazena o valor na vari�vel brake e inverte o sinal
    end
end
