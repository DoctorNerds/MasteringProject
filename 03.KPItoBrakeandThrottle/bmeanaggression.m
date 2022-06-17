% Algorítimo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o KPI de agressividade de freio e sua média após a
% filtragem da função "baggression.m"
%
% Entradas: 
%        brake_aggression = função que filtra o sinal de agressividade do 
%        freio em um intervalo pre definido
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saídas:
%        brake_aggression_kpi = KPI de agressividade do freio
%        brake_aggression_kpi_mean = média móvel do KPI de agressividade do
%        freio implementada como melhoria do sinal de entrada da RNA do
%        projeto final, desta forma o sinal sofre menos variações ao longo
%        do tempo.

% Definição da função
function [brake_aggression_kpi_mean, brake_aggression_kpi] = bmeanaggression(brake_aggression,interations,k)
j = 0;
l = 1;
for k = 1:interations,         % loop para percorrer todas as amostras
    
    if brake_aggression(k) > 0 % se existir sinal brake aggression
       j = j + 1;
       brake_aggression_kpi(j) = (brake_aggression(k)); % armazena valor no KPI
       if j == 1               % se primeiro valor
           brake_aggression_kpi_mean(l) = (brake_aggression_kpi(j)/2);
           l = l + 1;
       else                    % para os demais valores, calcula a média ponderada
           brake_aggression_kpi_mean(l) = ((brake_aggression_kpi(j-1))+((brake_aggression_kpi(j))/2))/2;
           l = l + 1;
       end
    else                       % se não existir sinal brake aggression
        if j == 0              % se for primeira amostra
            brake_aggression_kpi_mean(l) = 0;
            l = l + 1;
        else                  % senão mantém valor da amostra anterior
            brake_aggression_kpi_mean(l) = brake_aggression_kpi_mean(l-1);
            l = l + 1;
        end
    end
end