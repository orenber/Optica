classdef Lens <SysOptic
    %  Build a lens as you wish
    %  06/08/2014  in case the input is not anumber bug fix
    properties (GetAccess = public ,SetAccess=public)
        
        Index_in@double = 1.4
        Radius_Left@double = 0.16
        Radius_right@double = -0.16
        Width@double = 0.01
        Height@double=6
        Color@char = 'Blue'
        Interface=[]
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
        %constructor
        function len = Lens(Index_in,radius_left,radius_right,Height,width,color)
            if nargin>0
                len.Index_in=Index_in;
                len.Radius_Left=radius_left;
                len.Radius_right=radius_right;
                len.Height=Height;
                len.Width=width;
                len.Color=color;
            end
            len.update();
        end
        %Calculate its outgoing beam from the lens
        function r = pos(len,Yin )
            r=   mat(len)*Yin;
        end
        %Lens matrix calculation
        function mat(len)
            
            %Placing variables
            ni =len.Index_in;
            no=len.Index_out;
            Rl= len.Radius_Left;
            Rr= len.Radius_right;
            d=  len.Width;
            
            %Lens matrix calculation
            MRleft=[1 0;(no/ni-1)/Rl no/ni]  ;
            
            Md=[1 d;0 1];
            MRright=[1 0;(ni/no-1)/Rr  ni/no];
            len.M= MRright*Md*MRleft;
            
            len.Interface(:,:,1)=MRleft;
            len.Interface(:,:,2)=MRright;
        end
        %Lens matrix calculation in parameters
        function M = Mat(len)
            
            syms no ni Rl Rr d;
            
            %---------Thin lens------------
            %If the thickness of the lens is negligible
            %This is a thin lens
            if (len.Width>0)&&(len.Width<=0.01)
                d=0;
            end
            
            % ------Refraction---------
            %If the radius of the left lens is infinite
            %It is a flat surface on the left
            if len.Radius_Left==inf
                Rl=inf;
            end
            % if the radius of the right lens is infinite
            % It is a flat surface from the right
            if len.Radius_right==inf
                Rr=inf;
            end
            
            % ------Translation---------
            %If the index of refraction of the lens is equal to the index of refraction of the outer space
            %This is an empty space
            if len.Index_out==1
                no=1;
            end
            
            if len.Index_in==1
                ni=1;
            end
            
            %Lens matrix calculation in parameters
            Mright  =[1 0;(no-ni)/(Rl*no) ni/no] ;
            Md=[1 d;0 1];
            Mleft  =[1 0;(ni-no)/(Rr*ni) no/ni];
            
            M=Mright*Md*Mleft;
            
        end
        
        function set.Index_in(len,val)
            if isnan(val)==1
                % in case val is not number
                return
            elseif val<0
                val=0;
            end
            len.Index_in=val;
            len.update
        end
        
        function set.Radius_Left(len,val)
            if isnan(val)==1
                % in case val is not number
                return
            elseif val==0
                
                val=0.01;
            end
            len.Radius_Left=val;
            len.update
        end
        
        function set.Radius_right(len,val)
            if isnan(val)==1
                % in case val is not number
                return
            elseif val==0
                
                val=0.01;
            end
            len.Radius_right=val;
            len.update
        end
        
        function set.Height(len,val)
            if isnan(val)==1
                % in case val is not number
                return
            elseif val<=0
                val=0.01;
            end
            len.Height=val;
        end
        
        function set.Width(len,val)
            if isnan(val)==1
                % in case val is not number
                return
            elseif (val<=0)
                val=0.01;
            end
            len.Width=val;
            len.update;
        end
        
        function set.Color(len,color)
          index = strcmpi(len.color_collection,strtrim(color));
          therIsColor = any(index);
          assert(therIsColor,['the color input must be from type: ',...
              strjoin([len.color_collection],', ')])
          len.Color = len.color_collection{index};    
        end
        
        function update(len)
            len.mat;
            len.fc;
            len.VHf;
            len.VHb;
            len.X;
            len.Ma;
            
        end
        
        
    end
end
