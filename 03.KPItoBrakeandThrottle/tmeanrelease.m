% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o KPI de liberação do acelerador e sua média após a
% filtragem da função "trelease.m"
%
% Entradas:
%        throttle_release = função que filtra o sinal de liberação do 
%        acelerador em um intervalo pre definido
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saídas:
%        throttle_release_kpi = KPI de liberação do acelerador
%        throttle_release_kpi_mean = média móvel do KPI de liberação do
%        acelerador implementada como melhoria do sinal de entrada da RNA 
%        do projeto final, desta forma o sinal sofre menos variações ao 
%        longo do tempo.

% Definição da função
function [throttle_release_kpi,throttle_release_kpi_mean] = tmeanrelease(throttle_release,interations,k)
j = 0;
l = 1;
for k = 1:interations,         % loop para percorrer todas as amostras
    
    if throttle_release(k) > 0    % se existir sinal throttle release
       j = j + 1;
       throttle_release_kpi(j) = (throttle_release(k)); % armazena valor no KPI
       if j == 1            % se primeiro valor
           throttle_release_kpi_mean(l) = (throttle_release_kpi(j)/2);
           l = l + 1;
       else                 % para os demais valores, calcula a média ponderada
           throttle_release_kpi_mean(l) = ((throttle_release_kpi(j-1))+((throttle_release_kpi(j))/2))/2;
           l = l + 1;
       end
    else                    % se não existir sinal throttle release
        if j == 0           % se for primeira amostra
            throttle_release_kpi_mean(l) = 0;
            l = l + 1;
        else                % senão mantém valor da amostra anterior
            throttle_release_kpi_mean(l) = throttle_release_kpi_mean(l-1);
            l = l + 1;
        end
    end
end