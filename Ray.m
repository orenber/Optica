classdef Ray  <handle
    %RAY Summary of this class goes here
    %   Detailed explanation goes here
    %  03/08/2014 Ray y=0 bug fix
    %  03/08/2014 Ray destination change from 500 to 2500
    %  06/08/2014 Ray  in case the input is not anumber bug fix
    
    properties
        color='r'
        y=2
        teta=[-1 0 1]

    end
    
    properties (Access= private)
        p=zeros(1,3)

    end
    
    properties (SetAccess = private, GetAccess = public   )
        systemoptic
        xyr={}
    end
    
    methods
        
        function ray = Ray(sysopt)
            %%   --Constructor--

            % check if the class is of type SysOptic
            ok=isa(sysopt,'SysOptic');
            
            if (ok==0)
                
                disp('the class is not type of SysOptic class')
                return
            end
            
            ray.systemoptic=sysopt;

            
        end
        
        function set.teta(ray,val)
            
            % in case val is not number
            if  sum(isnan(val))>=1
                return
            end
            % Arrange the Rays to their size
            ray.teta=sort(val);
        end
        
        function set.y(ray,val)
            % in case val is not number
            if isnan(val(end))==1
                return
            elseif val==0
                val=0.001;
            end
            ray.y=val;
        end
        
        function ray = AddSys(ray,sys)
            %% Add the class of the optical system
            
            % check if the sys is SystemOptic class
            ok=isa(sys,'SysOptic');
            if (ok==0)
                disp(sys+ 'is not SysOptic class')
                return
            end
            
            ray.systemoptic=sys;
            
        end
        
        function RayIn(ray)
            %% Calculate the geometric trajectory of light rays
            
            % check if  systemoptic exist
            if (isempty(ray.systemoptic)==1)
                disp('SystemOptic class not found')
                return
            end
            
            % check if ther is lens in the SystemOptic class
            if  ~isempty(ray.systemoptic.lens)
                
                lens=ray.systemoptic.ArrengeMatrix;
            end

            ray.xyr=cell(length(ray.teta),1);
            
            for t=1:length(ray.teta)
                
                r=[ray.y ; tand(ray.teta(t))];
                ray.xyr{t,1}=[0,r(1),atand(r(2))];
                
                if ~isempty(ray.systemoptic.lens)
                    for n=1:length(lens)
                        if (n==1)
                            d= (lens(n).x) ;
                        else
                            d= lens(n).x-(lens(n-1).x+lens(n-1).Width);
                        end
                        x=lens(n).x;
                        w=lens(n).Width;
                        h=lens(n).Height/2;
                        
                        % Ray pass in free space
                        r=[1 d ;0 1]*r;
                        ray.xyr{t,2*n}=[x,r(1),atand(r(2))];
                        
                        
                        if ((r(1)<h)&&(r(1)>=-h))
                            
                            %Ray pass in Lens
                            r=lens(n).Interface(:,:,1)*r;
                            r=[1 w;0 1]*r;
                            r=lens(n).Interface(:,:,2)*r;
                            ray.xyr{t,2*n+1}=[x+w,r(1),atand(r(2))];
                            
                        else
                            
                            % Ray continue to propangate in free space
                            r=[1 w;0 1]*r;
                            ray.xyr{t,2*n+1}=[x+w,r(1),atand(r(2))];
                        end
                        
                        
                        
                    end
                    
                    
                    L=5500+lens(length(lens)).x+lens(length(lens)).Width;
                    
                    % the  distance of image from the figure
                    
                    r=[1 L-x-w;0 1]*r;
                    ray.xyr{t,2*n+2}=[L,r(1),atand(r(2))];
                    
                    % in case ther is no lens
                else
                    
                    L=1000^2;
                    
                    r=[1 L;0 1]*r;
                    ray.xyr{t,2}=[L,r(1),atand(r(2))];
                    
                    
                end
                
                
            end
            
            
        end
        
        function RayPlot(ray)
            %% Draw the geometric path of light rays
            
            if isempty(ray.xyr)==1
                
                return
            end

            
            ray.RayIn
            k=cell2mat(ray.xyr);
            Xindx=1:3:length(k);
            Yindx=2:3:length(k);
            
            siz=size(k);
            
            for  n=1:siz(1)
                
                X=k(n,Xindx);
                
                
                Y=k(n,Yindx);
                
                
                ray.p(n)= plot(X,Y,ray.color,'HandleVisibility','off');
                
            end
            for n=1:siz(1)
                set(ray.p(n),'HandleVisibility','on')
            end

            
        end

    end
    
end