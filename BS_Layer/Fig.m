classdef Fig <handle
    %FIG Summary of this class goes here
    %   Detailed explanation goes here
    %   02/08/2014 figure of the object:
    %   green arrow: object
    %   red arrow : real image
    %   blue  arrow: virtual image
    %   cyan arrow : virtual image of the system lens
    %   magenta arrow : real image of the system lens
    
    %   4/08/2014 rank(A) bug fix
    % created by oren berkovitch orenber@hotmail.com
    events
        Update
    end
    
    properties
        y@double = 0
        x@double = 0
        height@double = 2
        color  = 'green'
        
        
    end
    properties (Hidden)
        cleanup
    end
    properties (SetObservable,SetAccess = public, GetAccess = public )
        draw@logical =  false;
        
    end
    properties (SetAccess = private, GetAccess = public   )
        RealFig = struct('x',[],'y',[],'height',[],'M',[],'hObject',[]);
        ImgFig  = struct('x',[],'y',[],'height',[],'M',[],'hObject',[]);
        ray@Ray
        displayObj@Arrow
    end
    properties (SetAccess = private, GetAccess = private   )
        hObjectArr = {[]};
        listner_draw
        listener_ray
        listner_destroyed
        dataText
        parent
       
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
    
    methods (Access = public)
        
        function fig=Fig(varargin)
            
            setup_defult = struct('x',0,'y',0,'height',2,'color','green',...
                'parent',gca);
            setup_input = varargin2struct(varargin{:});
            setup = mergestruct(setup_defult,setup_input);
            
            fig.displayObj = Arrow([0 0],[0,0],setup.color,...
                'EdgeColor',setup.color,...
                'Parent',setup.parent);
   
            fig.parent = setup.parent;
            fig.color = setup.color;
            fig.x = setup.x;
            fig.y = setup.y;
            fig.height = setup.height;
            fig.listner_draw = addlistener(fig,'draw','PostSet',@(h,e)fig.view(h,e));
            fig.draw = true;
            fig.listner_destroyed = addlistener(fig,'ObjectBeingDestroyed',@(h,e)fig.destroyed(h,e));
            
            
            
        end
        
        function destroyed(fig,~,~)
            
            delete(fig.displayObj)
            fig.delete([fig.RealFig.hObject,fig.ImgFig.hObject])
        end
        
        function addRay(fig,ray)
            
            fig.ray=ray;
            fig.listener_ray = addlistener(ray...
                ,'Update',@(h,e)fig.viewImages(h,e));
        end
        
        function figure(fig)
            %Calculates the actual location creating virtual figures
            % and the real figures according to points of intersection of the rays of light
            i = 0;
            j = 0;
            fig.RealFig(10) = struct('x',[],'y',[],'height',[],'M',[],'hObject',[]);
            fig.ImgFig(10) = struct('x',[],'y',[],'height',[],'M',[],'hObject',[]);
            if ~isempty(fig.ray)
                fig.ray.rayPath
                if ~isempty(fig.ray.xyr)
                    YX= size(fig.ray.xyr);
                    Y=YX(1);
                    
                    lens = fig.ray.systemoptic.arrengeMatrix();
                    lensSum = length(lens);
                    for n=1:lensSum
                        % intialez the  A*X=B
                        A=zeros(1,2);B=zeros(1,2);
                        for m=1:Y
                            x = fig.ray.xyr{m,1+2*n}(1);
                            y = fig.ray.xyr{m,1+2*n}(2);
                            r = fig.ray.xyr{m,1+2*n}(3);
                            
                            % if the ray pass above or down
                            % the Lens dont take into count
                            if (y>lens(n).height/2)||(y <-lens(n).height/2)
                                continue
                            end
                            A(m,:) = [1,-tand(r)];
                            B(m,1) = y-x*tand(r);
                            
                            
                        end
                        % in case ther is no solution the eq
                        if eq(A(1,2),A(:,2))
                            
                            continue
                        elseif rank(A)==1
                            continue
                        end
                        
                        % find the intersect point of the line
                        Z=A\B;
                        Zx=Z(2);
                        Zy=Z(1);
                        
                        % if the size of the image is Zero continue
                        if (Z(1)==0)
                            continue
                        end
                        
                        % is the image is infront of the lens?
                        if  Zx> lens(n).x
                            % is ther is another lens farward?
                            if (lensSum > n)
                                % is the image is pass the front lens?
                                if Zx>(lens(n+1).x)
                                    
                                    continue
                                end
                            end
                            i = i+1;
                            
                            fig.RealFig(i).x = Zx;
                            fig.RealFig(i).y = 0;
                            fig.RealFig(i).height=Zy;
                            fig.RealFig(i).M = Zy/fig.height;
                            
                            % if the image is behind the lens this is virtual image
                        elseif  Zx<lens(n).x
                            j = j+1;
                            fig.ImgFig(j).x = Zx;
                            fig.ImgFig(j).y = 0;
                            fig.ImgFig(j).height = Zy;
                            fig.ImgFig(j).M = Zy/fig.height;
                            
                        end
                        
                    end
                    fig.RealFig = fig.useHobjectIfExist(fig.RealFig,i);
                    fig.ImgFig = fig.useHobjectIfExist(fig.ImgFig,j);
                    
                end
            end
        end
        
        function hObjArr = useHobjectIfExist(fig,hObjectArr,index)
            
            if index ~= 0
                
                hObjArr =  hObjectArr(1:index);
            else
                % initilize struct
                hObjArr = struct('x',[],'y',[],'height',[],'M',[],'hObject',[]);
            end
        end
        
        
        function plot(fig)
            %% Draw the figures according to their location on the X axis
            % calculate the Real and The virtual image
            if ~isempty(fig.ray.systemoptic.lens)
                fig.figure()
            end
            
            %% Plot all the Arrow (Real and Virtual Figure)
            % plot all the real image
            fig.RealFig = fig.craeteRealAndImgFigure(fig.RealFig,{'red','Magenta'});
            % plot all the virtual figure
            fig.ImgFig = fig.craeteRealAndImgFigure(fig.ImgFig,{'blue','cyan'});
            
        end
        
        function [opticFigure] = craeteRealAndImgFigure(fig,opticFigure,colorType)
            % plot all the virtual figure
            Color=colorType{1};
            for n = 1:length(opticFigure)
                if isempty(opticFigure(n).x)
                    continue
                end
                if (opticFigure(n).x-rem(opticFigure(n).x,1e-010))==(fig.ray.systemoptic.L-rem(fig.ray.systemoptic.L,1e-010))
                    Color = colorType{2};
                end
                if isempty(opticFigure(n).hObject)
                    
                    opticFigure(n).hObject = Fig('x', opticFigure(n).x,...
                        'y',opticFigure(n).y,...
                        'height', opticFigure(n).height,'color',Color);
                    %'ButtonDownFcn',{@VirtualImgData,Nimg},'FaceColor',Color,'LineWidth',abs(0.1*fig.ImgFig(Nimg).M));
                    %set(fig.ImgFig(Nimg).arrIm,'HandleVisibility','off')
                    
                else
                    
                    opticFigure(n).hObject.x =  opticFigure(n).x;
                    opticFigure(n).hObject.height =  opticFigure(n).height;
                    opticFigure(n).hObject.color = Color;
                    
                end
            end
            
        end
        
        
        %% show the figure data function
       
 
        function dataShow(fig,~,~)
             
       fig.dataText = text(fig.x,(fig.y+fig.height)*1.15,...
       sprintf('x = %g\ny = %g\nheight = %g',fig.x,fig.y,fig.height),...
                'BackgroundColor',[0.7,0.9,0.8]);
            
        end
        
        function deleteText(fig,~,~)
            
            delete(fig.dataText)
        end
     
        function delete(fig,h,e)
            if isvalid(fig)
                delete(fig.displayObj)
                % delete his children
                fig.deleteChildren(fig.RealFig);
                fig.deleteChildren(fig.ImgFig);
                
            end
        end
        
        function deleteChildren(fig,childrensFig)
            for t = 1:numel(childrensFig)
                if ~isempty(childrensFig(t).hObject)
                    delete(childrensFig(t).hObject)
                end
            end
        end
        
    end
    
    
    
    
    methods
        
        function set.height(fig,val)
            if fig.height~=val
                if val==0
                    val=0.3;
                end
                fig.height=val;
                fig.update();
            end
        end
        
        function set.color(fig,color)
            index = strcmpi(fig.color_collection,strtrim(color));
            therIsColor = any(index);
            assert(therIsColor,['the color input must be from type: ',...
                strjoin([fig.color_collection],', ')])
            if strcmpi(fig.color,fig.color_collection{index})
                fig.color = fig.color_collection{index};
                fig.displayObj.color = fig.color;
            end
        end
        
        function set.x(fig,x_pos)
            if fig.x~= x_pos
                fig.x = x_pos;
                fig.update();
            end
        end
        
        function set.y(fig,y_pos)
            if fig.y~= y_pos
                fig.y = y_pos;
                fig.update();
            end
        end
        
        
    end
    
    methods (Access = private)
        
        function drawFig(fig)
            
            fig.displayObj.updatePositionAndDraw([fig.x,fig.y],...
                [fig.x, fig.y+fig.height]);
            
        end
        
        function view(fig,h,e)
            if fig.draw
                fig.drawFig();
                set(fig.displayObj.hArrow,'visible','on');
                
            else
                set(fig.displayObj.hArrow,'visible','off')
            end
            
        end
        
        function viewImages(fig,h,e)
            if fig.draw
                fig.plot();
            end
        end
        
        
        function update(fig)
            if fig.draw
                fig.drawFig()
            end
            
            notify(fig,'Update')
        end
    end
    
end