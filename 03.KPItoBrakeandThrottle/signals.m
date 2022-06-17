% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna a o sinal separado de throttle e brake,
% correspondentes ao sinal positivo de descarga da bateria e negativo de
% recarga da bateria, respectivamente, do sinal original do perfil UDDS de
% teste dinâmico da bateria em laboratório
%
% Entrada: 
%        current = sinal de corrente UDDS de teste dinâmico da bateria em
%        laboratório
%        throttle = vetor linha nulo com comprimento igual ao número de
%        amostras do sinal UDDS
%        brake = vetor linha nulo com o comprimento igual ao número de
%        amostras do sinal UDDS
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saída:
%        throttle = sinal de corrente de descarga da bateria
%        brake = sinal de corrente de recarga da bateria

% Definição da função
function [throttle, brake] = signals(current,throttle,brake,interations,k)

for k = 1:interations,         % loop para percorrer todas as amostras
    if current(k) > 0,         % sinal de corrente for positivo, descarga
        throttle(k) = current(k); % armazena o valor na variável throttle
        brake(k) = 0;             % armazena zero na variável brake
    else                       % sinal de corrente for negativo, recarga
        throttle(k) = 0;          % armazena zero na variável throttle
        brake(k) = (-1)*current(k); % armazena o valor na variável brake e inverte o sinal
    end
end
