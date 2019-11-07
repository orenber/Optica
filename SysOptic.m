classdef SysOptic <handle
    %SYSOPTIC Summary of this class goes here
    %   Detailed explanation goes here
    %  06/08/2014  in case the input is not anumber bug fix
    
    properties (SetAccess = public, GetAccess = public   )
        focal
        rect
        ButtonDownFcn
        
    end
    properties (SetAccess = protected, GetAccess = public )
        
        
        vhf;
        vhb;
        L=0;
        m;
        M=[1 0;0 1]
        arrow_index
        
    end
    properties (SetAccess = private, GetAccess = public   )
        lens
        Xf=0
        Xb=0
        
    end
    properties (Dependent)
        x=0;
        indx
        Index_out
    end
    properties (Access=private)
        indxnum=0
        Xlocation=0
        Index_Out=1
        
    end
    
    
    methods
        %constructor
        function sys=SysOptic(varargin)
            siz = length(varargin);
            var = varargin;
            
            if (siz>0)
                
                sys.lens=horzcat(var {1,:});
                
            end
            sys.Index_out=1;
            sys.update;
            sys.indx=length(sys.lens);
            
            sys.arrow_index = text();
            
        end
        function AddLens(sys,varargin)
            
            var= varargin;
            
            % convert lens to cell
            for n=1:length(sys.lens)
                var{1,length(var)+1}= sys.lens(n);
            end
            var=fliplr(var);
            %convert from cell to lens
            sys.lens=horzcat(var {1,:});
            sys.lens(length(sys.lens)).Index_out=sys.Index_out;
            sys.indx=length(sys.lens);
            
            sys.update()
            
            
        end
        function RemoveLens(sys,varargin)
            %convert from cell to lens
            Rle=horzcat(varargin{1,:});
            % check if the input is type of Lens Class
            
            if (isa(Rle,'Lens')==0)
                disp('Lens not found')
                return
            end
            
            le=sys.lens;
            for n=1:length(Rle)
                InedxLens= find(ne(le,Rle(n)));
                sys.lens=le(InedxLens);
                le=sys.lens;
            end
            
            sys.update;
            sys.indx=length(sys.lens);
            
        end
        function update(sys)
            
            if ~isempty(sys.lens )
                
                var=sys.ArrengeMatrix;
                MultipMatrix(sys,var);
            else
                sys.ResetMatrix;
                
            end
            
            sys.fc;
            sys.VHf;
            sys.VHb;
            sys.X;
            sys.Ma;
            
            
        end
        function v = ArrengeMatrix(sys)
            
            len=sys.lens;
            siz=length(len);
            
            
            for n=1:siz
                
                j(1,n)=len(1,n).x;
                
            end
            
            f=sort(j);
            sys.Xf=f(1);
            sys.Xb=f(length(f));
            
            for n=1:siz
                
                for k=1:siz
                    
                    if (f(1,n)==len(1,k).x)
                        
                        v(1,n)=len(1,k);
                    end
                    
                    
                end
                
                
            end
            
            
        end
        function MultipMatrix(sys,var)
            
            sys.ResetMatrix();
            siz=length(var);
            j(1,1)=var(1,1).x;
            
            for  n=siz:-1:1
                if (n>1)
                    % in case both lens are in the same place
                    if var(1,n).x==var(1,n-1).x
                        continue
                    else
                        d=(var(1,n).x-(var(1,n-1).x+var(1,n-1).Width));
                    end
                elseif (n==1)
                    d=0;
                end
                sys.M=sys.M*var(1,n).M*[1 d;0 1];
                
                j(1,n)=var(1,n).x;
                
            end
            
        end
        function ResetMatrix(sys)
            
            sys.M=[1 0; 0 1];
        end
             
        function  fc(sys)
            
            sys.focal=-1/sys.M(2,1);
            
        end
        function  VHf(sys)
            
            sys.vhf=(sys.M(2,2)-det(sys.M))/sys.M(2,1);
            
        end
        function  VHb(sys)
            
            sys.vhb=(1-sys.M(1,1))/sys.M(2,1);
            
        end
        function  X(sys)
            if ~isempty(sys.lens)
                len= sys.ArrengeMatrix;
                sys.L=-(sys.M(1,1)*sys.Xf+sys.M(1,2))/(sys.M(2,1)*sys.Xf+sys.M(2,2))+sys.Xb+len(end).Width;
                
            else
                sys.L=0;
            end
            
            
        end
        function  Ma(sys)
            
            sys.m=1/(sys.M(2,1)*sys.Xf+sys.M(2,2));
            
        end
        
        function SysPlot(sys)
            
            if  isempty(sys.lens)==1
                
                cla reset
                axis([0,20,-16,16]);
                
                
                grid on
                line('xdata',[-1000;1000],'ydata',[0;0],'LineWidth',2,'HandleVisibility','off','color',[0.5 0.5 0.5])
                line('xdata',[0;0],'ydata',[-1000;1000],'LineWidth',2,'HandleVisibility','off','color',[0.5 0.5 0.5])
                set(gca,'NextPlot','replacechildren')
                return
            end
            % determain the axis border
            X=zeros(1,length(sys.lens));H=zeros(1,length(sys.lens));
            for n=1:length(sys.lens)
                X(n)=sys.lens(1,n).x+sys.lens(1,n).Width;
                H(n)=sys.lens(1,n).Height;
            end
            
            MaxlensX = max(X);
            MaxlensY = max(H);
            
            % Create axis
            cla reset
            axis([0,MaxlensX+1,-MaxlensY,MaxlensY]);
            
            
            grid on
            line('xdata',[-1000;1000],'ydata',[0;0],'LineWidth',2,'color',[0.5 0.5 0.5],'HandleVisibility','off')
            line('xdata',[0;0],'ydata',[-1000;1000],'LineWidth',2,'color',[0.5 0.5 0.5],'HandleVisibility','off')
            set(gca,'NextPlot','replacechildren')
            
            for k=1:length(sys.lens)
                
                
                % all the rest of the rec 'HandleVisibility','off'
                if (abs(sys.lens(k).Radius_Left)==inf)||(abs(sys.lens(k).Radius_right)==inf)
                    if abs(sys.lens(k).Radius_Left)==inf
                        Rl=0;
                        Rr=1;
                    end
                    if abs(sys.lens(k).Radius_right)==inf
                        Rr=0;
                        Rl=1;
                    end
                    
                else
                    Rl=1;
                    Rr=1;
                end
                
                
                sys.lens(k).rect = rectangle('pos',[sys.lens(k).x  -sys.lens(k).Height/2  sys.lens(k).Width sys.lens(k).Height ],...
                    'FaceColor', sys.lens(k).Color,'Curvature',[Rl Rr],'HandleVisibility','off',...
                    'ButtonDownFcn',@(h,e)fun(h,e,guidata(h),k));
                
            end
            sys.indx=k;
            function fun(hobject,event,handles,k)
                
                
                sys.indx=k;
                if isa(sys.ButtonDownFcn,'function_handle')
                    % call additional callback from the user
                    sys.ButtonDownFcn(hobject,event)
                end
                
            end
        end
        function Xlens=FindLensIndx(sys,varargin)
            
            % check if  the varargin is type of Lens Class
            if isa(varargin{:},'Lens')==0
                return
            end
            Lens=sys.ArrengeMatrix;
            Xlens=find(Lens==varargin{:});
            
        end
        function Focal(sys,f)
            
            R=-2*f*(sys.Index_in-sys.Index_Out)/sys.Index_Out;
            sys.Radius_Left=-R;
            sys.Radius_right=R;
            sys.Width=0.00000001;
            
        end
        
        function set.indx(sys,val)
            
            sys.indxnum=val;
            for n=1:length(sys.lens)
                if ~isempty(sys.lens(n).rect)
                    set(sys.lens(n).rect,'HandleVisibility','off')
                end
            end
            
            if sys.indx>0
                if ~isempty(sys.lens(sys.indx).rect)
                    set(sys.lens(sys.indx).rect,'HandleVisibility','on')
                    ylim=get(gca,'Ylim');
                    sys.arrow_index = text(sys.lens(sys.indx).x+sys.lens(sys.indx).Width/2,ylim(2)...
                        ,' \downarrow ','FontSize',18,'HorizontalAlignment','center','color','r');
                end
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
        function set.Index_out(sys,val)
            % in case val is not number
            if isnan(val)
                return
            elseif  val<0
                val=0;
            end
            sys.Index_Out=val;
            if ~isempty(sys.lens)
                for n=1:length(sys.lens)
                    sys.lens(n).Index_Out=val;
                    sys.lens(n).update
                end
                sys.update
            end
        end
        function val=get.Index_out(sys)
            val=sys. Index_Out;
        end
        
        function SysMovie(sys)
            
            if ~isempty(sys.indx)
                
                if (abs(sys.lens(sys.indx).Radius_Left)==inf)||(abs(sys.lens(sys.indx).Radius_right)==inf)
                    if abs(sys.lens(sys.indx).Radius_Left)==inf
                        Rl=0;
                        Rr=1;
                    end
                    if abs(sys.lens(sys.indx).Radius_right)==inf
                        Rr=0;
                        Rl=1;
                    end
                else
                    Rl=1;
                    Rr=1;
                end
                
                set(sys.lens(sys.indx).rect,...
                    'pos',[sys.lens(sys.indx).x  -sys.lens(sys.indx).Height/2  sys.lens(sys.indx).Width  sys.lens(sys.indx).Height ],...
                    'FaceColor', sys.lens(sys.indx).Color,'Curvature',[Rl Rr]);
                %, 'ButtonDownFcn',{@fun,sys.indx }));
                %set(sys.arrow_index,'position',sys.lens(sys.indx).x+sys.lens(sys.indx).Width/2,ylim(2))
            end
            
        end
        function ResetSystem(sys)
            sys.lens=[];
            sys.indx=0;
            sys.update;
        end
        function [xmin xmax ymin ymax]=WhoIsTheMost(sys)
            X=[] ;H=[];
            if ~isempty(sys.lens)
                X=zeros(1,length(sys.lens));
                H=zeros(1,length(sys.lens));
                
                for n=1:length(sys.lens)
                    X(n)=sys.lens(1,n).x+sys.lens(1,n).Width;
                    H(n)=sys.lens(1,n).Height;
                end
                
            end
            xmin=0;
            xmax=max(X);
            
            ymin=min(-H);
            ymax=max(H);
        end
        
    end
    
end
