% arrow demo
figure
xlim([-5,5])
ylim([-5,5])
%% create Arrow
ar = Arrow([-10 2],[-10,3]);
%% set  position
ar.updatePosition([-4 -2],[-4,-1]) 
%% set color 
ar.color = 'red'
%% set higth negative

