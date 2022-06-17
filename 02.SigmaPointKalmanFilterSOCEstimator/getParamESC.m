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
%
% fun��o theParam = getParamESC(paramName,temperature,model)
%
% Essa fun��o retorna os valores dos par�metros do modelo de c�lula ESC 
% especificado 'paramName', para as temperaturas em 'temperature' e para
% os dados do modelo de c�lula armazenados em 'model'.
%
% No modelo ESC padr�o, 'paramName' pode ser:
%    'QParam', 'RCParam', 'RParam', 'R0Param', 'MParam', 'M0Param',
%    'etaParam', or 'GParam' 
% (n�o diferencia letras mai�sculas)
%

function theParam = getParamESC(paramName,temp,model)
  theFields = fields(model); % obter lista de campos armazenados no modelo
  match = strcmpi(paramName,theFields); % veja se algum corresponde aos dados desejados
  if ~match, % se n�o, reporte um erro
    error('Parameter "%s" does not exist in model',paramName);
  end
  fieldName = char(theFields(match)); % nome do campo que diferencia mai�sculas de min�sculas

  % se o modelo contiver dados em apenas uma temperatura
  if isscalar(model.temps),
    if model.temps ~= temp, % verificar se os dados solicitados existem
      error('Model does not contain requested data at this temperature');
    end
    theParam = model.(fieldName);
    return
  end

  % Caso contr�rio, o modelo tem v�rias temperaturas. 
  % Entrada vinculada "temp" entre a temperatura m�nima e m�xima armazenada
  % para proibir "NaN" na sa�da
  theParamData = model.(fieldName);
  temp = max(min(temp,max(model.temps)),min(model.temps)); 
  ind = find(model.temps == temp); % veja se h� uma correspond�ncia exata para
  if ~isempty(ind), % evitar chamar para (lento) interp1 sempre que poss�vel
    if size(theParamData,1) == 1,
      theParam = theParamData(ind);
    else
      theParam = theParamData(ind,:);
    end
  else % se n�o houver uma correspond�ncia exata, interpolamos entre os 
    theParam = interp1(model.temps,theParamData,temp,'spline'); % valores
  end  % dos par�metros armazenados em diferentes temperaturas
