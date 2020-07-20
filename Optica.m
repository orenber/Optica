function varargout = Optica(varargin)
% Optics Version 1.2
% This software was built to be used as a calculation tool for simulations of optical systems Of lenses,
% this tool can also be used in high school students and institutions of higher education studying optics

% % User manual
% Lens:
% To add a new lens click Add Lens
% Removal of the lens: Click with the mouse on the lens you want to delete, a red arrow will appear over the same lens is selected and Then click Remove Lens
%
% Lens Data Entry: Click with the mouse on the lens you want to enter data to a red arrow will appear above the selected lens now enter the data, all the data are in meters.
% Lens matrix: each lens has its own matrix, by selecting the lens, the lens matrix table will appear

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Optica_OpeningFcn, ...
    'gui_OutputFcn',  @Optica_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Optica is made visible.
function Optica_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Optica (see VARARGIN)

% Choose default command line output for Optica
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
handles = GUI_Adjustment(hObject, handles);

% UIWAIT makes Optica wait for user response (see UIRESUME)
% uiwait(handles.figure_optica);
handles.setup = setSetup();

handles.system =  SystemOptic();
hold(handles.axes_system,'on')
handles.rayPoint = scatter(nan,nan,...
    'Parent',handles.axes_system,'MarkerFaceColor','green',...
    'Marker','o','MarkerEdgeColor','yellow');
hold(handles.axes_system,'off')


handles.system.createAxesBanch(handles.axes_system)
handles.ray = Ray(handles.system,handles.setup.ray);
handles.system.addRay(handles.ray);

handles.fig = Fig();
handles.fig.addRay(handles.ray);
handles.system.addFigure(handles.fig);

listen2DataChange(hObject, eventdata, handles) 

tableSystemUpdate(hObject, eventdata, handles)
table_ray_update_callback(hObject, eventdata, handles)

%set( handles.figure_optica,'WindowButtonDownFcn',@(h,e)DownFcn(h,e,guidata(h)))

guidata(hObject, handles);

function setup = setSetup()

   setup.lens = struct(...
     'X','x'...
    ,'Y','y'...
    ,'Focal','focal'...
    ,'Radius_Left','radius_left'...
    ,'Radius_Right','radius_right'...
    ,'Height','height'...
    ,'Width','width'...
    ,'Index_In','index_in'...
    ,'Index_Out','index_out'...
    ,'Color','color');

setup.system = {
     'Focal'...
    ,'Length'...
    ,'Front'...
    ,'Back'...
    ,'Magnification'...
    ,'VHF'...
    ,'VHB'...
    ,'Lens Count'};

setup.displyData = @(x)sprintf('%25.*g',3,x);
setup.color_collection = {'Blue',...
            'Red',...
            'Yellow',...
            'Green',...
            'Cyan',...
            'Magenta',...
            'Black'};
setup.ray = struct('y',2,'x',0,'teta',[10,-10,0],'color','red','draw',true);


function listen2DataChange(hObject, eventdata, handles)
handles.listener.systemUpdate = addlistener(handles.system,'Update',...
     @(h,e)(cellfun(@(x)feval(x,h,e),...
     {@(h,e)tableSystemUpdate(h,e,guidata(hObject)),...
      @(h,e)showLensData(h,e,guidata(hObject))...
     })...
     ));
handles.listener.rayUpdate = addlistener(handles.ray,...
    'Update',@(h,e)table_ray_update_callback(h,e,guidata(hObject)));
 
function tableSystemUpdate(hObject, eventdata, handles)
% show the  optical system data

set(handles.tbsysdata,'data',[handles.system.focal,...
                              handles.system.L,...
                              handles.system.Xf,...
                              handles.system.Xb,...
                              handles.system.m,...
                              handles.system.vhf,...
                              handles.system.vhb,...
                              length(handles.system.lens)]')

 set(handles.tbsysmatrix,'data', handles.system.matrix)
 if ~isempty(handles.system.lens)
 showLensDataTable(handles,handles.system.lens(handles.system.indx))
 end

function handles = GUI_Adjustment(hObject, handles)
        color_collection = {'Blue',...
            'Red',...
            'Yellow',...
            'Green',...
            'Cyan',...
            'Magenta',...
            'Black'};
set(handles.popupmenuColorLens,'string',color_collection);

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = Optica_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function showLensDataTable(handles,lensObj)
 
% update matrix lens table
set(handles.tbmatrixlens,'data',lensObj.matrix);


function showLensData(hObject, eventdata, handles)
system = handles.system;
    
    set(handles.panelens,'Title',strcat('Lens :',num2str(system.indx)))
    
    set(handles.editRadiusLeft,'string',num2str(system.lens(system.indx).radius_left));
    set(handles.editRadiusRight,'string',num2str(system.lens(system.indx).radius_right));
    
    set(handles.editWidth,'string',num2str(system.lens(system.indx).width));
    set(handles.editHeight,'string',num2str(system.lens(system.indx).height));
    
    set(handles.editIndexOut,'string',num2str(system.lens(system.indx).index_out));
    set(handles.editIndexIn,'string',num2str(system.lens(system.indx).index_in));
    
    set(handles.editX,'string',num2str(system.lens(system.indx).x));
    set(handles.editFocal,'string',num2str(system.lens(system.indx).focal));
    
    color_popup = get(handles.popupmenuColorLens,'string');
    color_selected_lens = system.lens(system.indx).color;
    color_index = find(ismember(color_popup,color_selected_lens));
    set(handles.popupmenuColorLens,'value',color_index)

 
    % update matrix lens table
    set(handles.tbmatrixlens,'data',system.lens(system.indx).matrix);
  
   
function enbleOpticLensUI(handles,onoff)

allHandles = [handles.editRadiusLeft,...
    handles.sliderRadiusLeft,...
    handles.editRadiusRight,...
    handles.sliderRadiusRight,...
    handles.editWidth,...
    handles.sliderWidth,...
    handles.editHeight,...
    handles.sliderHeight,...
    handles.editIndexIn,...
    handles.sliderIndexIn,...
    handles.editX,...
    handles.sliderX,...
    handles.editFocal,...
    handles.popupmenuColorLens,...
    handles.tbmatrixlens];
% update matrix lens table
set(allHandles,'Enable',onoff)


function resetLensUI(handles)
allHandles = ...
    [handles.editRadiusLeft,... 
     handles.editRadiusRight,...
     handles.editWidth,...
     handles.editHeight,...
     handles.editIndexIn,...
     handles.editX,...
     handles.editFocal,...
    ];
set(handles.tbmatrixlens,'data',[1,0 ; 0,1])
% update matrix lens table
set(allHandles,'string','')


% --- Executes on selection change in popupmenuColorLens.
function popupmenuColorLens_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuColorLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(handles.popupmenuColorLens,'String')) returns popupmenuColorLens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuColorLens
system = handles.system;
contents = cellstr(get(hObject,'String'));
color = contents{get(hObject,'Value')} ;

system.lens(system.indx).color = color;
 
% --- Executes on slider movement.
function sliderX_Callback(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
num = str2double(get(handles.editX,'string'));
num = NumberUpDown(hObject,num);
set(handles.editX,'string',num2str(num))

system.lens(system.indx).x=num;

function editFocal_Callback(hObject, eventdata, handles)
% hObject    handle to editFocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function editX_Callback(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX as text
%        str2double(get(hObject,'String')) returns contents of editX as a double
system = handles.system;
system.lens(system.indx).x = str2double(get(hObject,'string'));
set(hObject,'string',num2str(system.lens(system.indx).x));
 
% --- Executes on slider movement.
function sliderIndexIn_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIndexIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
num = str2double(get(handles.editIndexIn,'string'));
num = NumberUpDown(hObject,num);
system.lens(system.indx).index_in = num;

set(handles.editIndexIn,'string',num2str(system.lens(system.indx).index_in))
 
% --- Executes on slider movement.
function sliderIndexOut_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2double(get(handles.editIndexOut,'string'));
num = NumberUpDown(hObject,num);
handles.system.index_out = num;
set(handles.editIndexOut,'string',num2str(system.index_out))

function editIndexIn_Callback(hObject, eventdata, handles)
% hObject    handle to editIndexIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIndexIn as text
%        str2double(get(hObject,'String')) returns contents of editIndexIn as a double
system = handles.system;
system.lens(system.indx).index_in=str2double(get(hObject,'string'));
set(hObject,'string',num2str(system.lens(system.indx).index_in))

function editIndexOut_Callback(hObject, eventdata, handles)
% hObject    handle to editIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIndexOut as text
%        str2double(get(hObject,'String')) returns contents of editIndexOut as a double

handles.system.index_out = str2double(get(hObject,'string'));


% --- Executes on slider movement.
function sliderWidth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
num = str2double(get(handles.editWidth,'string'));
num = NumberUpDown(hObject,num,0.01);
system.lens(system.indx).width = num;
num = system.lens(system.indx).width;
set(handles.editWidth,'string',num2str(num))
 

% --- Executes on slider movement.
function sliderHeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
num = str2double(get(handles.editHeight,'string'));
num = NumberUpDown(hObject,num);

set(handles.editHeight,'string',num2str(num))
system.lens(system.indx).height = num;


function editWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWidth as text
%        str2double(get(hObject,'String')) returns contents of editWidth as a double
system = handles.system;
system.lens(system.indx).width=str2double(get(handles.editWidth,'string'));
set(handles.editWidth,'string',num2str(system.lens(system.indx).width))


function editHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHeight as text
%        str2double(get(hObject,'String')) returns contents of editHeight as a double
system = handles.system; 
system.lens(system.indx).height=str2double(get(hObject,'string'));
set(handles.editHeight,'string',num2str(system.lens(system.indx).height))
 

% --- Executes on slider movement.
function sliderRadiusLeft_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRadiusLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
num = str2double(get(handles.editRadiusLeft,'string'));
num = NumberUpDown(hObject,num);
set(handles.editRadiusLeft,'string',num2str(num))
system.lens(system.indx).radius_left = num;


function num = NumberUpDown(hObject,num,factor)
if nargin<3
    factor = 0.01;
end

current_value = get(hObject,'Value');
 
if (current_value<=0.5) 
    num=num-factor;
else
    num=num+factor;
end
% update 
set(hObject,'Value',0.5)  
 
% --- Executes on slider movement.
function sliderRadiusRight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

number_on_edit = str2double(get(handles.editRadiusRight,'string'));
num_new = NumberUpDown(hObject,number_on_edit);
set(handles.editRadiusRight,'string',num2str(num_new))
handles.system.lens(system.indx).radius_right = num_new;

guidata(hObject,handles)

function editRadiusLeft_Callback(hObject, eventdata, handles)
% hObject    handle to editRadiusLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRadiusLeft as text
%        str2double(get(hObject,'String')) returns contents of editRadiusLeft as a double
system = handles.system;
system.lens(system.indx).radius_left=str2double(get(handles.editRadiusLeft,'string'));
set(handles.editRadiusLeft,'string',num2str(system.lens(system.indx).radius_left))
 
guidata(hObject,handles)

function editRadiusRight_Callback(hObject, eventdata, handles)
% hObject    handle to editRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRadiusRight as text
%        str2double(get(hObject,'String')) returns contents of editRadiusRight as a double
system = handles.system;
system.lens(system.indx).radius_right = str2double(get(handles.editRadiusRight,'string'));
set(handles.editRadiusRight,'string',num2str(system.lens(system.indx).radius_right))


% --- Executes on button press in pushbuttonAddLens.
function pushbuttonAddLens_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create new Lens
handles.system.addLens(Lens())

enbleOpticLensUI(handles,'on')



% --- Executes on button press in pushbuttonRemoveLens.
function pushbuttonRemoveLens_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ~isempty(handles.system.lens)
handles.system.removeLens(handles.system.lens(handles.system.indx))
end

if isempty(handles.system.lens)
resetLensUI(handles)
enbleOpticLensUI(handles,'off')
end

% --- Executes on button press in checkboxRayOn.
function checkboxRayOn_Callback(hObject,~,handles)
% hObject    handle to checkboxRayOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRayOn
 handles.system.ray.draw = logical(get(hObject,'Value'));
 

function table_ray_update_callback(hObject, eventdata, handles)

set(handles.tbDegRay,'data',handles.ray.teta(:))
% update Ray Control
set(handles.editYRay,'string',num2str(handles.ray.y))
 
% update Ray table
mat = cell2mat(handles.ray.xyr);
xyr = reshape(mat,size(mat,1),size(mat,2));

coulumHeader = repmat({'x','y','angle'},1,size(xyr,2)/size(xyr,1));
xyr_color = paintColumeTable(xyr,{'blue','red','green'});
set(handles.tbRayXYTeta,'data',xyr_color,'ColumnName',coulumHeader);



function editYRay_Callback(hObject, eventdata, handles)
% hObject    handle to editYRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editYRay as text
%        str2double(get(hObject,'String')) returns contents of editYRay as a double
 
handles.ray.y = str2double(get(hObject,'String'));


% --- Executes on slider movement.
function sliderRay_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2double(get(handles.editYRay,'string'));
num = NumberUpDown(hObject,num);
set(handles.editYRay,'string',num2str(num))
handles.ray.y = num;

 
% --- Executes on selection change in popupmenuColorRay.
function popupmenuColorRay_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuColorRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuColorRay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuColorRay

contents = cellstr(get(hObject,'String'));
color = contents{get(hObject,'Value')};

handles.ray.color = color;

% --- Executes when entered data in editable cell(s) in tbDegRay.
function tbDegRay_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbDegRay (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.ray.teta(eventdata.Indices(1)) = eventdata.NewData;


% --- Executes on button press in ResetSystem.
function ResetSystem_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.system.resetSystem();
resetLensUI(handles)


% --------------------------------------------------------------------
function about_optica_menu_Callback(hObject, eventdata, handles)
% hObject    handle to about_optica_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg=findall(0,'Name','About Optica');
if isempty(msg)
    welcome=msgbox({'          Welcome to Optica programe 1.1ver          ';...
        '       This software was created by Oren berkovitch';
        '                email : orenber@hotmail.com.  ';...
        '                             July 2014';...
        '                                                      '},'About Optica');
    
    movegui(welcome,'center')
    uiwait(welcome)
end

% --- Executes on button press in ShowAllTheSystem.
function ShowAllTheSystem_Callback(hObject, eventdata, handles)

handles.system.showAllView();


% --- Executes when selected cell(s) is changed in tbRayXYTeta.
function tbRayXYTeta_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tbRayXYTeta (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
 

    path = cell2mat(handles.ray.xyr);
    Xind = find(mod(eventdata.Indices(:,2)-1,3)==0);
    Yind = find(mod(eventdata.Indices(:,2)-2,3)==0);
    Y = eventdata.Indices(Yind,:);
    X = eventdata.Indices(Xind,:);
    
    if size(X)==size(Y)
        
        x= diag(path(X(:,1),X(:,2)));
        y= diag(path(Y(:,1),Y(:,2)));
       
        set(handles.rayPoint,'XData',x,'YData',y);

    end

