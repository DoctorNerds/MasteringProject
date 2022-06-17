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
% --------------------------------------------------------------------
% fun��o processDynamic
%
% Nota t�cninca: PROCESSDYNAMIC assume que os testes com a bateria A123 
% j� foram executados para gerar os dados de entrada. 
% "makeMATfiles.m" converte o arquivo de dados do Excel para o formato "MAT" 
% os arquivos MATtem os campos de time, step, current, voltage, 
% chgAh, e disAh para cada run do script.
%
% Os resultados destes scripts s�o necess�rios para cada temperatura.  
% A seguir as etapas de cada um dos 3 scripts do teste DYN:
%   Script 1 (c�mara t�rmica ajustada para temperatura de teste):
%     Step 1: Repouso � @100% SOC para aclimatar � temperatura de teste
%     Step 2: Descarga � @1C para atingir @90% SOC
%     Step 3: Executa repetidamente os perfis din�micos (e possivelmente
%             repousos intermedi�rios) at� o SOC estar por volta de @10%
%   Script 2 (c�mara t�rmica ajustada para 25�C):
%     Step 1: Repouso � @10% SOC para aclimatar � 25�C
%     Step 2: Descarregue at� a tens�o m�nimca (ca. C/3)
%     Step 3: Repouso
%     Step 4: Tens�o constante em Vm�n (ca. C/30)
%     Steps 5-7: Aplicar um perfil de corrente oscilat�rio utilizado em desmagnetiza��o 
%     para minimizar o efeito da histerese
%     Step 8: Repouso
%   Script 3 (c�mara t�rmica ajustada para 25�C):
%     Step 2: Carrege � @1C para a tens�o m�xima
%     Step 3: Repouso
%     Step 4: Tens�o constante em Vm�x (ca. C/30)
%     Steps 5-7: Aplicar um perfil de corrente oscilat�rio utilizado em desmagnetiza��o 
%     para minimizar o efeito da histerese
%     Step 8: Repouso
% 
% Todas as outras etapas (se presentes) s�o ignoradas por PROCESSDYNAMIC 
% os passos entre os dados devem ser uniformes, n�s assumimos um per�odo de
% 1 segundo de amostra neste c�digo
%
% Entradas:
% - data: uma array, com uma entrada por temperatura a ser processada. 
%         uma das entradas da array deve estar a 2�C. Os campos de dados  
%         s�o: temp (temperatura de teste), script1, 
%         script 2 e script 3, onde estes �ltimos incluem dados
%         coletados de cada script. Os subcampos desses scripts
%         s�o os vetores: 
%         current, voltage, chgAh e disAh
% - model: A sa�da do processoOCV, compreendendo o modelo OCV
% - numpoles: N�mero de pares R-C neste modelo
% - doHyst: 0 se n�o desejamos um modelo de histerese, 1 se desejamos
%
% Sa�da:
% - model: Um modelo modificado, que agora cont�m os campos din�micos 
%          preenchidos.

function model = processDynamic(data,model,numpoles,doHyst)
  global bestcost
  
  % usado por "fminbnd" mais tarde
  if exist('optimset.m','file') 
    options=optimset('TolX',1e-8,'TolFun',1e-8,'MaxFunEval',100000, ...
      'MaxIter',1e6,'Jacobian','Off'); 
  end
    
  % ------------------------------------------------------------------
  % Step 1: Calcula a capacidade e a efici�ncia de Coulomb para cada teste
  % ------------------------------------------------------------------
  alltemps = [data(:).temp];
  alletas  = 0*alltemps;
  allQs    = 0*alltemps;
  
  ind25 = find(alltemps == 25); 
  if isempty(ind25),
    error('Must have a test at 25degC');
  end
  not25 = find(alltemps ~= 25);
  
  for k = ind25,    
    totDisAh = data(k).script1.disAh(end) + ...
               data(k).script2.disAh(end) + ...
               data(k).script3.disAh(end);
    totChgAh = data(k).script1.chgAh(end) + ...
               data(k).script2.chgAh(end) + ...
               data(k).script3.chgAh(end);
    eta25 = totDisAh/totChgAh; 
    data(k).eta = eta25; alletas(k) = eta25;
    data(k).script1.chgAh = data(k).script1.chgAh*eta25;
    data(k).script2.chgAh = data(k).script2.chgAh*eta25;
    data(k).script3.chgAh = data(k).script3.chgAh*eta25;    

    Q25 = data(k).script1.disAh(end) + data(k).script2.disAh(end) -...
          data(k).script1.chgAh(end) - data(k).script2.chgAh(end);
    data(k).Q = Q25; allQs(k) = Q25;
  end
  eta25 = mean(alletas(ind25));
  
  for k = not25,    
    data(k).script2.chgAh = data(k).script2.chgAh*eta25;
    data(k).script3.chgAh = data(k).script3.chgAh*eta25;
    eta = (data(k).script1.disAh(end) + data(k).script2.disAh(end)+...
           data(k).script3.disAh(end) - data(k).script2.chgAh(end)-...
           data(k).script3.chgAh(end))/data(k).script1.chgAh(end);
    data(k).script1.chgAh = eta*data(k).script1.chgAh;
    data(k).eta = eta; alletas(k) = eta;
    
    Q = data(k).script1.disAh(end) + data(k).script2.disAh(end) - ...
          data(k).script1.chgAh(end) - data(k).script2.chgAh(end);
    data(k).Q = Q; allQs(k) = Q;
  end
  
  model.temps    = unique(alltemps); numTemps = length(model.temps);
  model.etaParam = NaN(1,numTemps);
  model.QParam   = NaN(1,numTemps);
  for k = 1:numTemps,
    model.etaParam(k) = mean(alletas(alltemps == model.temps(k)));
    model.QParam(k)   = mean(allQs(alltemps == model.temps(k)));
  end
  
  % ------------------------------------------------------------------
  % Step 2: Calcula o OCV para cada "descarga" do teste
  % ------------------------------------------------------------------
  for k = 1:length(data),
    etaParam = model.etaParam(k);
    etaik = data(k).script1.current; 
    etaik(etaik<0)= etaParam*etaik(etaik<0);
    data(k).Z = 1 - cumsum([0,etaik(1:end-1)])*1/(data(k).Q*3600); 
    data(k).OCV = OCVfromSOCtemp(data(k).Z(:),alltemps(k),model);
  end
  
  % ------------------------------------------------------------------
  % Step 3: Otimiza��o
  % ------------------------------------------------------------------
  model.GParam  = NaN(1,numTemps); % Par�metro de histerese "gamma" 
  model.M0Param = NaN(1,numTemps); % Par�metro de histerese "M0" 
  model.MParam  = NaN(1,numTemps); % Par�metro de histerese "M" 
  model.R0Param = NaN(1,numTemps); % Par�metro de resist�ncia "R0" 
  model.RCParam = NaN(numTemps,numpoles); % Constante de tempo
  model.RParam  = NaN(numTemps,numpoles); % Par�metro Rk

  for theTemp = 1:numTemps, 
    fprintf('Processing temperature %d\n',model.temps(theTemp));
    bestcost = Inf;
%     theGammas = 1:5000;
%     theFit = zeros(size(theGammas));
%     for indGamma = 1:length(theGammas),
%       theFit(indGamma) = optfn(theGammas(indGamma),data,model,...
%                                model.temps(theTemp),doHyst);
%     end
%     figure(4); plot(theFit); stop
    if doHyst,
      if exist('fminbnd.m','file'),
        model.GParam(theTemp) = abs(fminbnd(@(x) optfn(x,data,...
                                  model,model.temps(theTemp),...
                                  doHyst),1,250,options));
      else
        model.GParam(theTemp) = abs(gss(@(x) optfn(x,data,...
                                  model,model.temps(theTemp),...
                                  doHyst),1,250,1e-8));
      end
    else
      model.GParam(theTemp) = 0;
      optfn(theGParam,data,model,model.temps(theTemp),doHyst);
    end
    [~,model] = minfn(data,model,model.temps(theTemp),doHyst);                          
  end
return

% --------------------------------------------------------------------
% Este "minfn" funciona para o modelo de c�lula de autocorre��o aprimorado
% (ESC)
% --------------------------------------------------------------------
function cost=optfn(theGParam,data,model,theTemp,doHyst)
  global bestcost 
  
  model.GParam(model.temps == theTemp) = abs(theGParam);
  [cost,model] = minfn(data,model,theTemp,doHyst);
  if cost<bestcost, % atualize o gr�fico dos par�metros do modelo para cada melhoria
    bestcost = cost;
    disp('Best ESC model values yet!');
    figure(3); theXlim = [min(model.temps) max(model.temps)];
                    plot(model.temps,model.QParam); 
                    %title('Capacity'); 
                    title('Par�metro Q - Capacidade de energia'); 
                    xlabel('Temperatura (�C)'); ylabel('(Ah)'); 
                    xlim(theXlim);
    figure(4);      plot(model.temps,1000*model.R0Param); 
                    %title('Resistance');
                    title('Par�metro R0 - Resist�ncia interna');
                    xlabel('Temperatura (�C)'); ylabel('(m\Omega)'); 
                    xlim(theXlim);
    figure(5);      plot(model.temps,1000*model.M0Param); 
                    %title('Hyst Magnitude M0');
                    title('Par�metro M0 - Histerese');
                    xlabel('Temperatura (�C)'); ylabel('(mV)'); 
                    xlim(theXlim);
    figure(6);      plot(model.temps,1000*model.MParam); 
                    %title('Hyst Magnitude M');
                    title('Par�metro M - Histerese');
                    xlabel('Temperatura (�C)'); ylabel('(mV)');
                    xlim(theXlim);
    figure(7);      plot(model.temps,getParamESC('RCParam',...
                    model.temps,model));
                    %title('RC Time Constant');
                    title('Par�metro RC - Constante de tempo');
                    xlabel('Temperatura (�C)'); ylabel('(tau)');
                    xlim(theXlim);
    figure(8);      plot(model.temps,1000*getParamESC('RParam',...
                    model.temps,model));
                    %title('R in RC');
                    title('Par�metro R - Resist�ncia RC');
                    xlabel('Temperatura (�C)'); ylabel('(m\Omega)');
                    xlim(theXlim);
    figure(9);      plot(model.temps,abs(model.GParam)); 
                    %title('Gamma');
                    title('Par�metro Gamma - Histerese');
                    xlabel('Temperatura (�C)'); ylabel('');
                    xlim(theXlim);
    figure(9);      plot(model.temps,abs(model.etaParam)); 
                    %title('Gamma');
                    title('Par�metro eta - Efici�ncia de Coulomb');
                    xlabel('Temperatura (�C)'); ylabel('');
                    xlim(theXlim);
  end
return

% --------------------------------------------------------------------
% Usando um valor assumido para gama (j� armazenado no modelo), encontre
% os valores �timos para os da c�lula restantes e calcule o erro RMS entre
% a tens�o da c�lula real e a prevista
% Using an assumed value for gamma (already stored in the model), find 
% optimum values for remaining cell parameters, and compute the RMS 
% error between true and predicted cell voltage
% --------------------------------------------------------------------
function [cost,model]=minfn(data,model,theTemp,doHyst)
  alltemps = [data(:).temp];
  ind = find(alltemps == theTemp); numfiles = length(ind);

  xplots = ceil(sqrt(numfiles));
  yplots = ceil(numfiles/xplots);
  rmserr = zeros(1,xplots*yplots);
  
  G = abs(getParamESC('GParam',theTemp,model));
  Q = abs(getParamESC('QParam',theTemp,model));
  eta = abs(getParamESC('etaParam',theTemp,model));
  RC = getParamESC('RCParam',theTemp,model);
  numpoles = length(RC);
  
  for thefile = 1:numfiles;
    ik = data(ind(thefile)).script1.current(:);
    vk = data(ind(thefile)).script1.voltage(:);
    tk = (1:length(vk))-1;
    etaik = ik; etaik(ik<0) = etaik(ik<0)*eta;

    h=0*ik; sik = 0*ik;
    fac=exp(-abs(G*etaik/(3600*Q)));
    for k=2:length(ik),
      h(k)=fac(k-1)*h(k-1)-(1-fac(k-1))*sign(ik(k-1));
      sik(k) = sign(ik(k));
      if abs(ik(k))<Q/100, sik(k) = sik(k-1); end
    end
    
    % Primeira etapa da modelagem: calcule o erro com o modelo
    vest1 = data(ind(thefile)).OCV;
    verr = vk - vest1;
    
    % Segunda etapa da modelagem: Calcule a constante de tempo na matriz A
    np = numpoles; 
    while 1,
      A = SISOsubid(-diff(verr),diff(etaik),np);
      eigA = eig(A); 
      eigA = eigA(eigA == conj(eigA));  % conferindo se real
      eigA = eigA(eigA > 0 & eigA < 1); % conferindo se no intervalo
      okpoles = length(eigA); np = np+1;
      if okpoles >= numpoles, break; end
      fprintf('Trying np = %d\n',np);
    end    
    RCfact = sort(eigA); RCfact = RCfact(end-numpoles+1:end);
    RC = -1./log(RCfact);
    % Simulando os filtros R-C para encontrar as correntes R-C
    if exist('dlsim.m','file') % na toolbox "control-system"
      vrcRaw = dlsim(diag(RCfact),1-RCfact,...
                   eye(numpoles),zeros(numpoles,1),etaik);
    else % uma solu��o um pouco mais lenta se n�o houver a toolbox "control-system"
      vrcRaw = zeros(length(RCfact),length(etaik));
      for vrcK = 1:length(etaik)-1,
        vrcRaw(:,vrcK+1) = diag(RCfact)*vrcRaw(:,vrcK)+(1-RCfact)*etaik(vrcK);
      end
      vrcRaw = vrcRaw';
    end

    % Terceira etapa da modelagem: Par�metros da histerese
    if doHyst,
      H = [h,sik,-etaik,-vrcRaw]; 
      if exist('lsqnonneg.m','file'), % na toolbox "optimization"
        W = lsqnonneg(H,verr); %  W = H\verr;    
      else
        W = nnls(H,verr); %  W = H\verr;    
      end
      M = W(1); M0 = W(2); R0 = W(3); Rfact = W(4:end)';
    else
      H = [-etaik,-vrcRaw]; 
      W = H\verr;    
      M=0; M0=0; R0 = W(1); Rfact = W(2:end)';
    end
    ind = find(model.temps == data(ind(thefile)).temp,1);
    model.R0Param(ind) = R0;
    model.M0Param(ind) = M0;
    model.MParam(ind) = M;
    model.RCParam(ind,:) = RC';
    model.RParam(ind,:) = Rfact';
    
    vest2 = vest1 + M*h + M0*sik - R0*etaik - vrcRaw*Rfact';
    verr = vk - vest2;
    
    % Plotando as tens�es
    figure(1); subplot(yplots,xplots,thefile); 
    plot(tk(1:10:end)/60,vk(1:10:end),tk(1:10:end)/60,...
         vest1(1:10:end),tk(1:10:end)/60,vest2(1:10:end));  
    xlabel('Time (min)'); ylabel('Voltage (V)'); 
    title(sprintf('Voltage and estimates at T=%d',...
                  data(ind(thefile)).temp));
    legend('voltage','vest1 (OCV)','vest2 (DYN)','location','southwest');

    % Plotando os erros de modelagem
    figure(2); subplot(yplots,xplots,thefile); 
    thetitle=sprintf('Modeling error at T = %d',data(ind(thefile)).temp);
    plot(tk(1:10:end)/60,verr(1:10:end)); title(thetitle);
    xlabel('Time (min)'); ylabel('Error (V)');
    ylim([-0.1 0.1]); 
    drawnow
    
    % Calculando o erro RMS apenas em dados com SOC 
    % aproximadamente de 5% a 95%
    v1 = OCVfromSOCtemp(0.95,data(ind(thefile)).temp,model);
    v2 = OCVfromSOCtemp(0.05,data(ind(thefile)).temp,model);
    N1 = find(vk<v1,1,'first'); N2 = find(vk<v2,1,'first');
    if isempty(N1), N1=1; end; if isempty(N2), N2=length(verr); end
    rmserr(thefile)=sqrt(mean(verr(N1:N2).^2));    
  end 

  cost=sum(rmserr); 
  fprintf('RMS error = %0.2f (mV)\n',cost*1000);
  if isnan(cost), stop, end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A = SISOsubid(y,u,n);
%  Identifica a matriz estado de espa�o A dos dados de entrada e sa�da.
%     y: vetor de sa�das medidas
%     u: vetor de entradas medidas
%     n: n�mero de p�los na solu��o
%           
%     A: matriz de transi��o de estado de espa�o em tempo discreto
%
%  A teoria desta aplica��o foi retirada do:                 
%               "Subspace Identification for Linear Systems
%               Theory - Implementation - Applications" 
%               Peter Van Overschee / Bart De Moor (VODM)
%               Kluwer Academic Publishers, 1996
%               Combined algorithm: Figure 4.8 page 131 (robust)
%               Robust implementation: Figure 6.1 page 169"
%
%  E o c�digo adaptado do "subid.m" do:
%               "Subspace Identification for 
%               Linear Systems" toolbox on MATLAB CENTRAL file 
%               exchange, originally by Peter Van Overschee, Dec. 1995"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = SISOsubid(y,u,n)
  y = y(:); y = y'; ny = length(y); % transformando y em um vetor linha
  u = u(:); u = u'; nu = length(u); % transformando u em um vetor linha
  i = 2*n; % #linhas na matriz de Hankel. Usualmente: i=2*(ordem m�xima)
  twoi = 4*n;           

  if ny ~= nu, error('y and u must be same size'); end
  if ((ny-twoi+1) < twoi); error('Not enough data points'); end

  % Determine the number of columns in the Hankel matrices
  % Determinando o n�mero de colunas da matriz de Hankel
  j = ny-twoi+1;

  % Fazendo as matrizes de Hankel Y e U
  Y=zeros(twoi,j); U=zeros(twoi,j);
  for k=1:2*i
    Y(k,:)=y(k:k+j-1); U(k,:)=u(k:k+j-1);
  end
  % Calculando o fator R
  R = triu(qr([U;Y]'))'; % fator R
  R = R(1:4*i,1:4*i); 	

  % ------------------------------------------------------------------
  % STEP 1: Calcular proje��es obl�quas e ortogonais
  % ------------------------------------------------------------------
  Rf = R(3*i+1:4*i,:);              % sa�das futuras
  Rp = [R(1:1*i,:);R(2*i+1:3*i,:)]; % entradas e sa�das anteriores
  Ru  = R(1*i+1:2*i,1:twoi); 	      % sa�das futuras
  % Sa�das futuras perpendiculares
  Rfp = [Rf(:,1:twoi) - (Rf(:,1:twoi)/Ru)*Ru,Rf(:,twoi+1:4*i)]; 
  % Entradas e sa�das perpendiculares anteriores
  Rpp = [Rp(:,1:twoi) - (Rp(:,1:twoi)/Ru)*Ru,Rp(:,twoi+1:4*i)]; 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % A proje��o obl�qua � calculada como (6.1) em VODM, p�gina 166.
  % obl/Ufp = Yf/Ufp * pinv(Wp/Ufp) * (Wp/Ufp)
  % A proje��o extra em Ufp (Uf perpendicular) tende a dar um 
  % melhor condicionamento num�rico (ver algo em VODM p�gina 131)
  % Esta verifica��o � necess�ria para evitar avisos de defici�ncia 
  % de classifica��o
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if (norm(Rpp(:,3*i-2:3*i),'fro')) < 1e-10
    Ob = (Rfp*pinv(Rpp')')*Rp; 	% Proje��o obl�qua
  else
    Ob = (Rfp/Rpp)*Rp;
  end

  % ------------------------------------------------------------------
  % STEP 2: Calculando a proje��o obliqua ponderada e suaa proje��o 
  %         SVD extra de 0b na Uf perpendicular
  % ------------------------------------------------------------------
  WOW = [Ob(:,1:twoi) - (Ob(:,1:twoi)/Ru)*Ru,Ob(:,twoi+1:4*i)];
  [U,S,~] = svd(WOW);
  ss = diag(S);

  % ------------------------------------------------------------------
  % STEP 3: Particionando U em U1 e U2 (o �ltimo n�o � usado)
  % ------------------------------------------------------------------
  U1 = U(:,1:n); % Determine U1

  % ------------------------------------------------------------------
  % STEP 4: Determine gam = Gamma(i) e gamm = Gamma(i-1) 
  % ------------------------------------------------------------------
  gam  = U1*diag(sqrt(ss(1:n)));
  gamm = gam(1:(i-1),:);
  gam_inv  = pinv(gam); 			% Pseudo inverso de gam
  gamm_inv = pinv(gamm); 			% Pseudo inverso de gamm

  % ------------------------------------------------------------------
  % STEP 5: Determine a matriz A (tamb�m C, que n�o � usada) 
  % ------------------------------------------------------------------
  Rhs = [gam_inv*R(3*i+1:4*i,1:3*i),zeros(n,1); R(i+1:twoi,1:3*i+1)];
  Lhs = [gamm_inv*R(3*i+1+1:4*i,1:3*i+1); R(3*i+1:3*i+1,1:3*i+1)];
  sol = Lhs/Rhs;    % Resolve o m�nimo quadrado para [A;C]
  A = sol(1:n,1:n); % Extrai A
return

function X = gss(f,a,b,tol)
  % pesquisa para encontrar o m�nimo de f em [a, b]
  % baseada no c�digo: https://en.wikipedia.org/wiki/Golden-section_search
  gr = (sqrt(5)+1)/2; % "golden ratio" usado na pesquisa

  c = b - (b - a) / gr;
  d = a + (b - a) / gr;
  while abs(c - d) > tol
    if f(c) < f(d),
      b = d;
    else
      a = c;
    end
    
    % recalculamos c e d aqui para evitar perda de precis�o o que 
    % pode levar a resultados incorretor ou loop infinito
    c = b - (b - a) / gr;
    d = a + (b - a) / gr;
  end
  X = (b+a)/2;
return

function [x,w,info]=nnls(C,d,opts)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  Direitos autorais desta parte do c�digo
  %  "nnls"  M�nimos quadrados n�o negativos Cx=d x>=0 w=C'(d-Cx)<=0
  %  2012-08-21  Matlab8  W.Whiten
  %  2013-02-17  Line 52 added
  %  Copyright (C) 2012, W.Whiten (personal W.Whiten@uq.edu.au) BSD license
  %  (http://opensource.org/licenses/BSD-3-Clause)
  %
  % [x,w,info]=nnls(C,d,opts)
  %  C    Coeficiente da matriz
  %  d    Vetor Rhs
  %  "opts" Op��es da estrutura: (opcional)
  %        .Accy  0 vers�o r�pida, 1 refina o valor final (padr�o), 
  %                 2 usa passos precisos, mas � muito lenta em casos
  %                 grandes, r�pida em casos pequenos, resultado geralmente
  %                 identico ao 1
  %        .Order Verdadeiro ou [], ou ordem para incluir inicialmente 
  %                 termos positivos se inclu�do fornecer� informa��es. 
  %                 Se x0 dispon�vel use find(x0>0), mas � melhor salvar 
  %                 da execu��o anterior de nnls
  %        .Tol   Valor do teste de toler�ncia, padr�o � zero
  %        .Iter  N�mero m�ximo de intera��es, n�o deve ser necess�rio.
  %
  %  x    Vetor de solu��o positiva x>=0
  %  w    Vetor multiplicador de Lagrange w(x==0)<= aproximadamente zero
  %  Informa��o extra da estrutura: 
  %        .iter  N�mero de intera��es usadas
  %        .wsc0  Tamanho estimado de erros em w
  %        .wsc   M�ximo de valores de teste para w
  %        .Order Vari�veis de pedido usadas, use para reiniciar "nnls"
  %                com "opts.Order"
  %
  % Existe com x>=0 e w<= zero ou ligeiramente acima de 0 devido ao 
  % arredondamento e para garantir a converg�ncia
  % Usando opera��es matriciais mais r�pidas, refina a resposta 
  % como padr�o (Accy 1).
  % Accy 0 � mais robusto em casos singulares.
  %
  % Follows Lawson & Hanson, Solving Least Squares Problems, Ch 23.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [~,n]=size(C);
  maxiter=4*n;

  % valores iniciais
  P=false(n,1);
  x=zeros(n,1);
  z=x;

  w=C'*d;

  % wsc_ s�o escalas para erros
  wsc0=sqrt(sum(w.^2));
  wsc=zeros(n,1);
  tol=3*eps;
  accy=1;
  pn1=0;
  pn2=0;
  pn=zeros(1,n);

  % veja se os valores das op��es foram dados
  ind=true;
  if(nargin>2)
    if(isfield(opts,'Tol'))
      tol=opts.Tol;
      wsc(:)=wsc0*tol;
    end
    if(isfield(opts,'Accy'))
      accy=opts.Accy;
    end
    if(isfield(opts,'Iter'))
      maxiter=opts.Iter;
    end
  end

  % testa se usa a matriz normal para velocidade
  if(accy<2)
    A=C'*C;
    b=C'*d;
    %L=zeros(n,n);
    LL=zeros(0,0);
    lowtri=struct('LT',true);
    uptri=struct('UT',true);
  end

  % testa se informa��es iniciais fornecidas
  if(nargin>2)
    if(isfield(opts,'Order') && ~islogical(opts.Order))
      pn1=length(opts.Order);
      pn(1:pn1)=opts.Order;
      P(pn(1:pn1))=true;
      ind=false;
    end
    if(~ind && accy<2)
      %L(1:pn1,1:pn1)=chol(A(pn(1:pn1),pn(1:pn1)),'lower');
      UU(1:pn1,1:pn1)=chol(A(pn(1:pn1),pn(1:pn1)));
      LL=UU';
    end
    pn2=pn1;
  end

  % loop at� que todas as vari�veis possitivas sejam adicionadas
  iter=0;
  while(true)
    % Verifica se n�o tem mais termos a serem adicionados
    if(ind && (all(P==true) || all(w(~P)<=wsc(~P))))
      if(accy~=1)
        break
      end
      accy=2;
      ind=false;
    end
    
    % pula se primeira vez e ordem inicial foram dadas
    if(ind)
      % seleciona o melhor termo para adicionar
      ind1=find(~P);
      [~,ind2]=max(w(ind1)-wsc(ind1));
      ind1=ind1(ind2);
      P(ind1)=true;
      pn2=pn1+1;
      pn(pn2)=ind1;
    end

    % loop at� que todos os termos negativos sejam removidos
    while(true)

      % verifica a diverg�ncia
      iter=iter+1;
      if(iter>=2*n)
        if(iter>maxiter)
          error(['nnls Failed to converge in ' num2str(iter)  ...
              ' iterations'])
        elseif(mod(iter,n)==0)
          wsc=(wsc+wsc0*tol)*2;
        end
      end

      % resolver usando "suspected positive terms"
      z(:)=0;
      if(accy>=2)
        z(P)=C(:,P)\d;
      else
        % adicionar uma linha ao fator triangular inferior  
        for i=pn1+1:pn2
          i1=i-1;
          %LL=L(1:i1,1:i1);
          %LL=LL(1:i1,1:i1);
          t=linsolve(LL,A(pn(1:i1),pn(i)),lowtri);
          %t=LL\A(pn(1:i1),pn(i));
          %L(i,1:i1)=t;
          %LL(i,1:i1)=t;
          AA=A(pn(i),pn(i));
          tt=AA-t'*t;
          if(tt<=AA*tol)
              tt=1e300;
          else
              tt=sqrt(tt);
          end
          %L(i,i)=sqrt(tt);
          %LL(i,i)=sqrt(tt);
          LL(i,1:i)=[t',tt];
          UU(1:i,i)=[t;tt];
        end

        % resolver usando o fator triangular inferior
        %LL=L(1:pn2,1:pn2);
        t=linsolve(LL,b(pn(1:pn2)),lowtri);
        %t=LL\b(pn(1:pn2));
        %UU=LL';
        %z(pn(1:pn2))=linsolve(UU,t,uptri);
        z(pn(1:pn2))=linsolve(UU,t,uptri);
        %z(pn(1:pn2))=LL'\t;
        % ou podemos usar isso para resolver sem atualizar os fatores
        %z(pn(1:pn2))=A(pn(1:pn2),pn(1:pn2))\b(pn(1:pn2));
      end
      pn1=pn2;

      % checando se os termos s�o positivos
      if(all(z(P)>=0))
        x=z;
        if(accy<2)
          w=b-A*x;
        else
          w=C'*(d-C*x);
        end
        wsc(P)=max(wsc(P),2*abs(w(P)));
        ind=true;
        break
      end

      % seleciona e remove o pior termo negativo
      ind1=find(z<0);
      [alpha,ind2]=min(x(ind1)./(x(ind1)-z(ind1)+realmin));
      ind1=ind1(ind2);

      % testa se removendo o �ltimo adicionado, aumenta "wsc" para evitar
      % loop
      if(x(ind1)==0 && ind)
        w=C'*(d-C*z);
        wsc(ind1)=(abs(w(ind1))+wsc(ind1))*2;
      end
      P(ind1)=false;
      x=x-alpha*(x-z);
      pn1=find(pn==ind1);
      pn(pn1:end)=[pn(pn1+1:end),0];
      pn1=pn1-1;
      pn2=pn2-1;
      if(accy<2)
        LL=LL(1:pn1,1:pn1);
        UU=UU(1:pn1,1:pn1);
      end
      ind=true;
    end
  end

  % resultado de informa��o necess�rio
  if(nargout>2)
    info.iter=iter;
    info.wsc0=wsc0*eps;
    info.wsc=max(wsc);
    if(nargin>2 && isfield(opts,'Order'))
      info.Order=pn(1:pn1);
    end
  end

return

