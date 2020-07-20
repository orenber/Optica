clear 
close all
%% demo fig 
figure
xlim([-5,5])
ylim([-5,5])
%% create figure defult object
f1 = Fig()
%% create figure wite setup
f2 = Fig('x',2,'y',-2,'color','blue')
%% create figure wite setup
f3 = Fig('x',-4,'y',-2,'height',-2,'color','Magenta')
%% update x position
f1.x = 3
%% update y and x position
f2.y = 0
f2.x = 0
%% update height
f3.height = 3
%% run animation
for n = 1:0.02:15
    f1.x = cos(n);
    f2.y = sin(n);
    f2.x = cos(n);
    f2.height = cos(n)/2;
    f3.height = 4*sin(n);
    drawnow();
end

%% update color

f3.color ='cyan'
%% set fig viseble off
f3.draw = false
%% set fig viseble on
f3.draw = true


%% delete object 
delete(f1)
delete(f2)
delete(f3)