%% create withe borad

f = figure;
a = axes('parent',f);
xlim([0 ,10])
ylim([0,10])
%% create lens

lens = Lens()
lens.x = 5;

%% lens focal
lens.focal

%% get radius left and rigth

lens.radius_left=1.6

lens.radius_right=-1.6
lens.focal
%% set new focal 

lens.radius_left=0.0014

lens.radius_right=-0.014


%% set focal 

lens.setFocal(0.3)
lens.radius_left
lens.radius_right
lens.focal