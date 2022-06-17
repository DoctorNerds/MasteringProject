% Algor�timo RNA - Novos resultados com outros perfis de corrente
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo � de autoria do aluno F�bio Mori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Fun��o que retorna o KPI de libera��o de freio e sua m�dia ap�s a
% filtragem da fun��o "brelease.m"
%
% Entradas:
%        brake_release = fun��o que filtra o sinal de libera��o do 
%        freio em um intervalo pre definido
%        interations = n�mero de amostra de dados do sinal
%        k = n�mero da amostra
% Sa�das:
%        brake_release_kpi = KPI de libera��o do freio
%        brake_release_kpi_mean = m�dia m�vel do KPI de libera��o do
%        freio implementada como melhoria do sinal de entrada da RNA do
%        projeto final, desta forma o sinal sofre menos varia��es ao longo
%        do tempo.

% Defini��o da fun��o
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
       else                 % para os demais valores, calcula a m�dia ponderada
           brake_release_kpi_mean(l) = ((brake_release_kpi(j-1))+((brake_release_kpi(j))/2))/2;
           l = l + 1;
       end
    else                    % se n�o existir sinal brake release
        if j == 0           % se for primeira amostra
            brake_release_kpi_mean(l) = 0;
            l = l + 1;
        else                % sen�o mant�m valor da amostra anterior
            brake_release_kpi_mean(l) = brake_release_kpi_mean(l-1);
            l = l + 1;
        end
    end
end