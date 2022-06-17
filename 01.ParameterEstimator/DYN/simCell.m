% Algorítimo DYN
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
% função [vk,irk,hk,zk,sik,OCV] = simCell(ik,T,deltaT,model,z0,iR0,h0)
% 
% Simula o modelo ESC para corrente de entrada ik na temperatura T
%
% Entradas:  
%          ik - corrente, onde (+) é descarga
%          T  - temperatura (°C)
%          deltaT - intervalo de amostragem no dado (s)
%          model - estrutura do modelo padrão
%          z0 - estado de carga inicial
%          iR0 - corrente inicial do resistor como vetor coluna
%          h0 - estado de histerese inicial
% Saídas: 
%          vk - tensão na célula para todos os steps de tempo
%          irk - corrente no resistor (nas ramificações R-C branches) 
%                para todos os steps de tempo
%          hk - estados de histerese para todos os steps de tempo
%          zk - estado de carga para todos os steps de tempo
%          sik - histerese instantânea para todos os steps de tempo
%          OCV - tensão de circuito aberto para todos os steps de tempo


function [vk,irk,hk,zk,sik,OCV] = simCell(ik,T,deltaT,model,z0,iR0,h0)
  % Força os dados para serem vetores coluna
  ik = ik(:); iR0 = iR0(:);

  % Obtém os parâmetros do modelo da estrutura do modelo
  RCfact = exp(-deltaT./abs(getParamESC('RCParam',T,model)))';
  G = getParamESC('GParam',T,model);
  Q = getParamESC('QParam',T,model);
  M = getParamESC('MParam',T,model);
  M0 = getParamESC('M0Param',T,model);
  RParam = getParamESC('RParam',T,model);
  R0Param = getParamESC('R0Param',T,model);
  etaParam = getParamESC('etaParam',T,model);
  
  etaik = ik; 
  etaik(ik<0) = etaParam*ik(ik<0); % compesa a eficiência de Coulomb
  
  % Simula os estados dinâmicos do modelo
  if exist('ss','file'), % usa o método "control-system-toolbox", se disponível
    sysd= ss(diag(RCfact),1-RCfact,eye(length(RCfact)),0,-1);
    irk = lsim(sysd,etaik,[],iR0);
  else
    irk=zeros([length(ik) length(iR0)]); irk(1,:) = iR0;
    for k = 2:length(ik),
      irk(k) = RCfact.*irk(k-1) + (1-RCfact)*etaik(k-1);
    end
  end
  zk = z0-cumsum([0;etaik(1:end-1)])*deltaT/(Q*3600); 
  if any(zk>1.1),
    warning('Current may have wrong sign as SOC > 110%');
  end
  
  % Parte da histerese 
  hk=zeros([length(ik) 1]); hk(1) = h0; sik = 0*hk;
  fac=exp(-abs(G*etaik*deltaT/(3600*Q)));
  for k=2:length(ik),
    hk(k)=fac(k-1)*hk(k-1)-(1-fac(k-1))*sign(ik(k-1));
    sik(k) = sign(ik(k));
    if abs(ik(k))<Q/100, sik(k) = sik(k-1); end
  end
    
  % Calcula a equação de saída
  OCV = OCVfromSOCtemp(zk,T,model);
  vk = OCV - irk*RParam' - ik.*R0Param + M*hk + M0*sik;