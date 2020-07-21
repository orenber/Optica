classdef Lens <Space
    %  Build a lens as you wish
    %  06/08/2014  in case the input is not anumber bug fix
    % created by oren berkovitch orenber@hotmail.com
    events
        Update
    end
    
    
    properties (GetAccess = public ,SetAccess=public)
        
        index_in@double = 1.4
        radius_left@double = 0.16
        radius_right@double = -0.16
        width@double = 0.01
        height@double=6
        color@char = 'Blue'
        interface=[]
        rect=[]
        x@double=0
        y@double=0
        focal@double
        axes
        parent
    end
    
    properties (GetAccess = private, SetAccess = private)
        listner_destroyed
    end
    
    properties (Constant,GetAccess = private)
        
        color_collection = {'Blue',...
            'Red',...
            'Yellow',...
            'Green',...
            'Cyan',...
            'Magenta',...
            'Black',...
            'White'};
        
    end
    methods
        %constructor
        function len = Lens(varargin)
            
            setup_input = varargin2struct(varargin{:});
            setup_defult = struct('y',-len.height/2,'axes',gca);
            setup = mergestruct(setup_defult,setup_input);
            
            for  field =  fieldnames(setup)'
                fieldStr = field{1};
                len.(fieldStr) = setup.(fieldStr);
            end
            
            radiuSum = abs(len.radius_right) +abs(len.radius_left);
            len.rect = rectangle(...
                'Position',[len.x, len.y, len.width, len.height ],...
                'FaceColor', len.color,...
                'EdgeColor',len.color,...
                'Curvature',abs([len.radius_right/radiuSum ,...
                len.radius_left/radiuSum]),...
                'Parent',len.axes,...
                'ButtonDownFcn',@(h,e)len.ButtonDownFcn());
            len.parent = ancestor(len.axes,{'figure'},'toplevel');
            len.listner_destroyed = addlistener(len,'ObjectBeingDestroyed',@(h,e)len.destroyed(h,e));
        end
        
        function destroyed(len,~,~)
            
            len.delete();
        end
        
        %Calculate its outgoing beam from the lens
        function r = pos(len,Yin )
            r = mat(len)*Yin;
        end
        %Lens matrix calculation
        function mat(len)
            
            %Placing variables
            ni = len.index_in;
            no = len.index_out;
            Rl = len.radius_left;
            Rr = len.radius_right;
            d =  len.width;
            
            %Lens matrix calculation
            MRleft = [1 0;(no/ni-1)/Rl no/ni]  ;
            
            Md = [1 d;0 1];
            MRright = [1 0;(ni/no-1)/Rr  ni/no];
            len.matrix = MRright*Md*MRleft;
            
            len.interface(:,:,1) = MRleft;
            len.interface(:,:,2) = MRright;
        end
        %Lens matrix calculation in parameters
        function matrix = getMatrix(len)
            
            syms no ni Rl Rr d;
            
            %---------Thin lens------------
            %If the thickness of the lens is negligible
            %This is a thin lens
            if (len.width>0)&&(len.width<=0.01)
                d=0;
            end
            
            % ------Refraction---------
            %If the radius of the left lens is infinite
            %It is a flat surface on the left
            if len.radius_left==inf
                Rl=inf;
            end
            % if the radius of the right lens is infinite
            % It is a flat surface from the right
            if len.radius_right==inf
                Rr=inf;
            end
            
            % ------Translation---------
            %If the index of refraction of the lens is equal to the index of refraction of the outer space
            %This is an empty space
            if len.index_out==1
                no=1;
            end
            
            if len.index_in==1
                ni=1;
            end
            
            %Lens matrix calculation in parameters
            Mright  =[1 0;(no-ni)/(Rl*no) ni/no] ;
            Md=[1 d;0 1];
            Mleft  =[1 0;(ni-no)/(Rr*ni) no/ni];
            
            matrix = Mright*Md*Mleft;
            
        end
        
        
        
        function set.index_in(len,val)
            assert(~isnan(val),'value is not number')
            if val<0
                val=0;
            end
            if len.index_in ~= val
                len.index_in = val;
                len.update()
            end
        end
        
        function set.radius_left(len,val)
            assert(~isnan(val),'value is not number')
            
            if len.radius_left ~= val
                len.radius_left = val;
                len.update()
            end
        end
        
        function set.radius_right(len,val)
            
            assert(~isnan(val),'value is not number')
            
            
            if len.radius_right ~= val
                len.radius_right = val;
                len.update()
            end
        end
        
        function set.height(len,val)
            assert(~isnan(val),'value is not number')
            if val<=0
                val=0.01;
            end
            
            if len.height ~= val
                len.height = val;
                len.update();
            end
        end
        
        function set.width(len,val)
            assert(~isnan(val),'value is not number')
            if val<=0
                val=0.01;
            end
            
            if len.width ~= val
                len.width = val;
                len.update();
            end
        end
        
        function set.color(len,color)
            index = strcmpi(len.color_collection,strtrim(color));
            therIsColor = any(index);
            assert(therIsColor,['the color input must be from type: ',...
                strjoin([len.color_collection],', ')])
            len.color = len.color_collection{index};
            len.draw()
        end
        
        function set.x(len,x_pos)
            if  len.x ~= x_pos
                len.x = x_pos;
                len.update();
            end
        end
        
        function set.y(len,y_pos)
            if len.y ~= y_pos
                len.y = y_pos;
                len.update();
            end
        end
        
        
        function draw(len)
            
            [Rl,Rr] = len.radius2Draw();
            set(len.rect,...
                'position',[len.x, len.y, len.width, len.height ],...
                'FaceColor', len.color,...
                'EdgeColor',len.color,...
                'Curvature',[Rl,Rr]...
                );
            
        end
        
        function delete(len)
            
            delete(len.rect)
        end
    end
    
    methods (Access = protected)
        function focalUpdate(len)
            
            [ni,no] = deal(len.index_in,len.index_out);
            [Rl,Rr] =deal(len.radius_left,len.radius_right) ;
             d = len.width;
            len.focal  = ((ni -no)*(1/Rl - 1/Rr+(ni -no)*d/(ni*Rl*Rr)))^-1;
            
                 
        end
    end
    
    methods (Access = protected)
        
        
        
        function ButtonDownFcn(len,~)
            
            
            set(len.parent,'WindowButtonMotionFcn',@len.MotionFcn);
            set(len.parent,'WindowButtonUpFcn',@len.ButtonUpFcn)
            set(len.parent,'WindowButtonDownFcn','');
            
        end
        
        function MotionFcn(len,~,~)
            Ixy=get(len.axes,'CurrentPoint');
            
            len.x = Ixy(1,1)-len.width/2;
            
        end
        
        function ButtonUpFcn(len,~,~)
            
            set(len.parent,'WindowButtonMotionFcn','');
            set(len.parent,'WindowButtonUpFcn','')
            
        end
        
        function [Rl,Rr] = radius2Draw(len)
            
            if (abs(len.radius_left)==inf)||(abs(len.radius_right)==inf)
                if abs(len.radius_left)==inf
                    Rl = 0;
                    Rr = 1;
                end
                if abs(len.radius_right)==inf
                    Rr = 0;
                    Rl = 1;
                end
                
            else
                Rl = 1;
                Rr = 1;
            end
        end
        
        function update(len)
            len.mat();
            len.focalUpdate()
            len.draw()
            notify(len,'Update')
        end
    end
end
