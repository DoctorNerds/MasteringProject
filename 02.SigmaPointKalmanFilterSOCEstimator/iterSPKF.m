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
% função [zk,zkbnd,spkfData] = iterSPKF(vk,ik,Tk,deltat,spkfData)
%
%    Executa uma interação do filtro de Kalman ponto-sigma usando a nova
%    medição de dados
%
% Entradas:
%   vk: tensão da célula medida (ruidosa) presente
%   ik: corrente da célula medida (ruidosa) presente
%   Tk: temperatura presente
%   deltat: intervalo de amostragem
%   spkfData: estrutura de dados inicializa pelo "initSPKF" e 
%             atualizada pelo "iterSPKF".
%
% Saídas:
%   zk: SOC estimado para esta amostra de tempo
%   zkbnd: limites de estimativa "3-sigma"
%   spkfData: estrutura de dados usados para armazentar variáveis

function [zk,zkbnd,spkfData] = iterSPKF(vk,ik,Tk,deltat,spkfData)
  model = spkfData.model;
  % Carrega os parâmetros do modelo da célula
  Q  = getParamESC('QParam',Tk,model);
  G  = getParamESC('GParam',Tk,model);
  M  = getParamESC('MParam',Tk,model);
  M0 = getParamESC('M0Param',Tk,model);
  RC = exp(-deltat./abs(getParamESC('RCParam',Tk,model)))';
  R  = getParamESC('RParam',Tk,model)';
  R0 = getParamESC('R0Param',Tk,model);
  eta = getParamESC('etaParam',Tk,model);
  if ik<0, ik=ik*eta; end;
  
  % Obtém os dados armazenados na estrutura "spkfData"
  I = spkfData.priorI;
  SigmaX = spkfData.SigmaX;
  xhat = spkfData.xhat;
  Nx = spkfData.Nx;
  Nw = spkfData.Nw;
  Nv = spkfData.Nv;
  Na = spkfData.Na;
  Snoise = spkfData.Snoise;
  Wc = spkfData.Wc;
  irInd = spkfData.irInd;
  hkInd = spkfData.hkInd;
  zkInd = spkfData.zkInd;
  if abs(ik)>Q/100, spkfData.signIk = sign(ik); end;
  signIk = spkfData.signIk;
  
  % Step 1a: Atualiza o tempo de estimativa de estado
  %          - Cria os pontos SigmaX aumentados "xhatminus"
  %          - Extrai pontos SigmaX do estado "xhatminus"
  %          - Calcula média ponderada "xhatminus (k)"

  % Step 1a-1: Cria SigmaX e xhat aumentados
  [sigmaXa,p] = chol(SigmaX,'lower'); 
  if p>0,
    fprintf('Cholesky error.  Recovering...\n');
    theAbsDiag = abs(diag(SigmaX));
    sigmaXa = diag(max(SQRT(theAbsDiag),SQRT(spkfData.SigmaW)));
  end
  sigmaXa=[real(sigmaXa) zeros([Nx Nw+Nv]); zeros([Nw+Nv Nx]) Snoise];
  xhata = [xhat; zeros([Nw+Nv 1])];
  % NOTA: sigmaXa é triangular inferior

  % Step 1a-2: Calcula pontos SigmaX (indexação estranha de xhata para
  % evitar a chamada "repmat", que é muito ineficiente no MATLAB)
  Xa = xhata(:,ones([1 2*Na+1])) + ...
       spkfData.h*[zeros([Na 1]), sigmaXa, -sigmaXa];

  % Step 1a-3: Atualiza o tempo da última interação até agora
  %     stateEqn(xold,current,xnoise)
  Xx = stateEqn(Xa(1:Nx,:),I,Xa(Nx+1:Nx+Nw,:)); 
  xhat = Xx*spkfData.Wm;
  xhat(hkInd) = min(1,max(-1,xhat(hkInd)));
  xhat(zkInd) = min(1.05,max(-0.05,xhat(zkInd)));

  % Step 1b: Atualização do tempo de covariância de erro
  %          - Calcula a covariância ponderada "sigmaminus(k)"
  %            (indexação estranha de xhat para evitar a chamada "repmat")
  Xs = Xx - xhat(:,ones([1 2*Na+1]));
  SigmaX = Xs*diag(Wc)*Xs';
  
  % Step 1c: Estimativa de saída
  %          - Calcula a estimativa de saída ponderada "yhat(k)"
  I = ik; yk = vk;
  Y = outputEqn(Xx,I+Xa(Nx+1:Nx+Nw,:),Xa(Nx+Nw+1:end,:),Tk,model);
  yhat = Y*spkfData.Wm;

  % Step 2a: Matriz de ganho estimado
  Ys = Y - yhat(:,ones([1 2*Na+1]));
  SigmaXY = Xs*diag(Wc)*Ys';
  SigmaY = Ys*diag(Wc)*Ys';
  L = SigmaXY/SigmaY; 

  % Step 2b: Atualização da medição da estimativa do estado
  r = yk - yhat; % residual.  Use para verificar erros do sensor...
  if r^2 > 100*SigmaY, L(:,1)=0.0; end 
  xhat = xhat + L*r; 
  xhat(zkInd)=min(1.05,max(-0.05,xhat(zkInd)));
  
  % Step 2c: Atualização de medição de covariância de erro
  SigmaX = SigmaX - L*SigmaY*L';
  [~,S,V] = svd(SigmaX);
  HH = V*S*V';
  SigmaX = (SigmaX + SigmaX' + HH + HH')/4; % ajuda a manter robustez
  
  % Código Q-bump
  if r^2>4*SigmaY % estimativa ruim de tensão por (2-sigmaY), "bump Q" 
    fprintf('Bumping sigmax\n');
    SigmaX(zkInd,zkInd) = SigmaX(zkInd,zkInd)*spkfData.Qbump;
  end
  
  % Salva os dados na estrutura "spkfData" spara a próxima vez...
  spkfData.priorI = ik;
  spkfData.SigmaX = SigmaX;
  spkfData.xhat = xhat;
  zk = xhat(zkInd);
  zkbnd = 3*sqrt(SigmaX(zkInd,zkInd));
  
  % Calcula novos estados para todos vetores de estados antigos em "xold"
  function xnew = stateEqn(xold,current,xnoise)
    current = current + xnoise; % ruído adicionado a corrente
    xnew = 0*xold;
    xnew(irInd,:) = RC*xold(irInd,:) + (1-RC)*current;
    Ah = exp(-abs(current*G*deltat/(3600*Q)));  % fator de histerese
    xnew(hkInd,:) = Ah.*xold(hkInd,:) + (Ah-1).*sign(current);
    xnew(zkInd,:) = xold(zkInd,:) - current*deltat/(3600*Q);
  end

  % Calcula a tensão de saída da célula para todos os vetores de estado em 
  % "xhat"
  function yhat = outputEqn(xhat,current,ynoise,T,model)
    yhat = OCVfromSOCtemp(xhat(zkInd,:),T,model);
    yhat = yhat + M*xhat(hkInd,:) + M0*signIk;
    yhat = yhat - R*xhat(irInd,:) - R0*current + ynoise(1,:);
  end

  % Raíz quadrada "segura"
  function X = SQRT(x)
    X = sqrt(max(0,x));
  end
end