% Algor�timo SPKF
%
% Este arquivo foi utilizado no projeto de mestrado do aluno F�bio Mori.
% O algoritmo aplicado neste projeto est� protegido por direitos autorais
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
% fun��o soc = SOCfromOCVtemp(ocv,temp,model)
%
% Calcula o estado de carga aproximado da tens�o de circuito aberto
% totalmente em repouso da c�lula a uma dada temperatura. Este n�o �
% exatamente o inverso da fun��o OCVfromSOCtemp devido � forma como os
% c�lculos s�o feitos, mas est� "bastante pr�ximo".
%
% Entradas: 
%        ocv = escalar ou matriz de tens�es de circuito aberto da c�lula
%        temp = escalar ou matriz de temperaturas em que calcular o OCV
%        model = estrutura de dados produzida pelo processDynamic
% Sa�das: 
%        soc = escalar ou matriz dos estados de carga -- uma para cada
%              ponto de entrada de soc e temperatura

function soc=SOCfromOCVtemp(ocv,temp,model)
  ocvcol = ocv(:); % for�a ocv para ser um vetor coluna
  OCV = model.OCV(:); % for�a para ser um vetor coluna
  SOC0 = model.SOC0(:); % for�a para ser um vetor coluna
  SOCrel = model.SOCrel(:); % for�a para ser um vetor coluna
  if isscalar(temp), % replica uma temperatura escalar para todos ocvs
    tempcol = temp*ones(size(ocvcol)); 
  else % for�a a matriz de temperatura para ser um vetor coluna
    tempcol = temp(:); 
    if ~isequal(size(tempcol),size(ocvcol)),
      error(['Function inputs "ocv" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']);
    end    
  end
  diffOCV=OCV(2)-OCV(1); % espa�amento entre pontos OCV - assuma uniforme
  soc=zeros(size(ocvcol)); % inicializa a sa�da para zero
  I1=find(ocvcol <= OCV(1)); % �ndices de ocvs abaixo dos dados armazenados no modelo
  I2=find(ocvcol >= OCV(end)); % e de ocvs acima dos dados armazenados no modelo
  I3=find(ocvcol > OCV(1) & ocvcol < OCV(end)); % o restante deles
  I6=isnan(ocvcol); % se a entrada for "n�o um n�mero" para qualquer local

  % para ocvs abaixo da menor tens�o, extrapole a parte de baixo da tabela
  if ~isempty(I1),
    dz = (SOC0(2)+tempcol.*SOCrel(2)) - (SOC0(1)+tempcol.*SOCrel(1));
    soc(I1)= (ocvcol(I1)-OCV(1)).*dz(I1)/diffOCV + ...
             SOC0(1)+tempcol(I1).*SOCrel(1);
  end
  
  % para ocvs acima da menor tens�o, extrapole a parte de cima da tabela
  if ~isempty(I2),
    dz = (SOC0(end)+tempcol.*SOCrel(end)) - ...
         (SOC0(end-1)+tempcol.*SOCrel(end-1));
    soc(I2) = (ocvcol(I2)-OCV(end)).*dz(I2)/diffOCV + ...
              SOC0(end)+tempcol(I2).*SOCrel(end);
  end
  
  % para faixa normal de ocv, interpole manualmente (10x mais r�pido que "interp1")
  I4=(ocvcol(I3)-OCV(1))/diffOCV; % usando interpola��o linear
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  soc(I3)=SOC0(I5+1).*omI45 + SOC0(I5+2).*I45;
  soc(I3)=soc(I3) + tempcol(I3).*(SOCrel(I5+1).*omI45 + SOCrel(I5+2).*I45);
  soc(I6) = 0; % substitua NaN OCVs por zero SOC
  soc = reshape(soc,size(ocv)); % a sa�da tem a mesma forma que a entrada