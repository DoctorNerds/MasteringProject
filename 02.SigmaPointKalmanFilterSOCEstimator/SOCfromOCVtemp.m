% Algorítimo SPKF
%
% Este arquivo foi utilizado no projeto de mestrado do aluno Fábio Mori.
% O algoritmo aplicado neste projeto está protegido por direitos autorais
% de Gregory L. Plett:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2015 by Gregory L. Plett of the University of Colorado 
% Colorado Springs (UCCS). This work is licensed under a Creative Commons 
% Attribution-NonCommercial-ShareAlike 4.0 Intl. License, v. 1.0.
% It is provided "as is", without express or implied warranty, for 
% educational and informational purposes only.
% This file is provided as a supplement to: Plett, Gregory L., "Battery
% Management Systems, Volume I, Battery Modeling," Artech House, 2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% função soc = SOCfromOCVtemp(ocv,temp,model)
%
% Calcula o estado de carga aproximado da tensão de circuito aberto
% totalmente em repouso da célula a uma dada temperatura. Este não é
% exatamente o inverso da função OCVfromSOCtemp devido à forma como os
% cálculos são feitos, mas está "bastante próximo".
%
% Entradas: 
%        ocv = escalar ou matriz de tensões de circuito aberto da célula
%        temp = escalar ou matriz de temperaturas em que calcular o OCV
%        model = estrutura de dados produzida pelo processDynamic
% Saídas: 
%        soc = escalar ou matriz dos estados de carga -- uma para cada
%              ponto de entrada de soc e temperatura

function soc=SOCfromOCVtemp(ocv,temp,model)
  ocvcol = ocv(:); % força ocv para ser um vetor coluna
  OCV = model.OCV(:); % força para ser um vetor coluna
  SOC0 = model.SOC0(:); % força para ser um vetor coluna
  SOCrel = model.SOCrel(:); % força para ser um vetor coluna
  if isscalar(temp), % replica uma temperatura escalar para todos ocvs
    tempcol = temp*ones(size(ocvcol)); 
  else % força a matriz de temperatura para ser um vetor coluna
    tempcol = temp(:); 
    if ~isequal(size(tempcol),size(ocvcol)),
      error(['Function inputs "ocv" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']);
    end    
  end
  diffOCV=OCV(2)-OCV(1); % espaçamento entre pontos OCV - assuma uniforme
  soc=zeros(size(ocvcol)); % inicializa a saída para zero
  I1=find(ocvcol <= OCV(1)); % índices de ocvs abaixo dos dados armazenados no modelo
  I2=find(ocvcol >= OCV(end)); % e de ocvs acima dos dados armazenados no modelo
  I3=find(ocvcol > OCV(1) & ocvcol < OCV(end)); % o restante deles
  I6=isnan(ocvcol); % se a entrada for "não um número" para qualquer local

  % para ocvs abaixo da menor tensão, extrapole a parte de baixo da tabela
  if ~isempty(I1),
    dz = (SOC0(2)+tempcol.*SOCrel(2)) - (SOC0(1)+tempcol.*SOCrel(1));
    soc(I1)= (ocvcol(I1)-OCV(1)).*dz(I1)/diffOCV + ...
             SOC0(1)+tempcol(I1).*SOCrel(1);
  end
  
  % para ocvs acima da menor tensão, extrapole a parte de cima da tabela
  if ~isempty(I2),
    dz = (SOC0(end)+tempcol.*SOCrel(end)) - ...
         (SOC0(end-1)+tempcol.*SOCrel(end-1));
    soc(I2) = (ocvcol(I2)-OCV(end)).*dz(I2)/diffOCV + ...
              SOC0(end)+tempcol(I2).*SOCrel(end);
  end
  
  % para faixa normal de ocv, interpole manualmente (10x mais rápido que "interp1")
  I4=(ocvcol(I3)-OCV(1))/diffOCV; % usando interpolação linear
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  soc(I3)=SOC0(I5+1).*omI45 + SOC0(I5+2).*I45;
  soc(I3)=soc(I3) + tempcol(I3).*(SOCrel(I5+1).*omI45 + SOCrel(I5+2).*I45);
  soc(I6) = 0; % substitua NaN OCVs por zero SOC
  soc = reshape(soc,size(ocv)); % a saída tem a mesma forma que a entrada