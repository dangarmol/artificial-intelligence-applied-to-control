function [sys,x0,str,ts] = controlador(t,x,u,flag)
%SFUNTMPL General M-file S-function template
%   With M-file S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

%
% The following outlines the general structure of an S-function.
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AQUI SE DEFINE EL NUMERO DE ENTRADAS Y SALIDAS DE LA FUNCION; SI SE
%A�ANDEN MAS ELEMENTOS A LA MEMORIA HAY QUE AUMENTAR EL NUMERO DE ENTRADAS
%Y SALIDAS EN LA MISMA CANTIDAD QUE EL NUMERO DE ELEMENTOS A�ADIDOS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 18; %numero de salidas
sizes.NumInputs      = 25; %numero de entradas
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1 1];

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AQUI ES DONDE DEBEIS ESCRIBIR VUESTRO CODIGO DE CONTROL.%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%las variables de entrada disponibles son: 

%t: es el instante de tiempo actual
%u(1): OVOL; volumen actual en el tanque de naftas (m^3).
%u(2): OPT; Temperatura de la bomba de suministro de nafta (�C)
%u(3): VNA; Apertura de la valvula de llenado de nafta. Esta variable solo toma
       %tres valores:1== valvula abierta. 0==valvula en camino, abri�ndose
       %� cerrandose. -1==valvula cerrada.
%u(4): FOV; detecci�n de bloqueo de la valvula de llenado de nafta. Si toma el
       %valor -1 la valvula esta bloqueada y por tanto cerrada. cualquier otro 
       %valor(0 � 1) supone que la v�lvula funciona correctamente.
%u(5): AVOL; volumen en el tanque de amoniaco (m^3).
%u(6): APT; Temperatura de la bomba de sumistro de nafta (�C)
%u(7): Apertura de la valvula de llenado de amoniaco. Esta variable solo toma
       %tres valores:1== valvula abierta. 0==valvula en camino, abri�ndose
       %� cerrandose. -1==valvula cerrada.
%u(8): FAV; detecci�n de bloqueo de la valvula de llenado de amoniaco. Si toma el
       %valor -1 la valvula esta bloqueada y por tanto cerrada. cualquier otro 
       %valor(0 � 1) supone que la v�lvula funciona correctamente.
%u(9): VC; Volumen de mezcla en la camara de compresion
%u(10):VCA; Apertura de la valvula de salida del compresor. Esta variable solo toma
       %tres valores:1== valvula abierta. 0==valvula en camino, abri�ndose
       %� cerrandose. -1==valvula cerrada.
%u(11):OP; Presi�n sumministrada por el compresor. (pa.) Nota: 1 atm�sfera =101325 pa.
%u(12):FCV; detecci�n de bloqueo de la valvula de salida del compresor. Si toma el
       %valor -1 la valvula esta bloqueada y por tanto cerrada. cualquier otro 
       %valor(0 � 1) supone que la v�lvula funciona correctamente. 
%u(13):CT; Tempertura del compresor.
%u(14)-u(25); Corresponde a los valores contenidos en la memoria del
%controlador. Sus valores iniciales est�n puestos a cero. Pueden modifcarse
%haciendo doble clik en el bloque de memoria para editarlos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%la variables de salida, hay que introducirlas como elementos de un vector
%en sys, el orden de dichas variables ser�a el siguiente:

%sys(1): interruptor de apertura sys(1)=1 � cierre sys(1)=0, de la v�vula de
         %llenado de nafta.
%sys(2): interruptor de arraque y parada de la bomba de suministro de
    %nafta. sys(2)=1 arraque de la bomba, sys(2)=0 parada de la bomba
%sys(3):  interruptor de apertura sys(3)=1 � cierre sys(3)=0, de la v�vula de
         %llenado de amoniaco.
%sys(4): %interruptor de arraque y parada de la bomba de suministro de
    %amoniaco. sys(4)=1 arraque de la bomba, sys(4)=0 parada de la bomba
%sys(5):  interruptor de apertura sys(5)=1 � cierre sys(5)=0, de la v�vula de
         %salida del compresor.
%sys(6): %interruptor de arraque y parada de la bomba de suministro de
    %amoniaco. sys(6)=0 arraque de la bomba, sys(6)=0 parada de la bomba
%sis(7)-sys(18) salidas para rescribir las diez posiciones de memoria
%disponible. Nota: aunque el valor de la memoria no cambie, es preciso
%rescribir de nuevo el valor que ten�an. as� por ejemplo si el valor de las
%posici�n de memoria 3, 5 y 10 no han cambiado, hay que rescribirlo como
%sys(9)=u(22), sys(11)=u(24) y sys(10)=u(23).

%%%%%%%%% EMPIEZA EL CODIGO DEL SISTEMA EXPERTO...%%%%%%%%%%%%%
% Control de llenado
if u(9)<18 && u(14)==-1 % Si no se han alcanzado los 18 m3 � no se ha llenado la c�psula.
    if u(15)==-1 % Arrancamos las bombas
        sys=[0,1,0,1,0,0,u(14),t,u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    elseif t-u(15)>100 % Esperamos 5 segundos
        if u(1) > 1 && u(5) > 1 % Si queda mas de 1 m3 abrimos las valvulas
            sys=[1,1,1,1,0,0,u(14),0,u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
        else % Si queda menos de 1 m3 cerramos las v�lvulas
            sys=[0,1,0,1,0,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
        end
    else
        sys=[0,1,0,1,0,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    end
    
% Control de cerrado de valvulas y bombas
elseif u(16)==-1 % Si la c�mara est� llena
    if u(17)==-1 % Cerramos las v�lvulas
        sys=[0,1,0,1,0,0,0,u(15),u(16),t,u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    elseif u(3)==-1 && u(7)==-1 % Si las valvulas estan cerradas, apagamos las bombas
        sys=[0,0,0,0,0,0,u(14),u(15),0,u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    else
        sys=[0,1,0,1,0,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    end
    
% Control de compresi�n de la mezcla
elseif u(18)==-1
    if u(19)==-1 % Iniciamos el compresor
        sys=[0,0,0,0,0,1,u(14),u(15),u(16),u(17),u(18),t,u(20),u(21),u(22),u(23),u(24),u(25)];
    elseif t-u(19)>400 % Esperamos 4 minutos y apagamos el compresor
        sys=[0,0,0,0,0,0,u(14),u(15),u(16),u(17),0,u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    else
        sys=[0,0,0,0,0,1,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    end 
    
% Control de vaciado y reinicio
elseif u(20)==-1
    if u(11) > 0 % Esperamos a que el compresor est� en reposo
        sys=[0,0,0,0,0,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    elseif u(9) > 0 % Esperamos a que se vaci� la c�mara
        sys=[0,0,0,0,1,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
    else % Reiniciamos el proceso
        sys=[0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
    end    
else
   sys=[0,0,0,0,0,0,u(14),u(15),u(16),u(17),u(18),u(19),u(20),u(21),u(22),u(23),u(24),u(25)];
end 

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
