% Algor�timo DYN
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
%
% fun��o ocv = OCVfromSOCtemp(soc,temp,model)
%
% Calcula a tens�o de circuito aberto totalmente em repouso para um estado
% particular de carga e temperatura
%
% Entradas: 
%        soc = estado de carga
%        temp = temperaturas
%        model = estrutura de dados produzida pela fun��o processDynamic
% Sa�da: 
%        ocv = tens�o de circuito aberto

function ocv=OCVfromSOCtemp(soc,temp,model)
  soccol = soc(:); % transforma a entrada soc em um vetor coluna
  SOC = model.SOC(:); % transforma a entrada model.SOC em um vetor coluna
  OCV0 = model.OCV0(:); % transforma a entrada model.OCV0 em um vetor coluna
  OCVrel = model.OCVrel(:); % transforma a entrada model.OCVrel em um vetor coluna
  if isscalar(temp), % replicar uma temperatura escalar para todos os socs
    tempcol = temp*ones(size(soccol)); 
  else
    tempcol = temp(:); % transforma a entrada temp em um vetor coluna
    if ~isequal(size(tempcol),size(soccol)),
      error(['Function inputs "soc" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']); % mensagem se erro
    end
  end
  diffSOC=SOC(2)-SOC(1); % espa�amento entre os pontos SOC
  ocv=zeros(size(soccol)); % Inicializa a vari�vel de sa�da ocv vazia
  I1=find(soccol <= SOC(1)); % �ndices de socs abaixo dos dados armazenados no modelo
  I2=find(soccol >= SOC(end)); % �ndices de socs acima dos dados armazenados no modelo
  I3=find(soccol > SOC(1) & soccol < SOC(end)); % o restante dos dados
  I6=isnan(soccol); % se a entrada for "n�o � um n�mero" para qualquer local

  % extrapolar o c�lculo de ocv para tens�es menores que o ponto de 
  % SOC mais baixo 
  if ~isempty(I1),
    dv = (OCV0(2)+tempcol.*OCVrel(2)) - (OCV0(1)+tempcol.*OCVrel(1));
    ocv(I1)= (soccol(I1)-SOC(1)).*dv(I1)/diffSOC + ...
             OCV0(1)+tempcol(I1).*OCVrel(1);
  end

  % extrapolar o c�lculo de ocv para tens�es maiores que o ponto de 
  % SOC mais alto
  if ~isempty(I2),
    dv = (OCV0(end)+tempcol.*OCVrel(end)) - ...
         (OCV0(end-1)+tempcol.*OCVrel(end-1));
    ocv(I2) = (soccol(I2)-SOC(end)).*dv(I2)/diffSOC + ...
              OCV0(end)+tempcol(I2).*OCVrel(end);
  end
  
  % para intervalo soc normal, interpolar manualmente (mais r�pido que
  % "interp1")
  I4=(soccol(I3)-SOC(1))/diffSOC; % interpola��o linear
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  ocv(I3)=OCV0(I5+1).*omI45 + OCV0(I5+2).*I45;
  ocv(I3)=ocv(I3) + tempcol(I3).*(OCVrel(I5+1).*omI45 + OCVrel(I5+2).*I45);
  ocv(I6)=0; % substituir NaN SOCs com tens�o zero
  ocv = reshape(ocv,size(soc)); % define a sa�da com a mesma forma que a entrada