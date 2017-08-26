function sysplot(varargin)  

lens=varargin;


num=size(varargin,2);
clf


MaxlensX=lens{1}.x+lens{1}.Width;
MaxlensY=lens{1}.Height;
MinlensY=lens{1}.Height;
for k=1:num
    
    if lens{k}. Index_in==1
        
        continue
    end
    
    
    % find the max x  higth width of the lens
    if (lens{k}.x+lens{k}.Width>MaxlensX)
    MaxlensX=lens{k}.x+lens{k}.Width;
    end
    
    if (lens{k}.Height>MaxlensY)
    MaxlensY=lens{k}.Height;
    
    end
    
    if (lens{k}.Height<MinlensY)
        MinlensY=lens{k}.Height;
    end
    
    if (lens{k}.Radius_Left~=inf||lens{k}.Radius_rigth~=inf)
        cur=[1 1];
        
    else 
        cur=[ 0 0 ];
    end
    
    if lens{k}.Width==0
        lens{k}.Width=0.01;
    end
    
   rectangle('pos',[lens{k}.x  0  lens{k}.Width lens{k}.Height ],'FaceColor', lens{k}.Color,'Curvature',cur)
    
end
% Create arrow


axis([0,MaxlensX+20,0,MaxlensY+10]);
grid on
annotation('arrow',[0.13 0.13],...
    [0.1 MinlensY/(MaxlensY+10);],'HeadLength',15,'HeadWidth',15,...
    'LineWidth',3);

end
