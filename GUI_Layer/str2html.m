function html= str2html(text,color,style,imgicon)
% created by oren berkovitch orenber@hotmail.com
img='';
 
if nargin<3
   style='';
   
 if  isnumeric(color)
    % rgb
     color=strcat('rgb(',strrep(num2str(color),'  ',','),')');
 end 
     
 if  isnumeric(text)
     text=num2str(text);
     
 end
   
   
elseif nargin==4
   currentFolder = which(imgicon(max(cell2mat(regexp(imgicon,{'\', '/'})))+1:end));
   img=strcat('<img src="file:/',currentFolder,'"/>');


   
   
end




 html=['<html><style>table{',style,'}</style><table color=',color,...
     '><TR>',img,'<TD><p>',text,'</p></TD></TR></table></html>'];

 
 
end