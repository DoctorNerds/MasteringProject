% Algorítimo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo é de autoria do aluno Fábio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Função que retorna o KPI de liberação de freio e sua média após a
% filtragem da função "brelease.m"
%
% Entradas:
%        brake_release = função que filtra o sinal de liberação do 
%        freio em um intervalo pre definido
%        interations = número de amostra de dados do sinal
%        k = número da amostra
% Saídas:
%        brake_release_kpi = KPI de liberação do freio
%        brake_release_kpi_mean = média móvel do KPI de liberação do
%        freio implementada como melhoria do sinal de entrada da RNA do
%        projeto final, desta forma o sinal sofre menos variações ao longo
%        do tempo.

% Definição da função
function [brake_release_kpi,brake_release_kpi_mean] = bmeanrelease(brake_release,interations,k)
j = 0;
l = 1;
for k = 1:interations,         % loop para percorrer todas as amostras
    
    if brake_release(k) > 0    % se existir sinal brake release
       j = j + 1;
       brake_release_kpi(j) = (brake_release(k)); % armazena valor no KPI
       if j == 1            % se primeiro valor
           brake_release_kpi_mean(l) = (brake_release_kpi(j)/2);
           l = l + 1;
       else                 % para os demais valores, calcula a média ponderada
           brake_release_kpi_mean(l) = ((brake_release_kpi(j-1))+((brake_release_kpi(j))/2))/2;
           l = l + 1;
       end
    else                    % se não existir sinal brake release
        if j == 0           % se for primeira amostra
            brake_release_kpi_mean(l) = 0;
            l = l + 1;
        else                % senão mantém valor da amostra anterior
            brake_release_kpi_mean(l) = brake_release_kpi_mean(l-1);
            l = l + 1;
        end
    end
end