function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 14-Apr-2015 19:47:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(handles.pushbutton1, 'String', 'Choose image...');
[i_file,i_PathName] = uigetfile({'*.jpg;*.png;*.tif;*.bmp', 'Image File';...
  '*.*', 'All Files (*.*)'},...
    'Select the image',[cd '\']); 
if ~isequal(i_file, 0)
    % Reading the Image file
    i_file = fullfile(i_PathName,i_file);
    handles.image = imread(i_file);
    handles.image = im2double(handles.image);
else
    set(handles.pushbutton1, 'String', 'Load');
    beep
    return;
end
 set(handles.pushbutton1, 'String', 'Wait...');
imageSaliency = IntensityMap(handles.image);
[num, match, loc] = mymatch(i_file);
if num <= 4
    msgbox('Horalka nelokalizovana','Error');
else
    load('target.mat');


    indexes = find(match);
    x1 = zeros(2, length(indexes));
    x1(1,:) = loc(indexes,2);
    x1(2,:) = loc(indexes,1);

    x2 = zeros(2, length(indexes));
    x2(1,:) = loct(match(indexes),2);
    x2(2,:) = loct(match(indexes),1);
    
    [H, inliers] = ransacfithomography(x2, x1, .01);
   
    load('target_corners.mat');
    % load matrix corners where cols are coordinates of template corners
    corners(3,:) = [1,1,1,1];
    
    
    cornersTransf = H * corners;
    
    for i = 1:size(cornersTransf,2)
        cornersTransf(:,i) = cornersTransf(:,i) ./ cornersTransf(3,i);
    end    
    
    
    
    x = abs(cornersTransf(1,:));
    y = abs(cornersTransf(2,:));
    [height, width, channels] = size(handles.image);
    mask = poly2mask(x,y,height, width);
    figure; imshow(mask);
    handles.image = mask .* imageSaliency;
    axes(handles.axes1);
    imshow(handles.image);
end
 set(handles.pushbutton1, 'String', 'Load');
 %beep
guidata(hObject, handles);

