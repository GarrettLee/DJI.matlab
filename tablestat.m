function varargout = tablestat(varargin)
% TABLESTAT M-file for tablestat.fig
%      TABLESTAT, by itself, creates a new TABLESTAT or raises the existing
%      singleton*.
%
%      H = TABLESTAT returns the handle to a new TABLESTAT or the handle to
%      the existing singleton*.
%
%      TABLESTAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLESTAT.M with the given input arguments.
%
%      TABLESTAT('Property','Value',...) creates a new TABLESTAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tablestat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tablestat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tablestat

% Last Modified by GUIDE v2.5 17-Apr-2008 12:01:02
% Copyright 1984-2008 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tablestat_OpeningFcn, ...
                   'gui_OutputFcn',  @tablestat_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
% End initialization code - DO NOT EDIT
end


% --- Executes just before tablestat is made visible.
function tablestat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tablestat (see VARARGIN)

% ---- Customized as follows ----

% Choose default command line output for tablestat
handles.output = hObject;
% Declare cache for selection, which starts out empty
handles.currSelection = [];
% Update handles structure
guidata(hObject, handles);
% Sunspot data set (sunspot.dat) is preloaded
% into the GUI in data_table
table = get(handles.data_table,'Data');
% Compute stats and draw graph for entire table ("Population')
refreshDisplays(table, handles, 1)


% --- Outputs from this function are returned to the command line.
function varargout = tablestat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following field (see UITABLE)
%  Indices:  row and column indices of the cell(s) currently selected
% handles    structure with handles and user data (see GUIDATA)

% ---- Customized as follows ----
% Obtain 1st column of current selection indices from event data;
% this contains row indices. We don't need column indices.
selection = eventdata.Indices(:,1);
% Remove duplicate row IDs
selection = unique(selection);
% Don't process less than a minimum nuber of observations
if size(selection) < 11
    return
end
% Obtain the data table
table = get(hObject,'Data');
% The selection is the table for stats and plot purposes;
% always extract both columns
% Cache the selection in case the plot type changes
handles.currSelection = selection;
guidata(hObject,handles)
% Update the stats and plot for new selection
refreshDisplays(table(selection,:), handles, 2)


% --- Executes on selection change in plot_type.
function plot_type_Callback(hObject, eventdata, handles)
% hObject    handle to plot_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ---- Customized as follows ----
% Determine state of the pop-up and assign the appropriate string
% to the plot panel label
index = get(hObject,'Value');    % What plot type is requested?
strlist = get(hObject,'String');        % Get the choice's name
set(handles.uipanel3,'Title',strlist(index))  % Rename uipanel3

% Plot one axes at a time, changing data; first the population
table = get(handles.data_table,'Data'); % Obtain the data table
refreshDisplays(table, handles, 1)

% Now compute stats for and plot the selection, if needed.
% Retrieve the stored event data for the last selection
selection = handles.currSelection;
if length(selection) > 10  % If more than 10 rows selected
    refreshDisplays(table(selection,:), handles, 2)
else
    % Do nothing; insufficient observations for statistics
end

                  
% --- Executes during object creation, after setting all properties.
function plot_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    

% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ---- Customized as follows ----
close(ancestor(hObject,'figure'))


% --------------------------------------------------------------------
function plot_ax1_Callback(hObject, eventdata, handles)
% hObject    handle to plot_ax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Displays contents of axes1 at larger size in a new figure

% Create a figure to receive this axes' data
axes1fig = figure;
% Copy the axes and size it to the figure
axes1copy = copyobj(handles.axes1,axes1fig);
set(axes1copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60]);
% Assemble a title for this new figure
str = [get(handles.uipanel3,'Title') ' for ' ...
       get(handles.poplabel,'String')];
title(str,'Fontweight','bold')
% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes1fig = axes1fig;
handles.axes1copy = axes1copy;
guidata(hObject,handles);


% --------------------------------------------------------------------
function plot_ax2_Callback(hObject, eventdata, handles)
% hObject    handle to plot_ax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Displays contents of axes2 at larger size in a new figure

% Create a figure to receive this axes' data
axes2fig = figure;
% Copy the axes and size it to the figure
axes2copy = copyobj(handles.axes2,axes2fig);
set(axes2copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60]);
% Assemble a title for this new figure
str = [get(handles.uipanel3,'Title') ' for ' ...
       get(handles.sellabel,'String')];
title(str,'Fontweight','bold')
% Save handles to new fig and axes in case
%  we want to do anything else to them
handles.axes1fig = axes2fig;
handles.axes1copy = axes2copy;
guidata(hObject,handles);


function refreshDisplays(table, handles, item)
% Updates the statistics table and one of the plots.
% Called from several tablestat GUI callbacks.
%   table    The data to summarize (a population or selection)
%            it has only one column
%   handles  The handles structure
%   item     Which column and corresponsing plot to update

% Choose appropriate axes
if isequal(item,1)
    ax = handles.axes1;
elseif isequal(item,2)
    ax = handles.axes2;
end
% Generate appropriate plot; return val peak is used by setStats
peak = plotPeriod(ax, table,...
              get(handles.plot_type,'Value'));
% Get the stats table from the gui
stats = get(handles.data_stats, 'Data');
% Generate the stats for the selection
stats = setStats(table, stats, item, peak);
% Replace the stats in the gui with the updated ones
set(handles.data_stats, 'Data', stats);
set(ax,'FontSize',7.0);


function stats = setStats(table, stats, col, peak)
% Computes basic statistics for data table.
%   table  The data to summarize (a population or selection)
%   stats  Array of statistics to update
%   col    Which column of the array to update
%   peak   Value for the peak period, computed externally

stats{1,col} =   size(table,1);      % Number of rows
stats{2,col} =    min(table(:,2));
stats{3,col} =    max(table(:,2));
stats{4,col} =   mean(table(:,2));
stats{5,col} = median(table(:,2));
stats{6,col} =    std(table(:,2));
stats{7,col} =        table(1,1);    % First row
stats{8,col} =        table(end,1);  % Last row
if ~isempty(peak)
    stats{9,col} = peak;             % Peak period from FFT
end


function peak = plotPeriod(ax, table, plottype)
% For plottype = 1, plots a line graph of the table data
% For plottype = 2, computes fft of table data, plots a line plot
% of the power spectrum, and marks and returns its highest value,
% signifying the primary period (in years in this case).
% In all cases, table is an n-by-1 vector.
%   ax        Handle to axes to plot into
%   table     Data to use for fft
%   plottype  index of type of plot to make:
%               1 = timeseries (x = Year, y = Sunspots)
%               2 = FFT periodogram using Sunspots only
%
% Part of this code has been adapted from MATLAB demo sunspots.m

if isequal(plottype,1)       % Just plot Year as x and Sunspots as y
    peak = [];               % No FFT output from this type of plot
    plot(ax,table(:,1),table(:,2),'LineWidth',2);
elseif isequal(plottype,2)   % Compute power spectrum and plot v. period
    relNums = table(:,2);
    n = size(relNums);
    Y = fft(relNums,n(1));
    % The first component of Y is simply the sum of the data,
    % and can be removed.
    Y(1) = [];
    n = length(Y);
    % The complex magnitude squared of Y is called the power,
    % and a plot of power versus frequency is a "periodogram".
    power = abs(Y(1:floor(n/2))).^2;
    nyquist = 1/2;
    freq = (1:n/2)/(n/2)*nyquist;
    % Plotting power versus period (where period=1./freq) is more
    % understandable than power v. frequency. Doing so shows a
    % very prominent cycle with a length of about 11 years.
    period = 1./freq;
    plot(ax,period,power,'LineWidth',2);
    axis(ax,[0 35 0 2e+7]);
    hold(ax,'on');
    % Get the index of the maximum Power (a vector when ties exist)
    index = find(power == max(power));
    % Get value of period where power is maximum
    peak = period(index);
    % Plot a red circular marker at the highest point(s)
    plot(ax,peak,power(index),'r.', 'MarkerSize',16);
    set(ax,'Xtick',[0 5 10 15 20 25 30 35]);
    hold(ax,'off');
end


% --------------------------------------------------------------------
function plot_Axes1_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% UNUSED - For parent of uicontextmenu plot_ax1

% --------------------------------------------------------------------
function plot_Axes2_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% UNUSED - For parent of uicontextmenu plot_ax2
