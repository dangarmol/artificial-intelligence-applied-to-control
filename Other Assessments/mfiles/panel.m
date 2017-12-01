function [sys,x0,str,ts] = panel(t,x,u,flag)
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
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 16;
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
ts  = [-2 0];


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
if  ~any(get(0,'children')==15)
    figure(15)
    set(gcf,'Units','Normalized','NumberTitle','off','Name','Panel de Control')
    set(gcf,'Position',[0.01 0.2 0.30 0.6])   
    
    plot(0,0)
    hold on
    plot(0,13)
    plot(25,0)
    text(0,6,'Temp. Comp.')
    text(8,6,num2str(u(13),4))
    text(0,7,'P Compresor')
    text(8,7,num2str(u(11),9))
    text(0,8,'Vol C. Comp.')
    text(8,8,num2str(u(9),3))
    text(0,9,'Temp. B Amon.')
    text(8,9,num2str(u(6),4))
    text(0,12,'Vol. Nafta')
    text(8,12,num2str(u(1),3))
    text(0,11,'Temp. B Nafta')
    text(8,11,num2str(u(2),4))
    text(0,10,'Vol. Amoniaco')
    text(8,10,num2str(u(5),3))
    text(13,12,'Val. Naftas')
    text(13,11,'B. Naftas')
    text(13,9,'Val. Amoniaco ')
    text(13,8,'B. Amoniaco ')
    text(13,6,'Val. C. Comp.')
    text(13,5,'Compresor')
    a=[0;0;0];
    a(u(3)+2)=1;
    color=[1 0 0;0 0 1; 0 1 0]*a;
    plot( 22,12,'o','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',color')
    a=[0;0;0];
    a(u(14)+1)=1;
    color=[1 0 0;0 1 0; 0 0 1]*a;
    plot( 22,11,'s','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',color')
    a=[0;0;0];
    a(u(7)+2)=1;
    color=[1 0 0;0 0 1; 0 1 0]*a;
    plot( 22,9,'o','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',[color'])
    a=[0;0;0];
    a(u(15)+1)=1;
    color=[1 0 0;0 1 0; 0 0 1]*a;
    plot( 22,8,'s','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',[color'])
    a=[0;0;0];
    a(u(10)+2)=1;
    color=[1 0 0;0 0 1; 0 1 0]*a;
    plot( 22,6,'o','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',[color'])
    a=[0;0;0];
    a(u(16)+1)=1;
    color=[1 0 0;0 1 0; 0 0 1]*a;
    plot( 22,5,'s','MarkerSize',16,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',[color'])
    drawnow
    axis off
end


b=get(gca,'children');
a=[0;0;0];
a(u(16)+1)=1;
color=[1 0 0;0 1 0; 0 0 1]*a;
set(b(1),'MarkerFaceColor',color')
if u(12)==-1
set(b(2),'MarkerFaceColor',[1 1 0])
else
a=[0;0;0];
a(u(10)+2)=1;
color=[1 0 0;0 0 1; 0 1 0]*a;
set(b(2),'MarkerFaceColor',color')
end
a=[0;0;0];
a(u(15)+1)=1;
color=[1 0 0;0 1 0; 0 0 1]*a;
set(b(3),'MarkerFaceColor',color')
if u(8)==-1
set(b(4),'MarkerFaceColor',[1 1 0])
else
a=[0;0;0];
a(u(7)+2)=1;
color=[1 0 0;0 0 1; 0 1 0]*a;
set(b(4),'MarkerFaceColor',color')
end
a=[0;0;0];
a(u(14)+1)=1;
color=[1 0 0;0 1 0; 0 0 1]*a;
set(b(5),'MarkerFaceColor',color')
if u(4)==-1
set(b(6),'MarkerFaceColor',[1 1 0])
else
a=[0;0;0];
a(u(3)+2)=1;
color=[1 0 0;0 0 1; 0 1 0]*a;
set(b(6),'MarkerFaceColor',color')
end
set(b(13),'String',num2str(u(5),3))
set(b(15),'String',num2str(u(2),4))
set(b(17),'String',num2str(u(1),3))
set(b(19),'String',num2str(u(6),4))
set(b(21),'String',num2str(u(9),3))
set(b(23),'String',num2str(u(11),9))
set(b(25),'String',num2str(u(13),4))
sys =[];


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

sampleTime = 5;    %  Example, set the next hit to be one second later.
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
