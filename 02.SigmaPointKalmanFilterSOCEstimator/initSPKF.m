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
% fun��o spkfData = initSPKF(v0,T0,SigmaX0,SigmaV,SigmaW,model)
%
%    Inicializa uma estrutura "spkfData", usada pelo filtro de Kalman ponto
%    sigma para armazenar seu pr�prio estado e dados associados
%
% Entradas:
%   v0: Tens�o inicial da c�lula
%   T0: Temperatura inicial da c�lula
%   SigmaX0: Matriz de covariancia de incerteza de estado inicial
%   SigmaV: Covari�ncia do ru�do de medi��o
%   SigmaW: Covari�ncia do ru�do de processo
%   model: modelo ESC da c�lula
%
% Sa�da:
%   spkfData: Estrutura de dados usados pelo c�digo SPKF

function spkfData = initSPKF(v0,T0,SigmaX0,SigmaV,SigmaW,model)
  % Descri��o do estado inicial
  ir0   = 0;                           spkfData.irInd = 1;
  hk0   = 0;                           spkfData.hkInd = 2;
  SOC0  = SOCfromOCVtemp(v0,T0,model); spkfData.zkInd = 3;
  spkfData.xhat  = [ir0 hk0 SOC0]'; % estado inicial

  % Valores de covari�ncia
  spkfData.SigmaX = SigmaX0;
  spkfData.SigmaV = SigmaV;
  spkfData.SigmaW = SigmaW;
  spkfData.Snoise = real(chol(diag([SigmaW; SigmaV]),'lower'));
  spkfData.Qbump = 5;
  
  % par�metros espec�ficos do SPKF
  Nx = length(spkfData.xhat); spkfData.Nx = Nx; % comprimento do vetor de estado
  Ny = 1; spkfData.Ny = Ny; % comprimento do vetor de medi��o
  Nu = 1; spkfData.Nu = Nu; % comprimento do vetor de entrada
  Nw = size(SigmaW,1); spkfData.Nw = Nw; % comprimento do vetor de ru�do de processo
  Nv = size(SigmaV,1); spkfData.Nv = Nv; % comprimento do vetor de ru�do do sensor
  Na = Nx+Nw+Nv; spkfData.Na = Na;     % comprimento do vetor de estado aumentado
  
  h = sqrt(3); spkfData.h = h; % fator de sintonia SPKF/CDKF  
  Weight1 = (h*h-Na)/(h*h); % fatores de pondera��o ao calcular a m�dia 
  Weight2 = 1/(2*h*h);      % e a covari�ncia
  spkfData.Wm = [Weight1; Weight2*ones(2*Na,1)]; % m�dia
  spkfData.Wc = spkfData.Wm;                     % covari�ncia
  
  % valor pr�vio da corrente
  spkfData.priorI = 0;
  spkfData.signIk = 0;
  
  % armazene a estrutura de dados do modelo tamb�m
  spkfData.model = model;