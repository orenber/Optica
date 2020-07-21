classdef Ray  <handle
    %RAY Summary of this class goes here
    %   Detailed explanation goes here
    %  03/08/2014 Ray y=0 bug fix
    %  03/08/2014 Ray destination change from 500 to 2500
    %  06/08/2014 Ray  in case the input is not anumber bug fix
    % created by oren berkovitch orenber@hotmail.com
    events
        Update
    end
    
    properties
        
        color@char='red'
        y@double = 2
        
        teta@double=[-1 0 1]
      
        
    end
    
    properties (Access= private)
        p@double = zeros(1,3)
        ax
        listner_draw
        listener_sys
    end
    properties (SetObservable,SetAccess = public, GetAccess = public )
         draw@logical =  false; 
         
    end
    properties (SetAccess = private, GetAccess = public   )
        systemoptic
        xyr@cell = {}
        
        x@double = 0;
    end
    properties (Constant,GetAccess = private)
        
        color_collection = {'Blue',...
            'Red',...
            'Yellow',...
            'Green',...
            'Cyan',...
            'Magenta',...
            'Black'};
        
    end
    
    methods
        
        function ray = Ray(sysopt,varargin)
          
            ray.addSystemOptic(sysopt);
            ray.listner_draw = addlistener(ray,'draw','PostSet',@(h,e)ray.view(h,e));
            
            setup_input = varargin2struct(varargin{:});
            setup_defult = struct('y',2,'ax',gca);
            setup = mergestruct(setup_defult,setup_input);
            
            for  field =  fieldnames(setup)'
                fieldStr = field{1};
                ray.(fieldStr) = setup.(fieldStr);
            end

       
           
        end
        
        function set.teta(ray,val)
            
            % in case val is not number
            assert(isNumber(val)&&~any(isnan(val)),'value must be number')
            
            assert(length(val)==3,'value must be in array in length 3')
            % Arrange the Rays to their size
            ray.teta=sort(val);
            ray.update()
        end
        
        function set.y(ray,val)
            % in case val is not number
            assert(isa(val,'double')&&~isnan(val),'value must be double type and not nan')
            ray.y=val;
            ray.update()
            
        end
        
        function set.x(ray,val)
            % in case val is not number
            assert(isa(val,'double')&&~isnan(val),'value must be double type and not nan')
            ray.x = val;
            ray.update()
            
        end
        
        function set.color(ray,color)
            index = strcmpi(ray.color_collection,strtrim(color));
            therIsColor = any(index);
            assert(therIsColor,['the color input must be from type: ',...
                strjoin([ray.color_collection],', ')])
            ray.color = ray.color_collection{index};
              if ray.draw 
            ray.updateDraw()
              end
        end
        
        function rayPath(ray)
            %% Calculate the geometric trajectory of light rays
            
            % check if ther is lens in the SystemOptic class
            if  ~isempty(ray.systemoptic.lens)
                
                lens= ray.systemoptic.arrengeMatrix();
                %lens = lenSortx(ray.x<=[lenSortx().x]);
            end
            
            ray.xyr=cell(length(ray.teta),1);
            
            for t=1:length(ray.teta)
                
                r=[ray.y ; tand(ray.teta(t))];
                ray.xyr{t,1}=[0,r(1),atand(r(2))];
                
                if ~isempty(ray.systemoptic.lens)
                    lensCount = length(lens);
                    for n=1:lensCount
                  
                        if (n==1)
                            d= lens(n).x;
                        else
                            d= lens(n).x-(lens(n-1).x+lens(n-1).width);
                        end
                        X = lens(n).x;
                        w = lens(n).width;
                        tail = lens(n).y;
                        head = lens(n).height+lens(n).y;
                        % Ray pass in free space
                        r=[1 d ;0 1]*r;
                        ray.xyr{t,2*n}=[X,r(1),atand(r(2))];
                        
                        
                        if ((tail <= r(1))&&(r(1) <= head))
                            
                            %Ray pass in Lens
                            r=lens(n).interface(:,:,1)*r;
                            r=[1 w;0 1]*r;
                            r=lens(n).interface(:,:,2)*r;
                            ray.xyr{t,2*n+1}=[X+w,r(1),atand(r(2))];
                            
                        else
                            
                            % Ray continue to propangate in free space
                            r=[1 w;0 1]*r;
                            ray.xyr{t,2*n+1}=[X+w,r(1),atand(r(2))];
                        end
                        
                        
                        
                    end
                    
                    
                    L=5500+lens(lensCount).x+lens(lensCount).width;
                    
                    % the  distance of image from the figure
                    
                    r=[1 L-X-w;0 1]*r;
                    ray.xyr{t,2*n+2}=[L,r(1),atand(r(2))];
                    
                    % in case ther is no lens
                else
                    
                    L=1000^2;
                    
                    r=[1 L;0 1]*r;
                    ray.xyr{t,2}=[L,r(1),atand(r(2))];
                    
                    
                end
                
                
            end
            
            
        end
        
        
    end
    
    methods (Access = protected)
        
        function ray = addSystemOptic(ray,sys)
            % check if the sys is SystemOptic class
            assert(isa(sys,'SystemOptic'),'is not SystemOptic class')
            ray.systemoptic=sys;
            ray.listener_sys = addlistener(ray.systemoptic...
                ,'Update',@(h,e)ray.update());
        end
        
        function update(ray)
            ray.rayPath();
            
            if ray.draw
                ray.updateDraw()
            end
            notify(ray,'Update')
        end
        
        function plot(ray)
            %% Draw the geometric path of light rays
            
            assert(~isempty(ray.xyr),'please update ray path')
            
            
            k=cell2mat(ray.xyr);
            Xindx=1:3:length(k);
            Yindx=2:3:length(k);
            siz=size(k);
            xlim = get(ray.ax,'xlim');
            ylim = get(ray.ax,'ylim');
            hold(ray.ax,'on')
            for  n=1:siz(1)
                
                X=k(n,Xindx);
                Y=k(n,Yindx);
                
                ray.p(n)= plot(X,Y,ray.color,'Parent',ray.ax,...
                    'HandleVisibility','on','LineStyle','-');
                
            end
            
            set(ray.ax,'xlim',xlim,'ylim',ylim)
        end
        
        function updateDraw(ray)
            
            k=cell2mat(ray.xyr);
            Xindx = 1:3:length(k);
            Yindx = 2:3:length(k);
            for n = 1:3
                X=k(n,Xindx);
                Y=k(n,Yindx);
                set(ray.p(n),'xdata',X,'ydata',Y,'color',ray.color)
            end
            
        end
        
        function view(ray,h,e)
            if ray.draw
               ray.plot();
            else
               if ~isempty(ray.p) 
               set(ray.p(1:3),'visible','off')
               end
            end
        end
        
    end
end