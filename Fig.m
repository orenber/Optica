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
    properties
        obj=struct('y',0, 'x', 0,'Heigth',2)
     
    end
    properties (SetAccess = private, GetAccess = public   )
        RealFig=[]
        ImgFig=[]
        ray=[]
    end
    properties (SetAccess = private, GetAccess = private   )
      Arr=[];
    end
       
    methods
     
        function fig=Fig(Ray)
             %--Constructor--
            if isa(Ray,'Ray')==1
              fig.ray=Ray;
              fig.obj.Heigth=fig.ray.y;
            else
            end
          
        end

        function Figure(fig)
            %Calculates the actual location creating virtual figures 
            % and the real figures according to points of intersection of the rays of light
            
            fig.RealFig=[];
            fig.ImgFig=[];
            
               if ~isempty(fig.ray)
                   fig.ray.RayIn
                   if ~isempty(fig.ray.xyr)
                  YX= size(fig.ray.xyr);
                  Y=YX(1);
                  
                  lens=fig.ray.systemoptic.ArrengeMatrix;
                   for n=1:1:length(lens)
                       % intialez the  A*X=B 
                       A=zeros(1,2);B=zeros(1,2);
                              for m=1:Y
                                           x=fig.ray.xyr{m,1+2*n}(1);
                                           y=fig.ray.xyr{m,1+2*n}(2);
                                           r=fig.ray.xyr{m,1+2*n}(3);
                                        
                                           % if the ray pass above or down
                                           % the Lens dont take into count
                                         if (y>lens(n).Height/2)||(y<-lens(n).Height/2)
                                             continue
                                         end
                              A(m,:)=[1,-tand(r)];
                              B(m,1)=y-x*tand(r);
                              

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
                            if (length(lens)>n)
                                % is the image is pass the front lens?
                                if Zx>(lens(n+1).x)
                                continue
                                end
                            end
                                          fig.RealFig(length(fig.RealFig)+1).x=Zx;
                                          fig.RealFig(length(fig.RealFig)).y=Zy;
                                          fig.RealFig(length(fig.RealFig)).M=Zy/fig.obj.Heigth;
                                  % if the image is behind the lens this is virtual image
                       elseif  Zx<lens(n).x 
                                          fig.ImgFig(length(fig.ImgFig)+1).x=Zx;
                                          fig.ImgFig(length(fig.ImgFig)).y=Zy;
                                          fig.ImgFig(length(fig.ImgFig)).M=Zy/fig.obj.Heigth;
                       end
                   end    
                   
                   
                   end
               end   
        end
        
        function PlotFig(fig)
   %% Draw the figures according to their location on the X axis
            
            
            % calculate the Real and The virtual image
            fig.Figure
            fig.obj.Heigth=fig.ray.y;
            %% Plot all the Arrow (Real and Virtual Figure)
            
            set(gca,'NextPlot','replacechildren')
            newplot
            % plot the object
                 fig.obj.arrObj=arrow([fig.obj.x  fig.obj.y],[fig.obj.x  fig.obj.Heigth],...
                             'FaceColor','g','LineWidth',0.2);
                             set(fig.obj.arrObj,'HandleVisibility','off')
            
            % plot all the real image
            if ~isempty(fig.RealFig)
                
                        for Nrel=1:length(fig.RealFig)
                            color='r';
                            if (fig.RealFig(Nrel).x-rem(fig.RealFig(Nrel).x,1e-010))==(fig.ray.systemoptic.L-rem(fig.ray.systemoptic.L,1e-010))
                                color='m';
                            end
                                fig.RealFig(Nrel).arrRe=arrow([fig.RealFig(Nrel).x  0],[fig.RealFig(Nrel).x  fig.RealFig(Nrel).y],...
                                'ButtonDownFcn',{@RealImgData,Nrel},'FaceColor',color,'LineWidth',abs(0.1*fig.RealFig(Nrel).M));
                                set(fig.RealFig(Nrel).arrRe,'HandleVisibility','off')
                        end

                        
            end
            % plot all the virtual figure
            if ~isempty(fig.ImgFig)
             
                        for Nimg =1:length(fig.ImgFig)
                                                  color='b';
                            if (fig.ImgFig(Nimg).x-rem(fig.ImgFig(Nimg).x,1e-010))==(fig.ray.systemoptic.L-rem(fig.ray.systemoptic.L,1e-010))
                                color='c';
                            end
                             fig.ImgFig(Nimg).arrIm=arrow([fig.ImgFig(Nimg).x  0],[fig.ImgFig(Nimg).x  fig.ImgFig(Nimg).y],...
                             'ButtonDownFcn',{@VirtualImgData,Nimg},'FaceColor',color,'LineWidth',abs(0.1*fig.ImgFig(Nimg).M));
                             set(fig.ImgFig(Nimg).arrIm,'HandleVisibility','off')
                        end

            end
            
           
             %% show the figure data function 
             
            function VirtualImgData(~,~,NumImg)
         
                
                text(fig.ImgFig(NumImg).x,fig.ImgFig(NumImg).y*1.02,...
                      char(strcat('x=',num2str(fig.ImgFig(NumImg).x)),...
                             strcat('y=',num2str(fig.ImgFig(NumImg).y)),....
                             strcat('M=',num2str(fig.ImgFig(NumImg).M))...
                            )...
                      )
                
            end
            
        function RealImgData(~,~,NumImg)
                
                text(fig.RealFig(NumImg).x,fig.RealFig(NumImg).y*1.02,...
                      char(strcat('x=',num2str(fig.RealFig(NumImg).x)),...
                             strcat('y=',num2str(fig.RealFig(NumImg).y)),....
                             strcat('M=',num2str(fig.RealFig(NumImg).M))...
                            )...
                      )
                
            end
        end
        
        function LockFig(fig,state)
             %% set all arrow 'HandleVisibility','on'
            try
                    % object 'HandleVisibility','on'
                     set(fig.obj.arrObj,'HandleVisibility',state)

                     % real Image 'HandleVisibility','on'
                     if ~isempty(fig.RealFig)
                                for Nrel =1:length(fig.RealFig)

                                     set(fig.RealFig(Nrel).arrRe,'HandleVisibility',state)
                                end
                     end
                     % virtual Image 'HandleVisibility','on'
                     if ~isempty(fig.ImgFig)
                                for Nimg =1:length(fig.ImgFig)

                                     set(fig.ImgFig(Nimg).arrIm,'HandleVisibility',state)
                                end
                     end
             catch  err
                    disp(err.message)
             end
        end
         
        function [xmin,xmax,ymin,ymax]= WhosIsTheMost(fig)
            %% Calculates the location farthest character and high \ low to determine the size of the axes
          
            Xim=[];Yim=[];
            Xrel=[];Yrel=[];
             

             % check if Img figures exist
            if ~isempty(fig.ImgFig)
                Xim=zeros(1,length(fig.ImgFig));
                Yim=zeros(1,length(fig.ImgFig));
                for n=1:length(fig.ImgFig)
                    
                    Xim(n)=fig.ImgFig(n).x;
                    Yim(n)=fig.ImgFig(n).y;
                    
                end
                
            end
            
            if ~isempty(fig.RealFig)
                Xrel=zeros(1,length(fig.RealFig));
                Yrel=zeros(1,length(fig.RealFig));
                for n=1:length(fig.RealFig)
                    
                    Xrel(n)=fig.RealFig(n).x;
                    Yrel(n)=fig.RealFig(n).y;
                    
                end
                
            end
                    
            X=horzcat(Xim,Xrel,fig.obj.x);
            Y=horzcat(Yim,Yrel,fig.obj.Heigth);
            
            xmin=min(X);
            xmax=max(X);
            
            ymin=min(Y);
            ymax=max(Y);
          
        end
    end
    
end