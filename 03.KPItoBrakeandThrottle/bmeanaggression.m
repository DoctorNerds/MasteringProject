% Algor�timo KPI
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna o KPI de agressividade de freio e sua m�dia ap�s a
% filtragem da fun��o "baggression.m"
%
% Entradas: 
%        brake_aggression = fun��o que filtra o sinal de agressividade do 
%        freio em um intervalo pre definido
%        interations = n�mero de amostra de dados do sinal
%        k = n�mero da amostra
% Sa�das:
%        brake_aggression_kpi = KPI de agressividade do freio
%        brake_aggression_kpi_mean = m�dia m�vel do KPI de agressividade do
%        freio implementada como melhoria do sinal de entrada da RNA do
%        projeto final, desta forma o sinal sofre menos varia��es ao longo
%        do tempo.

% Defini��o da fun��o
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
       else                    % para os demais valores, calcula a m�dia ponderada
           brake_aggression_kpi_mean(l) = ((brake_aggression_kpi(j-1))+((brake_aggression_kpi(j))/2))/2;
           l = l + 1;
       end
    else                       % se n�o existir sinal brake aggression
        if j == 0              % se for primeira amostra
            brake_aggression_kpi_mean(l) = 0;
            l = l + 1;
        else                  % sen�o mant�m valor da amostra anterior
            brake_aggression_kpi_mean(l) = brake_aggression_kpi_mean(l-1);
            l = l + 1;
        end
    end
end