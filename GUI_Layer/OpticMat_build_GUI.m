%% figure
function handles = OpticMat_build_GUI(handles)
% created by oren berkovitch orenber@hotmail.com

set(handles.figure_opticMat,...
    'name','Optica',...
    'menubar','none',...
    'unit','normalized',...
    'resize','on',...
    'position',[ 0.25  0.15   0.45   0.45],...
    'tag','OpticMat',...
    'Visible','on');

%% main panel
handles.panel_main = uipanel('parent',handles.figure_opticMat,...
    'BorderType','none');

%% Separator
handles.mainHBox = uiextras.HBox( 'Parent',handles.panel_main,...
    'Spacing', 5,'Tag','mainHBox');
 
handles.vBoxFlex_lensAndSystem = uiextras.VBoxFlex(...
    'Parent',handles.mainHBox,'Spacing', 5 ,...
    'Tag','vBoxFlex_lensAndSystem');

handles.title_color = { 'ForegroundColor','k',...
    'TitleColor',[207,220,234]/255};
handles = lens_frame(handles); 
%% system panel
handles = system_frame(handles);
set(handles.vBoxFlex_lensAndSystem,'Heights',[-100 ,-100])
%handles.panelAxesAndRay = uiextras.Panel('Parent',handles.mainvBoxFlex)
handles.vBox_axesAndRays = uiextras.VBox(...
    'Parent',handles.mainHBox,...
    'Spacing', 5,'Tag','vBox_axesAndRays');

 set(handles.mainHBox ,'Widths',[250,-100])
%% axes_frame
handles = axes_frame(handles);
%% ray panel 
handles = ray_frame(handles);

set(handles.vBox_axesAndRays,'Heights',[-100 ,180])


end



function handles = lens_frame(handles)

%% lens Panel -------------------------------
handles.boxPanel_lens = uiextras.BoxPanel(... 
    'Title', 'Lens Propertise', ...
    handles.title_color{:},... 
    'Tag','boxPanel_lens',...
    'Parent', handles.vBoxFlex_lensAndSystem);

%% 
handles.vbox_lens = uiextras.VBox( 'Parent',handles.boxPanel_lens,...
    'Spacing', 5,'Tag','vbox_lens');

handles.hBox_adjusment_lens = uiextras.HBox('Parent',handles.vbox_lens,...
    'Tag','hBox_adjusment_lens');
%% add lens 
handles.buttom_add_lens = uicontrol('Parent',handles.hBox_adjusment_lens,...
            'string',str2html('Add lens','black',[],'icons/plus.png'),...
            'Tag','buttom_add_lens',...
            'callback',@(h,e)OpticMat('addLensCallback',h,e,guidata(h)...
            ));
 %% Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
%% remove lens
handles.buttom_remove_lens = uicontrol('Parent',handles.hBox_adjusment_lens,...
    'string',str2html('Remove lens','black',[],'icons/minus.png'),...
    'Tag','buttom_remove_lens',...
    'callback',@(h,e)OpticMat('removeLensCallback',h,e,guidata(h)));
%Icons made by <a href="https://www.flaticon.com/authors/pixel-perfect" title="Pixel perfect">Pixel perfect</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

%% lens propertise
handles.panel_lens_propertise =  uiextras.Panel( 'Parent',handles.vbox_lens,...
    'Title', 'Lens Index:','BorderType','none');

handles.table_lens_propertise = uitable(...
    'Parent',handles.panel_lens_propertise,...
    'RowName',fieldnames(handles.setup.lens),...
    'ColumnWidth',{110},'Tag','table_lens_propertise',...
    'FontWeight','Bold','FontSize',8,'ColumnName',{'Value'},...
    'ColumnEditable',true,...
    'CellEditCallback',@(h,e)OpticMat('table_lens_callback',h,e,guidata(h))...
    );
%% lens matrix table
handles.panel_matrix_lens = uiextras.Panel( 'Parent',handles.vbox_lens,...
    'Title', 'Lens Matrix:','BorderType','none');
handles.table_lens_matrix = uitable('Parent',handles.panel_matrix_lens,...
    'data',[1,0 ;0,1],'RowName','numbered','ColumnName','numbered',...
    'ColumnWidth',{105});

set(handles.hBox_adjusment_lens,'Widths',[-100,-100])
set(handles.vbox_lens,'Heights' ,[35,-100,75])

 
end

function handles = system_frame(handles)

%% system panel
handles.panel_system = uiextras.BoxPanel( 'Title', 'System Propertise', ...
    'ForegroundColor','k',...
    'TitleColor',[207,220,234]/255,...
    'Tag','panel_system',...
    'Parent', handles.vBoxFlex_lensAndSystem);

handles.vbox_system = uiextras.VBox('Parent',handles.panel_system,...
    'Spacing', 5,'Tag','vbox_system');

%% system propertise
handles.panel_system_propertise =  uiextras.Panel( 'Parent',handles.vbox_system,...
    'Title', 'Optic System Data','BorderType','none');

handles.table_system_propertise = uitable('Parent',handles.panel_system_propertise,...
    'RowName',handles.setup.system,...
    'ColumnWidth',{105},'Tag','table_system_propertise',...
    'FontWeight','Bold','FontSize',8,'ColumnName',{'Value'},...
    'ColumnEditable',false);
%% system matrix table
handles.panel_matrix_system = uiextras.Panel( 'Parent',handles.vbox_system,...
    'Title', 'Matrix optic System','BorderType','none');
handles.table_system_matrix = uitable('Parent',handles.panel_matrix_system,...
    'data',[1,0 ;0,1],'RowName','numbered','ColumnName','numbered',...
     'ColumnWidth',{105});
%% button_reset_system 
handles.button_reset_system = uicontrol('Parent',handles.vbox_system,...
       'string',str2html('Reset system','black',[],'icons/reset.png'),...
       'Tag','button_reset_system',...
 'callback',@(h,e)OpticMat('reset_system_callback',h,e,guidata(h)));
set(handles.vbox_system,'Heights' ,[-100,80,35])       


end

function handles = axes_frame(handles)

%% axes panel
handles.panel_axes = uiextras.BoxPanel( 'Title', 'Axes bench', ...
    'Tag','panel_axes',...
    'Parent', handles.vBox_axesAndRays );

%% separetor
handles.hBox_axesAndButton = uiextras.HBox(...
    'Parent',handles.panel_axes,'Spacing', 0 ,...
    'Tag','hBox_axesAndButton','BackgroundColor','k');

handles.axes_move_widget = AxesMove('Parent', handles.hBox_axesAndButton  );
handles.axes_move_widget.type ='num';
 set(handles.axes_move_widget.Axes,'box','on','units','normalized'...
            ,'tag','axes_move'...
            ,'Layer','bottom'...
            ,'LineStyleOrder',{':'}...
            ,'xcolor',[1 1 1]...
            ,'ycolor',[1 1 1]...
            ,'Color','k'...
            ,'XMinorTick','on'...
            ,'YMinorTick','on'...
            ,'xminorGrid','on'...
            ,'xMinorGrid','on'...
            ,'yminorGrid','on'...
            ,'yMinorGrid','on'...
            ,'GridColor',[1,1,1]...
            ,'GridLineStyle','-'...
            ,'YGrid','on'...
            ,'XGrid','on'...
            ,'box','on'...
            ,'fontsize',12 ...
            ,'LooseInset', [0,0,0,0]...
            )
 %% separetor
handles.vBox_pussbutton_resize = uiextras.VBox(...
    'Parent',handles.hBox_axesAndButton,'Spacing', 0 ,...
    'Tag','hBox_axesAndButton','BackgroundColor','k','Padding',10); 

 handles.pussbutton_resize = uicontrol(...
     'string',str2html('','black','','icons/expand.png'),...
     'tooltip','show all optic system',...
                        'Parent',handles.vBox_pussbutton_resize,...
                        'Tag','pussbutton_resize',...
                        'Style','pushbutton',...
'callback',@(h,e)OpticMat('show_all_Optical_system_callback',h,e,guidata(h))); 
                    
         uiextras.Empty('Parent',handles.vBox_pussbutton_resize)
 set(handles.hBox_axesAndButton,'Widths',[-100,55])         
set(handles.vBox_pussbutton_resize,'Heights',[30,-100])
% Update handles structure
guidata(handles.figure_opticMat, handles);
end

function handles = ray_frame(handles)

%% ray panel
handles.panel_rays = uiextras.BoxPanel( 'Title', 'Rays Propertise', ...
  handles.title_color{:},...
    'Tag','panel_rays',...
    'Parent', handles.vBox_axesAndRays);
    %%
    handles.vbox_rays = uiextras.VBox('Parent',handles.panel_rays,...
        'Spacing', 5,'Tag','vbox_Rays');
        %% seting 
       
        handles.panel_ray_seting = uiextras.Panel( 'Parent',handles.vbox_rays,...
            'Title', 'rays seting :','BorderType','none');
        handles.hbox_rays_seting = uiextras.HBox('Parent',...
             handles.panel_ray_seting,...
            'Spacing', 5,'Tag','hbox_rays_seting');
            % ray cheackbox
            handles.check_box_rays_on = uicontrol(...
            'Parent',handles.hbox_rays_seting,...
            'string','Reset Rays','Tag','button_reset_Rays',...
            'style','check',...
            'value',handles.setup.ray.draw,...
            'callback',@(h,e)OpticMat('rayOnOffCallback',h,e,guidata(h)));
            % text
            uicontrol('Parent',handles.hbox_rays_seting,...
                        'string','Ray top','style','text');
                    
            jModel = javax.swing.SpinnerNumberModel(2,-20,20,0.1);
            jSpinner = javax.swing.JSpinner(jModel);
            jhSpinner = javacomponent(jSpinner, [10,10,60,20],...
                handles.hbox_rays_seting);
            set(jhSpinner,'StateChangedCallback',@(h,e)javaSpinerCallback(h,e,handles))
  
            % text        
            uicontrol('Parent',handles.hbox_rays_seting,...
                        'string','Color','style','text');
            % listbox        
            handles.popupmenu_rays_color = uicontrol(...
                'Parent',handles.hbox_rays_seting,...
                'String',handles.setup.color_collection,...
'Value',find(strcmpi(handles.setup.color_collection,handles.setup.ray.color)),...
'callback',@(h,e)OpticMat('ray_color_popupmenu_callback',h,e,guidata(h)),...
                        'Tag','popupmenu_rays_color','style','popupmenu');          
            % empty space 
            uiextras.Empty('Parent',handles.hbox_rays_seting)
            set(handles.hbox_rays_seting,'Widths',[85,45,50,50,73,-100])
handles.panel_rays_path = uiextras.Panel( 'Parent',handles.vbox_rays,...
    'Title','Rays_path','Tag','panel_rays_path','BorderType','none');
     handles.hBox_rays_tables = uiextras.HBox(...
        'Parent',handles.panel_rays_path,...
        'Spacing', 5,'Tag','hBox_rays_tables');
       %% table ray angle initial
        handles.table_angle_rays = uitable(...
                'Parent',handles.hBox_rays_tables,...
                'ColumnWidth',{'auto'},'Tag','table_angle_rays',...
                'FontWeight','Bold','FontSize',8,'ColumnName',{'angle(deg)'},...
                'ColumnEditable',true,...
                'ForegroundColor',[52,91,77]/255,...
                'CellEditCallback',@(h,e)OpticMat('table_ray_angle_callback',h,e,guidata(h))...
                );
        %% table Rays_path
        handles.table_ray_path = uitable(...
                'Parent',handles.hBox_rays_tables,...
                'RowName',{},...
                'ColumnWidth',{'auto'},'Tag','table_ray_path',...
                'FontWeight','Bold','FontSize',8,...
'CellSelectionCallback',@(h,e)OpticMat('show_ray_refraction_point_callback',h,e,guidata(h)),...
                'ColumnEditable',false);

set(handles.hBox_rays_tables,'Widths',[100,-100])
set(handles.vbox_rays,'Heights',[40,-100]) 

% Update handles structure
guidata(handles.figure_opticMat, handles);
end

 function javaSpinerCallback(h,e,handles)
 OpticMat('ray_y_callback',h,e,guidata(handles.figure_opticMat))
 end











