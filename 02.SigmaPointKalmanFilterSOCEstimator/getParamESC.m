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
%
% função theParam = getParamESC(paramName,temperature,model)
%
% Essa função retorna os valores dos parâmetros do modelo de célula ESC 
% especificado 'paramName', para as temperaturas em 'temperature' e para
% os dados do modelo de célula armazenados em 'model'.
%
% No modelo ESC padrão, 'paramName' pode ser:
%    'QParam', 'RCParam', 'RParam', 'R0Param', 'MParam', 'M0Param',
%    'etaParam', or 'GParam' 
% (não diferencia letras maiúsculas)
%

function theParam = getParamESC(paramName,temp,model)
  theFields = fields(model); % obter lista de campos armazenados no modelo
  match = strcmpi(paramName,theFields); % veja se algum corresponde aos dados desejados
  if ~match, % se não, reporte um erro
    error('Parameter "%s" does not exist in model',paramName);
  end
  fieldName = char(theFields(match)); % nome do campo que diferencia maiúsculas de minúsculas

  % se o modelo contiver dados em apenas uma temperatura
  if isscalar(model.temps),
    if model.temps ~= temp, % verificar se os dados solicitados existem
      error('Model does not contain requested data at this temperature');
    end
    theParam = model.(fieldName);
    return
  end

  % Caso contrário, o modelo tem várias temperaturas. 
  % Entrada vinculada "temp" entre a temperatura mínima e máxima armazenada
  % para proibir "NaN" na saída
  theParamData = model.(fieldName);
  temp = max(min(temp,max(model.temps)),min(model.temps)); 
  ind = find(model.temps == temp); % veja se há uma correspondência exata para
  if ~isempty(ind), % evitar chamar para (lento) interp1 sempre que possível
    if size(theParamData,1) == 1,
      theParam = theParamData(ind);
    else
      theParam = theParamData(ind,:);
    end
  else % se não houver uma correspondência exata, interpolamos entre os 
    theParam = interp1(model.temps,theParamData,temp,'spline'); % valores
  end  % dos parâmetros armazenados em diferentes temperaturas
