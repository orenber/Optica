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

handles.lens_array = {};
handles.system = SysOptic(handles.lens_array);
handles.system.ButtonDownFcn = @(h,e)DownFcn(h,e,guidata(h));
handles.ray = Ray(handles.system);
handles.fig = Fig(handles.ray);

handles.system.SysPlot()
ResetOpticSys(handles,'off');

ShowSysdata(handles)
%set( handles.figure_optica,'WindowButtonDownFcn',@(h,e)DownFcn(h,e,guidata(h)))

guidata(hObject, handles);

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


function DownFcn(hObject,event,handles)

set( handles.figure_optica,'WindowButtonMotionFcn',@(h,e)MotionFcn(h,e,guidata(h)))
set( handles.figure_optica,'WindowButtonUpFcn',@(h,e)UpFcn(h,e,guidata(h)))
ShowLensData(handles)

function MotionFcn(hObject,event,handles)

system = handles.system;
if  (~isempty(system.indx))&&(ne(system.indx,0))
          
        xy=get(handles.axes_optica,'CurrentPoint');
        x=xy(1);
        
        system.lens(system.indx).x=x;
        system.SysMovie()
        
end

function UpFcn(~,~,handles)
% turn off movemont function 
set( handles.figure_optica,'WindowButtonMotionFcn','')
set( handles.figure_optica,'WindowButtonUpFcn','')

system = handles.system;
if (~isempty(system.lens))&&(~isempty(system.indx))...
        &&(ne(system.indx,0))
    
    % update all field lens
    system.update()
    if (isempty(system.lens)==1)
        ResetOpticSys(handles,'off')
    else
        
        ShowLensData(handles)
    end
    RayAndFigure(handles)
    
end

function RayAndFigure(handles)
% plot the figure
system = handles.system;
% if the figure check box is check and ther is alens in the system
if  get(handles.Fig,'value')==1&&handles.system.indx~=0
    set(system.lens(system.indx).rect,'HandleVisibility','off')
    Fig_Callback(handles,handles,handles);
    set(system.lens(system.indx).rect,'HandleVisibility','on')
end
% plot the RAys


Fig_Callback(handles,handles,handles);
UpdateRay(handles);

function ShowSysdata( handles)
system = handles.system;

if ~isempty(system.lens)
    set(handles.editFocal,'string',system.lens(system.indx).focal)
end
% show the  optical system data
data_table = [system.focal, system.L, system.Xf...
    ,system.Xb, system.m, system.vhf, system.vhb, length(system.lens)]';
set(handles.tbsysdata,'data',data_table)
% show the Matrix of the system
set(handles.tbsysmatrix,'data',system.M);
% show the optical path data
% --- Outputs from this function are returned to the command line.
function varargout = Optica_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function ShowLensDataTable(handles,indx)
system = handles.system;
% check if the matrix is empty
if  isempty(system.lens)==1
    Mat=[1 0;0 1];
else
    Mat=system.lens(indx).M;
end
% update matrix lens table
set(handles.tbmatrixlens,'data',Mat);
ShowSysdata(handles);

function ShowLensData(handles)
system = handles.system;

% update all field lens
if (isempty(system.lens)==1)
    ResetOpticSys(handles,'off')
else
    
    set(handles.panelens,'Title',strcat('Lens :',num2str(system.indx)))
    
    set(handles.editRadiusLeft,'string',num2str(system.lens(system.indx).Radius_Left));
    set(handles.editRadiusRight,'string',num2str(system.lens(system.indx).Radius_right));
    
    set(handles.editWidth,'string',num2str(system.lens(system.indx).Width));
    set(handles.editHeight,'string',num2str(system.lens(system.indx).Height));
    
    set(handles.editIndexOut,'string',num2str(system.lens(system.indx).Index_out));
    set(handles.editIndexIn,'string',num2str(system.lens(system.indx).Index_in));
    
    set(handles.editX,'string',num2str(system.lens(system.indx).x));
    set(handles.editFocal,'string',num2str(system.lens(system.indx).focal));
    
    color_popup = get(handles.popupmenuColorLens,'string');
    color_selected_lens = system.lens(system.indx).Color;
    color_index = find(ismember(color_popup,color_selected_lens));
    set(handles.popupmenuColorLens,'value',color_index)

 
    % update matrix lens table
    set(handles.tbmatrixlens,'data',system.lens(system.indx).M);
end
% update System optic
ShowSysdata( handles);

function ResetOpticSys(handles,onoff)

allHandles = [handles.editRadiusLeft,...
    handles.sliderRadiusLeft,...
    handles.editRadiusRight,...
    handles.sliderRadiusRight,...
    handles.editWidth,...
    handles.sliderWidth,...
    handles.editHeight,...
    handles.sliderHeight,...
    handles.editIndexOut,...
    handles.sliderIndexOut,...
    handles.editIndexIn,...
    handles.sliderIndexIn,...
    handles.editX,...
    handles.sliderX,...
    handles.editFocal,...
    handles.popupmenuColorLens,...
    handles.tbmatrixlens];
% update matrix lens table
set(allHandles,'Enable',onoff)

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

system.lens(system.indx).Color=color;
system.SysMovie()
RayAndFigure(handles)

% --- Executes during object creation, after setting all properties.
function popupmenuColorLens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuColorLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sliderFocal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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
system.SysMovie()
system.update()
RayAndFigure(handles)
ShowSysdata(handles)

% --- Executes during object creation, after setting all properties.
function sliderX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editFocal_Callback(hObject, eventdata, handles)
% hObject    handle to editFocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system = handles.system;

val = str2double(get(handles.editFocal,'string'));
system.lens(system.indx).Focal(val)
set(handles.editRadiusRight,'string',num2str(system.lens(system.indx).Radius_right))
set(handles.editRadiusLeft,'string',num2str(system.lens(system.indx).Radius_Left))
set(handles.editWidth,'string',num2str(system.lens(system.indx).Width))
system.update()
system.SysMovie()
RayAndFigure(handles)
ShowLensDataTable(handles,system.indx)

% --- Executes during object creation, after setting all properties.
function editFocal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editX_Callback(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX as text
%        str2double(get(hObject,'String')) returns contents of editX as a double
system = handles.system;
system.lens(system.indx).x=str2double(get(hObject,'string'));
set(hObject,'string',num2str(system.lens(system.indx).x));
system.update()

system.SysMovie()
RayAndFigure(handles)
ShowSysdata(handles)

% --- Executes during object creation, after setting all properties.
function editX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
system.lens(system.indx).Index_in=num;

set(handles.editIndexIn,'string',num2str(system.lens(system.indx).Index_in))

system.update
RayAndFigure(handles)
ShowLensDataTable( handles,system.indx);

% --- Executes during object creation, after setting all properties.
function sliderIndexIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIndexIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function sliderIndexOut_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system = handles.system;
num = str2double(get(handles.editIndexOut,'string'));
num = NumberUpDown(hObject,num);
system.Index_out = num;
set(handles.editIndexOut,'string',num2str(system.Index_out))


RayAndFigure(handles)

ShowLensDataTable( handles,system.indx);

% --- Executes during object creation, after setting all properties.
function sliderIndexOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editIndexIn_Callback(hObject, eventdata, handles)
% hObject    handle to editIndexIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIndexIn as text
%        str2double(get(hObject,'String')) returns contents of editIndexIn as a double
system = handles.system;
system.lens(system.indx).Index_in=str2double(get(hObject,'string'));
set(hObject,'string',num2str(system.lens(system.indx).Index_in))
RayAndFigure(handles)
ShowLensDataTable(handles,system.indx)

% --- Executes during object creation, after setting all properties.
function editIndexIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIndexIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editIndexOut_Callback(hObject, eventdata, handles)
% hObject    handle to editIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIndexOut as text
%        str2double(get(hObject,'String')) returns contents of editIndexOut as a double

handles.system.Index_out = str2double(get(hObject,'string'));
RayAndFigure(handles)
ShowLensData(handles)

% --- Executes during object creation, after setting all properties.
function editIndexOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIndexOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
system.lens(system.indx).Width = num;
num = system.lens(system.indx).Width;
set(handles.editWidth,'string',num2str(num))

system.SysMovie()
system.update()
RayAndFigure(handles)
ShowLensDataTable(handles,system.indx)
% --- Executes during object creation, after setting all properties.
function sliderWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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

system.lens(system.indx).Height = num;
system.SysMovie()
RayAndFigure(handles)

% --- Executes during object creation, after setting all properties.
function sliderHeight_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWidth as text
%        str2double(get(hObject,'String')) returns contents of editWidth as a double
system = handles.system;
system.lens(system.indx).Width=str2double(get(handles.editWidth,'string'));
set(handles.editWidth,'string',num2str(system.lens(system.indx).Width))
system.update()
system.SysMovie()
RayAndFigure(handles)
ShowLensDataTable( handles,system.indx);

% --- Executes during object creation, after setting all properties.
function editWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHeight as text
%        str2double(get(hObject,'String')) returns contents of editHeight as a double
system = handles.system; 
system.lens(system.indx).Height=str2double(get(hObject,'string'));
set(handles.editHeight,'string',num2str(system.lens(system.indx).Height))
system.SysMovie()
RayAndFigure(handles)

% --- Executes during object creation, after setting all properties.
function editHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

system.lens(system.indx).Radius_Left=num;
system.update
RayAndFigure(handles)
ShowLensDataTable( handles,system.indx);

function num=NumberUpDown(hObject,num,factor)
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
 

% --- Executes during object creation, after setting all properties.
function sliderRadiusLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRadiusLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function sliderRadiusRight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
system = handles.system;
number_on_edit = str2double(get(handles.editRadiusRight,'string'));
num_new = NumberUpDown(hObject,number_on_edit);
set(handles.editRadiusRight,'string',num2str(num_new))

system.lens(system.indx).Radius_right = num_new;
system.update()
RayAndFigure(handles)
ShowLensDataTable( handles,system.indx);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function sliderRadiusRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editRadiusLeft_Callback(hObject, eventdata, handles)
% hObject    handle to editRadiusLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRadiusLeft as text
%        str2double(get(hObject,'String')) returns contents of editRadiusLeft as a double
system = handles.system;
system.lens(system.indx).Radius_Left=str2double(get(handles.editRadiusLeft,'string'));
set(handles.editRadiusLeft,'string',num2str(system.lens(system.indx).Radius_Left))
system.update()
system.SysMovie()
RayAndFigure(handles)
ShowLensDataTable(handles,system.indx);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editRadiusLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRadiusLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRadiusRight_Callback(hObject, eventdata, handles)
% hObject    handle to editRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRadiusRight as text
%        str2double(get(hObject,'String')) returns contents of editRadiusRight as a double
system = handles.system;
system.lens(system.indx).Radius_right=str2double(get(handles.editRadiusRight,'string'));
set(handles.editRadiusRight,'string',num2str(system.lens(system.indx).Radius_right))
system.update
system.SysMovie
RayAndFigure(handles)
ShowLensDataTable( handles,system.indx);

% --- Executes during object creation, after setting all properties.
function editRadiusRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRadiusRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonAddLens.
function pushbuttonAddLens_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lens = handles.lens_array;
system = handles.system;

if isempty(system.lens)
    ResetOpticSys(handles,'on');
end
% create new Lens
indx = length(lens)+1;
lens{indx}=Lens;

system.AddLens(lens{indx})
system.SysPlot()

ShowLensData( handles)
guidata(hObject,handles)

% --- Executes on button press in pushbuttonRemoveLens.
function pushbuttonRemoveLens_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lens = handles.lens_array;
system = handles.system;

if ~isempty(system.lens)
    
    system.RemoveLens(system.lens(system.indx));
    handles.lens_array = lens(1:length(lens)-1);
    system.SysPlot()
    ShowLensDataTable( handles,system.indx);
    ShowLensData( handles)
    
else
    ResetOpticSys(handles,'off')
end

if isempty(system.lens)
    ResetOpticSys(handles,'off')
end

guidata(hObject,handles)

% --- Executes on button press in checkboxRayOn.
function checkboxRayOn_Callback(hObject,~,handles)
% hObject    handle to checkboxRayOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRayOn
system = handles.system;
RayOn=get(handles.checkboxRayOn,'Value');
% if the ray check box is check
if RayOn==1
    % if the figure checkbox is check
    if get(handles.Fig,'Value')==1
        Fig_Callback( handles,handles,handles);
        UpdateRay(handles);
        
    else
        Fig_Callback( handles,handles,handles);
        UpdateRay(handles);
        
    end
    
elseif RayOn==0
    if  (~isempty(system.lens))||(system.indx~=0)
        set(system.lens(system.indx).rect,'HandleVisibility','off')
        
        newplot
        if get(handles.Fig,'value')==1
            Fig_Callback( handles ,handles,handles);
        end
        set(system.lens(system.indx).rect,'HandleVisibility','on')
    else
        newplot
    end
    
end

function UpdateRay(handles)

ray = handles.ray;
system = handles.system;
set(handles.tbDegRay,'data',[ray.teta]')
if  get(handles.checkboxRayOn,'value')==1
    % update Ray Data
    ray.RayIn()
    % update Ray Control
    set(handles.editYRay,'string',num2str(ray.y))
    % update Ray table
    mat=cell2mat(ray.xyr);
    xyr=reshape(mat,3,length(mat));
    set(handles.tbRayXYTeta,'data',xyr);
    
    if  (~isempty(system.lens))||(system.indx~=0)
        set(system.lens(system.indx).rect,'HandleVisibility','off')
        % Plot the Ray
        set(system.lens(system.indx).rect,'HandleVisibility','on')
    else
        % Plot the Ray
        ray.RayPlot()
    end
    
end

function editYRay_Callback(hObject, eventdata, handles)
% hObject    handle to editYRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editYRay as text
%        str2double(get(hObject,'String')) returns contents of editYRay as a double
 
handles.ray.y = str2double(get(hObject,'String'));
RayAndFigure(handles)

% --- Executes during object creation, after setting all properties.
function editYRay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editYRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sliderRay_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ray = handles.Ray ;
system = handles.system;
num = str2double(get(handles.editYRay,'string'));
num = NumberUpDown(hObject,num);
set(handles.editYRay,'string',num2str(num))

ray.y = num;
system.update()
RayAndFigure(handles)
ShowLensDataTable(handles,system.indx);

% --- Executes during object creation, after setting all properties.
function sliderRay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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
RayAndFigure(handles)
% --- Executes during object creation, after setting all properties.
function popupmenuColorRay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuColorRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

handles.ray.teta= (get(hObject,'data'))';
Fig_Callback(handles ,handles,handles)
UpdateRay(handles)

guidata(hObject,handles)

% --- Executes on button press in Fig.
function Fig_Callback(hObject,~,handles)
% hObject    handle to Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Fig

system = handles.system;
set(handles.axes_optica,'NextPlot','replacechildren')

if  get(handles.Fig,'Value')==1
    handles.ray.RayIn()
    if ~isempty(system.lens)
        set(system.lens(system.indx).rect,'HandleVisibility','off')
        newplot
        handles.fig.PlotFig()
        if get(handles.checkboxRayOn,'Value')==1
            handles.ray.RayPlot()
        end
        handles.fig.LockFig('on')
        set(system.lens(system.indx).rect,'HandleVisibility','on')
    end
    
elseif get(handles.Fig,'Value')==0
    if ~isempty(system.lens)
        set(system.lens(system.indx).rect,'HandleVisibility','off')
        newplot
        if get(handles.checkboxRayOn,'Value')==1
            handles.ray.RayPlot()
        end
        set(system.lens(system.indx).rect,'HandleVisibility','on')
        
    elseif isempty(system.lens)&&get(handles.checkboxRayOn,'value')==0
        newplot
    end
end

% --- Executes on button press in ResetSystem.
function ResetSystem_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.system.ResetSystem();
handles.system.SysPlot();
ShowLensData(handles)

guidata(hObject,handles)

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

[Fxmin, Fxmax, Fymin, Fymax]= handles.fig.WhosIsTheMost();
[Lxmin, Lxmax, Lymin, Lymax]= handles.system.WhoIsTheMost();

xmin=min(horzcat(Fxmin,Lxmin,Fxmax,Lxmax));
xmax=max(horzcat(Fxmin,Lxmin,Fxmax,Lxmax));
ymin=min(horzcat(Fymin,Lymin,Fymax,Lymax));
ymax=max(horzcat(Fymin,Lymin,Fymax,Lymax));

axis([xmin*(1+1/6) xmax*(1+1/5) ymin*(1+1/5) ymax*(1+1/5)]);
guidata(hObject,handles)

% --- Executes when selected cell(s) is changed in tbRayXYTeta.
function tbRayXYTeta_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tbRayXYTeta (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
% index=find(mod(eventdata.Indices(:,2),3)==0);
% Nm= eventdata.Indices(index,:);
% XY=setdiff(eventdata.Indices(:,:),Nm,'rows');
% unique(m(min(XY(:,1)):max(XY(:,1)),sort(unique(XY(:,2)))),'rows')
system = handles.system;

if get(handles.checkboxRayOn,'Value')==1
    m=get(hObject,'data');
    Xind=find(mod(eventdata.Indices(:,2)-1,3)==0);
    Yind=find(mod(eventdata.Indices(:,2)-2,3)==0);
    Y= eventdata.Indices(Yind,:);
    X=eventdata.Indices(Xind,:);
    
    if size(X)==size(Y)
        
        x= diag(m(X(:,1),X(:,2)));
        y= diag(m(Y(:,1),Y(:,2)));
        set(system.lens(system.indx).rect,'HandleVisibility','off')
        newplot
        p=plot(x,y,'ro','HandleVisibility','off');
        Fig_Callback(handles,handles,handles)
        set(p,'HandleVisibility','on')
    end
end
