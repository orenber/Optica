
classdef AxesMove < handle
    %AXESPLAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        boundry@double = [-5000,5000]
        Axes
        Figure
    end
    
    
    properties   (SetAccess = public, GetAccess = public )
        xdata
        ydata_high
        ydata_low
        type@char = 'date'
        
    end
    
    properties  (SetAccess = protected, GetAccess = protected )
        endPoint =struct('x',[],'y',[])
        startPoint = struct('x',[],'y',[])
        listener_WindowMousePress
        listener_y_axes
        listener_x_axes
        listener_axes_SizeChanged
        xTickSum = 10
        yTickSum = 11
    end
    methods
        
        function obj = AxesMove(varargin)
            try
                % creaet axes
                obj.Axes = axes(varargin{:});
                obj.Figure = ancestor(obj.Axes,'figure','toplevel');
                obj.listener_WindowMousePress = addlistener(obj.Figure,...
                    'WindowMousePress',@obj.start);
                obj.listener_x_axes = addlistener( obj.Axes,...
                    'XLim','PostSet',@obj.xAxesChange);
                obj.listener_y_axes = addlistener( obj.Axes,...
                    'YLim','PostSet',@obj.yAxesChange);
                obj.listener_axes_SizeChanged = addlistener(obj.Axes,...
                    'SizeChanged',@obj.sizeChanged);
                
                set(obj.Figure,'WindowKeyPressFcn',@obj.WindowKeyPress);
                
                
            catch err
                
                delete(obj)
                rethrow(err)
            end
        end
        
        function sizeChanged(obj,event,~)
            
            pos = round(obj.getPosition(obj.Axes,'cen'));
            
            
            obj.xTickSum =  pos(3)/(0.2*obj.Axes.FontSize);
            obj.yTickSum =  pos(4);
            obj.axesChange(event)
            
        end
        function position = getPosition(obj,handleObject ,convertUnits)
            
            originalUnit = get(handleObject,'Units');
            set(handleObject,'Units',convertUnits)
            
            position =  get(handleObject,'Position');
            % return to original units
            set(handleObject,'Units',originalUnit)
            
        end
        function axesChange(obj,event,~)
            yAxesChange(obj,event)
            xAxesChange(obj,event)
            
        end
        function yAxesChange(obj,event,~)
            ylim_boundry = get(obj.Axes,'ylim');
            y = linspace(ylim_boundry(1),ylim_boundry(2),obj.yTickSum);
            
            y_tick = arrayfun(@(x)sprintf('%1f',x),y,'UniformOutput',false);
            set(obj.Axes,'ytick',y,'YTickLabel',y_tick);
        end
        
        function xAxesChange(obj,event,~)
            xlim_boundry = get(obj.Axes,'xlim');
            x = linspace(xlim_boundry(1),xlim_boundry(2),obj.xTickSum);
            if strcmpi(obj.type,'date')
                x_tick =  datestr( x,'dd mmm yyyy');
            else
                x_tick = arrayfun(@(x)sprintf('%1f',x),x,'UniformOutput',false);
            end
            set(obj.Axes,'xtick',x,'XTickLabel',x_tick);
        end
        
        
        function start(obj,event,~)
            
            set(obj.Figure,'WindowButtonDownFcn',@obj.WindowMousePress)
            
            
        end
        
        function move(obj,step)
            xRange = get(obj.Axes,'xlim');
            newXRange = xRange+step;
            if  obj.inRange(newXRange)
                xlim(obj.Axes,newXRange)
                if ~isempty(obj.ydata_high)
                    yRange = obj.getYlim(newXRange);
                    ylim(obj.Axes,yRange)
                end
            end
        end
        
        function setXlimBackward(obj,backwardSteps)
            xlimBackward = obj.boundry(2)-backwardSteps;
            if  obj.inRange([xlimBackward,obj.boundry(2)])
                newXRange(1) = xlimBackward(1);
                
                newXRange(2) = obj.boundry(2);
                xlim(obj.Axes,newXRange)
            end
        end
        
        function state = inRange(obj,range)
            state =  range(1)>=obj.boundry(1) && range(2)<=obj.boundry(2);
            
        end
        
        function setData(obj,xdata,ydata_high,ydata_low)
            if nargin<4
                ydata_low = ydata_high;
            end
            assert(numel(xdata)==numel(ydata_high),'xdata and ydata must be the same length')
            obj.xdata = xdata;
            obj.boundry = [min( obj.xdata ),max( obj.xdata)];
            xlim(obj.Axes, obj.boundry )
            obj.ydata_high = ydata_high;
            obj.ydata_low = ydata_low;
        end
        
        function yrange = getYlim(obj,xrange)
            index =   (obj.xdata <= xrange(2))& (obj.xdata >= xrange(1));
            ylimRange(1)= min(obj.ydata_low(index));
            ylimRange(2) = max(obj.ydata_high(index));
            extra = diff(ylimRange)*(0.1);
            yrange(1) = ylimRange(1) - extra;
            yrange(2) = ylimRange(2) + extra;
        end
        
        function isInAxes =  isMouseInAxesArea(obj,~,~)
                 yboundry = ylim(obj.Axes);
            xboundry = xlim(obj.Axes);
            
            inXaxes = xboundry(1)<=obj.Axes.CurrentPoint(1,1)&&...
                obj.Axes.CurrentPoint(1,1)<=xboundry(2);
            
            inYaxes = yboundry(1)<=obj.Axes.CurrentPoint(1,2)&&...
                obj.Axes.CurrentPoint(1,2)<=yboundry(2);
            isInAxes = inXaxes&&inYaxes;
        end
        
    end
    
    methods (Access = protected)
        
        
        
        
        %% mouse
        function WindowMousePress(obj,h,e)
            
            
       isInAxes =  obj.isMouseInAxesArea();
            
            if isInAxes
                set(obj.Figure,'WindowButtonUpFcn',@obj.WindowMouseRelease);
                set(obj.Figure,'WindowButtonMotionFcn',@obj.WindowMouseMotion);
                currentPoint = get(obj.Axes,'CurrentPoint');
                obj.startPoint.x = currentPoint(1,1);
                obj.startPoint.y = currentPoint(1,2);
            end
            
        end
        
        function WindowMouseRelease(obj,h,e)
            
            set(obj.Figure,'WindowButtonUpFcn','');
            set(obj.Figure,'WindowButtonMotionFcn','');
        end
        
        function WindowMouseMotion(obj,h,e)
            
            
            currentPoint = get(obj.Axes,'CurrentPoint');
            
            
            steps = obj.startPoint.x-currentPoint(1,1) ;
            obj.move(steps)
            
        end
        
        
        %% keyboard
        
        function WindowKeyPress(obj,h,e)
            
            
            switch e.Key
                
                case 'rightarrow'
                    steps = diff(get(obj.Axes,'xlim'))/50;
                    obj.move(steps)
                case 'leftarrow'
                    steps = -diff(get(obj.Axes,'xlim'))/50;
                    obj.move(steps)
                    
            end
            
        end
        
        
    end
    
end
