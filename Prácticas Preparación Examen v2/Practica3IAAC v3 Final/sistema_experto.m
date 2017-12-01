function pid=sistema_experto(pid,num,den,espec)

% Simulamos el modelo
  [tout,yout]=simular(pid,num,den);
    
% Calculo de las caracteristicas del sistema
  [tr,tp,Mp,ts,ys]=caracteristicas(tout,yout);
  [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
  
% Abrimos el modelo Simulink
  open_system('modelo');
  disp(' ');
  disp(' Pulse enter para ejecutar el control experto');
  pause;
  
% Incrementar o decrementar las especificaciones
  if tr<=espec(1), incrementar_tr=1; else incrementar_tr=0; end
  if tp<=espec(2), incrementar_tp=1; else incrementar_tp=0; end   
  if Mp<=espec(3), incrementar_Mp=1; else incrementar_Mp=0; end   
  if ts<=espec(4), incrementar_ts=1; else incrementar_ts=0; end   
  if ys<=espec(5), incrementar_ys=1; else incrementar_ys=0; end   
  
% Reglas del sistema experto para adaptar las caracteristicas a las especificaciones
  salir=0;
  while ~salir
      % Regla para el tiempo de subida
        if espec(1)<tr
            pid(1)=pid(1)+0.35;
            pid(2)=pid(2)+0;
            pid(3)=pid(3)+0;
        else
            pid(1)=pid(1)-0.25;
            pid(2)=pid(2)+0;
            pid(3)=pid(3)+0;
        end
       
      % Regla para la sobreelongación      
        if espec(3)<Mp
            pid(1)=pid(1)-0.25;
            pid(2)=pid(2)+0;
            pid(3)=pid(3)+0.6;
        else
            pid(1)=pid(1)+0.1;
            pid(2)=pid(2)+0;
            pid(3)=pid(3)-0.25;
%             pid(1)=pid(1)+0.25;
%             pid(2)=pid(2)+0;
%             pid(3)=pid(3)-0.5;
        end
        
      % Regla para el valor estacionario      
        if espec(5)<ys
            pid(1)=pid(1)-0.2;
            pid(2)=pid(2)+0.1;
            pid(3)=pid(3)+0.25;
        else
            pid(1)=pid(1)+0.2;
            pid(2)=pid(2)-0.25;
            pid(3)=pid(3)-0.1;
%             pid(1)=pid(1)+0.2;
%             pid(2)=pid(2)-0.1;
%             pid(3)=pid(3)-0.25;
        end
      
      % Caracteristicas del sistema bajo la nueva situacion
        [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
        [tr,tp,Mp,ts,ys]=caracteristicas(tout,yout);
        
      % Si se cumplen las especificaciones, entonces salir
        if incrementar_tr
            if tr>=espec(1)
                salir=1;
            end
        else
            if tr<espec(1)
                salir=1;
            end
        end
        if salir && incrementar_Mp
            if Mp<espec(3)
                salir = 0;
            end
        else
            if salir && Mp>=espec(3)
                salir = 0;
            end
        end
        if salir && incrementar_ys
            if ys<espec(5)
                salir = 0;
            end
        else
            if salir && ys>=espec(5)
                salir = 0;
            end
        end
  end
  
  [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
  disp(' ');
  disp(' PID sintonizado, pulse enter para salir');
  pause;
  
% Cerramos el modelo Simulink
  close_system('modelo');