function data_color = paintColumeTable(data,colors)
% created by oren berkovitch orenber@hotmail.com
%% color = {'blue','red','green'};
nrow = size(data,1);
ncol = size(data,2);

nc = numel(colors);
data_color = cell(nrow,ncol);

for col = 1:ncol
    color_num = numberbase(col,nc);
    for row = 1:nrow
        data_color(row,col) = str2html(data(row,col),colors{color_num});
    end
end
end


function num = numberbase(number,base)
num = mod(number,base);
if num ==0
    num = base;
end

end