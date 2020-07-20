close all
clear
clc

%% crete system optic
sys = SystemOptic()

a = gca;
sys.createAxesBanch(a)

%% create 3 lens 
len1 = Lens()
len2 = Lens()
len3 = Lens()
%% update position lens
len1.x = 10
len2.x= 16
%% add lens to the system
sys.addLens(len1)
sys.addLens(len2)
sys.addLens(len3)
sys.lens
%% check the system matrix 
sys.matrix

%% change lens position
len3.x = 3

%% change len index 
len3.index_in = 1.1
%% check the system matrix update
sys.matrix

%% remove lens

sys.removeLens(len3)

%% create ray ligth 
ray = Ray(sys,'ax',a)
%% add ray to teh system
sys.addRay(ray)
%% calculate raypath
ray.rayPath();
ray.draw = true

%% turn off plot 
ray.draw = false

%% turn on plot 
ray.draw = true
%% change ray position
for n = [-5:0.01:5,5:-0.01:0]
ray.y = n;
drawnow()
end
 
%% change  ray color 
ray.color = 'blue'

%% change ray angle
ray.teta = [-30,0,30]

%% change 
for n = 1:0.1:180
ray.teta = [n,10*sin(n),-n];
drawnow()
end
ray.y = 2
%% claclute ray path 
ray.rayPath()
%% create figure
fig = Fig()
fig.addRay(ray)

%% add fig to the system
sys.addFigure(fig)
%% create figure 

fig.figure()

%% plot 
fig.plot()

%%
for n = 1:0.1:25
    
fig.y = 2*sin(n);
fig.x = cos(n);

drawnow()
end

%% update figure position 
fig.x = 0;
fig.y = 0
fig.height  =2

%% add more lens to the system
sys.addLens(Lens('x',5,'y',2))

sys.addLens(Lens('x',8,'y',-150))
l4 = Lens('x',5,'y',-7)
sys.addLens(l4)

%% show all system 
sys.showAllView(0.1)


%% reset system
tic
sys.resetSystem()
toc
sys.matrix
