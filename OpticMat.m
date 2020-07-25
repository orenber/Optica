function varargout = OpticMat(varargin)
% OPTICMAT MATLAB code for OpticMat.fig
%      OPTICMAT, by itself, creates a new OPTICMAT or raises the existing
%      singleton*.
%
%      H = OPTICMAT returns the handle to a new OPTICMAT or the handle to
%      the existing singleton*.
%
%      OPTICMAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTICMAT.M with the given input arguments.
%
%      OPTICMAT('Property','Value',...) creates a new OPTICMAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OpticMat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OpticMat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OpticMat

% Last Modified by GUIDE v2.5 16-Jul-2020 06:20:26
% Begin initialization code - DO NOT EDIT

% created by oren berkovitch orenber@hotmail.com
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OpticMat_OpeningFcn, ...
                   'gui_OutputFcn',  @OpticMat_OutputFcn, ...
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


% --- Executes just before OpticMat is made visible.
function OpticMat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OpticMat (see VARARGIN)

% Choose default command line output for OpticMat
handles.output = hObject;

%% add path
% Determine where your m-file's folder is.
folder = fileparts(which('OpticMat.m')); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
 
handles.setup = setSetup();
%% build gui

handles = OpticMat_build_GUI(handles);

handles.system =  SystemOptic();
hold(handles.axes_move_widget.Axes,'on')
handles.rayPoint = scatter(nan,nan,...
    'Parent',handles.axes_move_widget.Axes,'MarkerFaceColor','green',...
    'Marker','o','MarkerEdgeColor','red');
hold(handles.axes_move_widget.Axes,'off')
handles.system.createAxesBanch(handles.axes_move_widget.Axes)

handles.ray = Ray(handles.system,handles.setup.ray);
handles.system.addRay(handles.ray);

handles.fig = Fig();
handles.fig.addRay(handles.ray);
handles.system.addFigure(handles.fig);
listen2DataChange(hObject, eventdata, handles)

tableSystemUpdate(hObject, eventdata, handles)
table_ray_update_callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OpticMat wait for user response (see UIRESUME)
% uiwait(handles.figure_opticMat);

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
      @(h,e)tableLensUpdate(h,e,guidata(hObject))...
     })...
     ));
 
handles.listener.windowMouseRelease = addlistener(handles.figure_opticMat,...
    'WindowMouseRelease',@(h,e)table_ray_update_callback(h,e,guidata(h)));

guidata(hObject,handles);


function tableSystemUpdate(hObject, eventdata, h)

set(h.table_system_matrix,'data', h.system.matrix)

% show the  optical system data
data2show = {h.setup.displyData(h.system.focal);...
        h.setup.displyData(h.system.L);...
        h.setup.displyData(h.system.Xf);...
        h.setup.displyData(h.system.Xb);...
        h.setup.displyData(h.system.m);...
        h.setup.displyData(h.system.vhf); ...
        h.setup.displyData(h.system.vhb);...
        h.setup.displyData(length(h.system.lens))...
        };
set(h.table_system_propertise,'data',data2show)

function show_all_Optical_system_callback(hObject, eventdata, handles)
%% show all system 
handles.system.showAllView(0.3)
function tableLensUpdate(hObject, eventdata, h)
if ~isempty(h.system.lens)
    lens = h.system.lens(h.system.indx);
    set(h.panel_lens_propertise,...
        'Title',strcat('Lens :',sprintf('%d',(h.system.indx)))...
        )
    
    
    data2show = {h.setup.displyData(lens.x);...
        h.setup.displyData(lens.y);...
        h.setup.displyData(lens.focal);...
        h.setup.displyData(lens.radius_left);...
        h.setup.displyData(lens.radius_right);...
        h.setup.displyData(lens.height);...
        h.setup.displyData(lens.width);...
        h.setup.displyData(lens.index_in);...
        h.setup.displyData(lens.index_out);...
        sprintf('%25s',lens.color);...
        };
    % update matrix lens table
    set(h.table_lens_matrix,'data',lens.matrix);
else
    set(h.panel_lens_propertise,...
        'Title','Lens : Nan'...
        )
    data = repmat({''},10,1);
    data2show = cellfun(@(x)h.setup.displyData(x),data,'UniformOutput',false);
    set(h.table_lens_matrix,'data',[1,0;0,1])
end
set(h.table_lens_propertise,'data',data2show)

function addLensCallback(hObject, eventdata, handles)
 % create new Lens
handles.system.addLens(Lens())

function removeLensCallback(hObject, eventdata, handles)

if ~isempty(handles.system.lens)
handles.system.removeLens(handles.system.lens(handles.system.indx))
end

function reset_system_callback(hObject, eventdata, handles)
handles.system.resetSystem();
table_ray_update_callback(hObject, eventdata, handles);

function table_lens_callback(hObject, eventdata, h)
lens = h.system.lens(h.system.indx);
allPropery = fieldnames(h.setup.lens);
properySelect = allPropery{eventdata.Indices(1)};
property = h.setup.lens.(properySelect);
switch property
    case 'color'
          lens.(property) = eventdata.NewData;
    otherwise
          lens.(property) = str2double(eventdata.NewData);
end

function table_ray_angle_callback(hObject, eventdata, handles)

handles.ray.teta(eventdata.Indices(1)) = str2double(eventdata.NewData);
table_ray_update_callback(hObject, eventdata, handles)

function table_ray_update_callback(hObject, eventdata, h)
data_angle =  arrayfun(@(x)sprintf('%15.*g',3,x),h.ray.teta(:),...
    'UniformOutput',false);
set(h.table_angle_rays,'data',data_angle)
% update Ray table
mat = cell2mat(h.ray.xyr);
xyr = reshape(mat,size(mat,1),size(mat,2));
interfaceNumbers =  size(xyr,2)/size(xyr,1);  
num = repmat(1:interfaceNumbers,size(xyr,1),1);
coulumNum = arrayfun(@(x){num2str(x)},num(:)');
% concatinate title and number 
coulumHeader = strcat(repmat({'x','y','angle'},1,interfaceNumbers),coulumNum);

xyr_color = paintColumeTable(xyr,{'blue','red','green'});
set(h.table_ray_path,'data',xyr_color,'ColumnName',coulumHeader);

function rayOnOffCallback(hObject, eventdata, h)
 h.ray.draw = logical(get(h.check_box_rays_on,'Value'));

function ray_color_popupmenu_callback(hObject, eventdata, handles)
colorCollection = get(hObject,'string');
handles.ray.color = colorCollection{hObject.Value};
        
function ray_y_callback(hObject, eventdata, handles) 
 
handles.fig.y = 0;
handles.fig.height = hObject.Value;
handles.ray.y = hObject.Value;
table_ray_update_callback(hObject, eventdata, handles)

function show_ray_refraction_point_callback(hObject, eventdata, handles)

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

% --- Outputs from this function are returned to the command line.
function varargout = OpticMat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
