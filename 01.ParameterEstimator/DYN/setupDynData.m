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
% -------------------------------------------------------------------------
% Op��es de arquivos usados para otimiza��es em diferentes temperaturas
% Temp:  -25  -15  -05   05   15   25   35   45
% --------------------------------------------------------
% A123:   10   10   30   45   50   50   50   50 (c�lila utilizada aqui)
% ATL:     2    5   15   20   30   40   50   50
% E1:      2    5   10   20   25   35   45   50
% E2:      2    5    5   15   25   35   45   50
% P14:     4   10   20   35   50   50   50   50
% SAM:     2    2    5   10   10   15   15   15
% 
% Note que o indicador num�rico indica a taxa-C m�xima usada em cada teste
% (ex: "40" - 4.0C). Por causa da maior resist�ncia em temperaturas mais 
% baixas, n�s devemos reduzir a corrente m�xima para evitar exceder os 
% limites de tens�o de cada c�lula.

clear all
%cellIDs = {'A123','ATL','E1','E2','P14','SAM'};
cellIDs = {'A123'};
temps = [-25  -15   -5    5   15   25   35   45];
mags =  {[10   10   30   45   45   50   50   50]};

%mags =  {[10   10   30   45   45   50   50   50], ... % A123
%         [ 2    4   15   20   30   40   50   50], ... % ATL
%         [ 2    4   10   20   25   35   45   50], ... % E1
%         [ 2    3    5   15   20   35   45   50], ... % E2
%         [ 4    5   20   30   50   50   50   50], ... % P14
%         [ 2    2    5   10   10   15   15   15]};    % SAM
