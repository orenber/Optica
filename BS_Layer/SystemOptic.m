classdef SystemOptic <handle
    %SYSOPTIC Summary of this class goes here
    %   Detailed explanation goes here
    %  06/08/2014  in case the input is not anumber bug fix
    % created by oren berkovitch orenber@hotmail.com
    events
        Update
    end
    
    properties (SetAccess = public, GetAccess = public   )
        focal
        draw = false
    end
    properties (SetAccess = protected, GetAccess = public )
        
        
        vhf;
        vhb;
        L=0;
        m;
        matrix = [1 0;0 1]
        
        
    end
    properties (SetAccess = private, GetAccess = public   )
        lens
        
        Xf=0
        Xb=0
        
    end
    properties (SetAccess = private, GetAccess = public   )
        figure
        ray
    end
    
    properties (Dependent)
        x@double=0;
        indx@double
        Index_out@double
    end
    properties (Access=private)
        indxnum@double = 0
        Xlocation@double = 0
        index_out@double = 1
        
    end
    
    properties (SetAccess = private, GetAccess = private   )
        ax
        arrow_index
        listener_lens
        listener_lens_hit
        listner_destroyed
    end
    
    
    methods
        %constructor
        function sys = SystemOptic(varargin)
            siz = length(varargin);
            var = varargin;
            
            if (siz>0)
                
                sys.lens=horzcat(var {1,:});
                
            end
            sys.index_out=1;
            
            
            sys.update();
            sys.indx = length(sys.lens);
            
            
        end
        
        function addLens(sys,varargin)
            
            var= varargin;
            
            % convert lens to cell
            for n=1:length(sys.lens)
                var{1,length(var)+1}= sys.lens(n);
            end
            var=fliplr(var);
            %convert from cell to lens
            sys.lens=horzcat(var {1,:});
            sys.lens(end).index_out = sys.index_out;
            sys.indx = length(sys.lens);
            handle = sys.lens(sys.indx);
            
            sys.listener_lens = addlistener(handle...
                ,'Update',@(h,e)sys.update());
            sys.listener_lens_hit = addlistener(handle.rect...
                ,'Hit',@(h,e)sys.selectedLens(handle));
            
            sys.update()
            
            
        end
        
        function addFigure(sys,fig)
            
            % check if the sys is Fig class
            assert(isa(fig,'Fig'),'input is not Fig class')
            set(fig.displayObj.hArrow,'Parent',sys.ax)
            sys.figure = fig;
            
        end
        
        function addRay(sys,ray)
            % check if the sys is Fig class
            assert(isa(ray,'Ray'),'input is not Ray class')
            sys.ray = ray;
            
        end
        
        function removeLens(sys,varargin)
            %convert from cell to lens
            lens_to_remove = horzcat(varargin{1,:});
            % check if the input is type of Lens Class
            
            if (isa(lens_to_remove,'Lens')==0)
                disp('Lens not found')
                return
            end
            
            le=sys.lens;
            
            
            for n=1:length(lens_to_remove)
                
                InedxLens= find(ne(le,lens_to_remove(n)));
                sys.lens=le(InedxLens);
                le=sys.lens;
                delete(lens_to_remove(n))
            end
            
            sys.indx=length(sys.lens);
            sys.update();
            
            if  sys.indx==0
               sys.resetSystem() 
            end
            
            
        end
        
        function selectedLens(sys,handle)
            
            sys.indx = sys.findLensIndx(handle);
            
            
        end
        
        function update(sys)
            
            opticalObjectSorted = sys.arrengeMatrix();
            if ~isempty(opticalObjectSorted )
                sys.multipMatrix(opticalObjectSorted);
            else
                sys.resetMatrix();
                
            end
            
            sys.fc;
            sys.VHf;
            sys.VHb;
            sys.X;
            sys.Ma;
            notify(sys,'Update')
            if sys.draw
                sys.plot()
                
            end
            
        end
        function objectSort = arrengeMatrix(sys)
            
            if ~isempty(sys.lens)
                [xObjPosition,index]=  sort([sys.lens.x]);
                objectSort = sys.lens(index);
                
            else
                objectSort = [];
                xObjPosition = nan;
            end
            sys.Xf = xObjPosition(1);
            sys.Xb = xObjPosition(end);
            
        end
        function multipMatrix(sys,var)
            
            sys.resetMatrix();
            siz=length(var);
            j(1,1)=var(1,1).x;
            
            for  n=siz:-1:1
                if (n>1)
                    % in case both lens are in the same place
                    if var(1,n).x==var(1,n-1).x
                        continue
                    else
                        d=(var(1,n).x-(var(1,n-1).x+var(1,n-1).width));
                    end
                elseif (n==1)
                    d=0;
                end
                sys.matrix = sys.matrix*var(1,n).matrix*[1 d;0 1];
                
                j(1,n)=var(1,n).x;
                
            end
            
        end
        function resetMatrix(sys)
            
            sys.matrix = [1 0; 0 1];
        end
        
        function  fc(sys)
            
            sys.focal=-1/sys.matrix(2,1);
            
        end
        function  VHf(sys)
            
            sys.vhf = (sys.matrix(2,2)-det(sys.matrix))/sys.matrix(2,1);
            
        end
        function  VHb(sys)
            
            sys.vhb = (1-sys.matrix(1,1))/sys.matrix(2,1);
            
        end
        function  X(sys)
            if ~isempty(sys.lens)
                len = sys.arrengeMatrix();
                sys.L=-(sys.matrix(1,1)*sys.Xf+sys.matrix(1,2))/ ...
                    (sys.matrix(2,1)*sys.Xf+sys.matrix(2,2))+sys.Xb+len(end).width;
                
            else
                sys.L=0;
            end
            
            
        end
        function  Ma(sys)
            
            sys.m = 1/(sys.matrix(2,1)*sys.Xf+sys.matrix(2,2));
            
        end
        
        function plotsys(sys)
            
            if  isempty(sys.lens)
                
                return
            end
            
            % determain the axis border
            X=zeros(1,length(sys.lens));
            H=zeros(1,length(sys.lens));
            
            for n=1:length(sys.lens)
                X(n)=sys.lens(1,n).x+sys.lens(1,n).Width;
                H(n)=sys.lens(1,n).Height;
            end
            
            MaxlensX = max(X);
            MaxlensY = max(H);
            axis([0,MaxlensX+1,-MaxlensY,MaxlensY])
            
        end
        
        function fun(hobject,event,~,k)
            
            sys.indx = k;
            
            if isa(sys.ButtonDownFcn,'function_handle')
                % call additional callback from the user
                sys.ButtonDownFcn(hobject,event)
            end
            
        end
        
        function createAxesBanch(sys,ax)
            
            sys.draw = true;
            sys.ax = ax;
            set(sys.ax,'xlim',[0,20],'ylim',[-16,16]);
            
            
            grid(sys.ax,'on')
            line('parent',sys.ax,'xdata',[-1000;1000],'ydata',[0;0]...
                ,'LineWidth',2,'HandleVisibility','off','color',[0.5 0.5 0.5])
            line('parent',sys.ax,'xdata',[0;0],'ydata',[-1000;1000]...
                ,'LineWidth',2,'HandleVisibility','off','color',[0.5 0.5 0.5])
            ylim = get(sys.ax,'Ylim');
            sys.arrow_index = text(0,ylim(2) ...
                ,' \downarrow ','FontSize',18,'HorizontalAlignment','center'...
                ,'color','r','parent',sys.ax,'Visible','off');
            sys.listner_destroyed = addlistener(sys,'ObjectBeingDestroyed',@(h,e)sys.destroyed(h,e));
            
        end
        
        function destroyed(sys,~,~)
            
            delete(sys.ax)
        end
        
        
        function indx = findLensIndx(sys,varargin)
            
            % check if  the varargin is type of Lens Class
            assert(isa(varargin{:},'Lens'),'value is type of Lens Class')
            
            indx = find(sys.lens == varargin{:});
            
        end
        
        function getFocal(sys,f)
            
            R=-2*f*(sys.Index_in-sys.Index_Out)/sys.Index_Out;
            sys.radius_Left=-R;
            sys.radius_right=R;
            sys.width=0.00000001;
            
        end
        
        function set.indx(sys,val)
            
            sys.indxnum = val;
            if sys.draw
                sys.plot()
            end
        end
        function val= get.indx(sys)
            val=  sys.indxnum;
            
        end
        function set.x(sys,val)
            if isnan(val)==1
                return
                
            elseif val<0
                % the position of the lens cant be below 0
                val=0;
            end
            
            sys.Xlocation=val;
            sys.update()
            
        end
        function val= get.x(sys)
            val=sys.Xlocation;
        end
        function set.index_out(sys,val)
            % in case val is not number
            assert(~isnan(val),'value is not number')
            assert(0<=val,'index_out cant be lower or equal 0')
            
            sys.index_out = val;
            if ~isempty(sys.lens)
                for n=1:length(sys.lens)
                    sys.lens(n).index_out = val;
                end
                sys.update()
            end
        end
        function val=get.index_out(sys)
            val = sys.index_out;
        end
        
        function plot(sys)
            % draw the corrent index lens
            if ~isempty(sys.lens)
                
                ylim=get(sys.ax,'Ylim');
                set(sys.arrow_index,'Visible','on','Position',...
                    [sys.lens(sys.indx).x+sys.lens(sys.indx).width/2,ylim(2),0]);
                
            elseif isempty(sys.lens)
                
                set(sys.arrow_index,'Visible','off');
            end
        end
        function resetSystem(sys)
            
            delete(sys.lens)
            if ~isempty(sys.figure)
                sys.figure.deleteChildren([sys.figure.ImgFig,sys.figure.RealFig])
            end
            sys.lens=[];
            sys.indx=0;
            sys.update();
        end
        function showAllView(sys,factor_percent)
            if nargin<2
                factor_percent = 0.1;
            end
            if ~isempty(sys.lens)
            ylenRange = [[sys.lens.y],[sys.lens.y]+[sys.lens.height]];
            xlenRange = [[sys.lens.x],[sys.lens.x]+[sys.lens.width]];
            else
                ylenRange = [];
                xlenRange = [];
            end
            fig = [sys.figure.RealFig,sys.figure.ImgFig];
            yFigureRange = [[sys.figure.y,fig.y],[sys.figure.y,fig.y]+[sys.figure.height,fig.height]];
            xFigureRange = [[sys.figure.x,fig.x],[fig.x]+sign([fig.x]).*abs([fig.M]/4)];
            
            ysort = sort([ylenRange,yFigureRange]);
            xsort = sort([xlenRange,xFigureRange]);
            
            ymin = min([ysort(1),-1]);
            ymax = max([ysort(end),3]);
            xmin = min([xsort(1),-0.5]);
            xmax = max([xsort(end),1]);
            
            factor.y = diff([ymin,ymax])*factor_percent;
            factor.x = diff([xmin,xmax])*factor_percent;
            ylim(sys.ax,[ymin-factor.y,ymax+factor.y])
            xlim(sys.ax,[xmin-factor.x,xmax+factor.x])
            
            
        end
        
    end
    
end
