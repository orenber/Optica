classdef Arrow<handle
    
    
    properties

         
        color  = 'green'
        
    end
    
    properties
        hArrow
        xdata
        ydata
        shape = [ 0, (1-0.13), (1-0.18), 1, (1-0.18), (1-0.13), 0;
                0.014,    0.014,     0.08, 0,    -0.08,    -0.014, - 0.014];
    end
    
    properties (SetAccess = private,GetAccess = public)
         length@double
         angle@double
    end
    
    properties (Constant,GetAccess = private)
        
        color_collection = {'Blue',...
            'Red',...
            'Yellow',...
            'Green',...
            'Cyan',...
            'Magenta',...
            'Black'};
        W1 = 0.08;   % half width of the arrow head, normalized by length of arrow
        W2 = 0.014;  % half width of the arrow shaft
        L1 = 0.18;   % Length of the arrow head, normalized by length of arrow
        L2 = 0.13;  % Length of the arrow inset
    end
    
    methods
        
        function obj = Arrow(p0,p1,color,varargin)
            if nargin == 2
                color = 'Green';
            end
            [xData,yData] = setPosition(obj,p0,p1);
            % Plot!
            obj.hArrow = patch(xData, yData,color,varargin{:}); 
            obj.color = color;
        end
        
        function [xdata,ydata] = setPosition(obj,p0,p1)
            % Parameters:
            
            % Unpack the tail and tip of the arrow
            x0 = p0(1);
            y0 = p0(2);
            x1 = p1(1);
            y1 = p1(2);

            % Scale,rotate, shift :
            dx = x1-x0;
            dy = y1-y0;
            obj.length = sqrt(dx*dx + dy*dy);
            obj.angle = atan2(-dy,dx);
            P = obj.length*obj.shape;   %Scale
            P = [cos(obj.angle), sin(obj.angle); -sin(obj.angle), cos(obj.angle)]*P;  %Rotate
            P = p0(:)*ones(1,7) + P;  %Shift
            xdata = P(1,:);
            ydata  = P(2,:);
        end
        
        function set.color(obj,color)
            index = strcmpi(obj.color_collection,strtrim(color));
            therIsColor = any(index);
            assert(therIsColor,['the color input must be from type: ',...
                strjoin([obj.color_collection],', ')])
            obj.color = obj.color_collection{index};
            set(obj.hArrow,'FaceColor',obj.color)
        end
        
        function updatePositionAndDraw(obj,p0,p1)
            [obj.xdata,obj.ydata] = setPosition(obj,p0,p1);
             obj.draw();
        end
        
        function draw(obj)
            if isvalid(obj.hArrow)
             set(obj.hArrow,'xdata',obj.xdata,'ydata',obj.ydata)
            end
        end
        
        function delete(obj,~,~)
            
         delete(obj.hArrow)   
        end
    end
    
    
end
