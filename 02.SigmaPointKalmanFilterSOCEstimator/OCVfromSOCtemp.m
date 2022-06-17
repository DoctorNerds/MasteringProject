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
% função ocv = OCVfromSOCtemp(soc,temp,model)
%
% Calcula a tensão de circuito aberto em repouso total para um estado 
% particular de carga e temperatura
%
% Entradas: 
%        soc = escalar ou matriz dos pontos de estado de carga da célula 
%        temp = escalar ou matriz de temperaturas nas quais calcular OCV
%        model = estrutura de dados produzida pelo "processDynamic"
% Saída: ocv = escalar ou matriz das tensões de circuito aberto -- uma para 
%              cada ponto de entrada de soc e temperatura

function ocv=OCVfromSOCtemp(soc,temp,model)
  soccol = soc(:); % força soc para ser um vetor coluna
  SOC = model.SOC(:); % força para ser um vetor coluna
  OCV0 = model.OCV0(:); % força para ser um vetor coluna
  OCVrel = model.OCVrel(:); % força para ser um vetor coluna
  if isscalar(temp), % replica uma temperatura escalar para todos socs
    tempcol = temp*ones(size(soccol)); 
  else
    tempcol = temp(:); % força a matriz de temperatura para ser um vetor coluna
    if ~isequal(size(tempcol),size(soccol)),
      error(['Function inputs "soc" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']);
    end
  end
  diffSOC=SOC(2)-SOC(1); % espaçamento entre pontos SOC - assuma uniforme
  ocv=zeros(size(soccol)); % inicializa a saída para zero
  I1=find(soccol <= SOC(1)); % índices de socs abaixo dos dados armazenados no modelo
  I2=find(soccol >= SOC(end)); % e de socs acima dos dados armazenados no modelo
  I3=find(soccol > SOC(1) & soccol < SOC(end)); % o restante deles
  I6=isnan(soccol); % se a entrada for "não um número" para qualquer local

  % para tensões menores que o ponto de dados mais baixo de soc armazenado, 
  % extrapole fora da extremidade inferior da tabela
  if ~isempty(I1),
    dv = (OCV0(2)+tempcol.*OCVrel(2)) - (OCV0(1)+tempcol.*OCVrel(1));
    ocv(I1)= (soccol(I1)-SOC(1)).*dv(I1)/diffSOC + ...
             OCV0(1)+tempcol(I1).*OCVrel(1);
  end

  % para tensões maiores que o ponto de dados mais alto de soc armazenado,
  % extrapole fora da extremidade superior da tabela
  if ~isempty(I2),
    dv = (OCV0(end)+tempcol.*OCVrel(end)) - ...
         (OCV0(end-1)+tempcol.*OCVrel(end-1));
    ocv(I2) = (soccol(I2)-SOC(end)).*dv(I2)/diffSOC + ...
              OCV0(end)+tempcol(I2).*OCVrel(end);
  end

  % para faixa normal de ocv, interpole manualmente (10x mais rápido que "interp1")
  I4=(soccol(I3)-SOC(1))/diffSOC; % usando interpolação linear
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  ocv(I3)=OCV0(I5+1).*omI45 + OCV0(I5+2).*I45;
  ocv(I3)=ocv(I3) + tempcol(I3).*(OCVrel(I5+1).*omI45 + OCVrel(I5+2).*I45);
  ocv(I6)=0; % subtitua NaN SOCs por zero tensão
  ocv = reshape(ocv,size(soc)); % a saída tem a mesma forma que a entrada