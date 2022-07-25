clear;clc;close all;
%% Read the nc file outputted from "example_radionuclides_basic_for_surface.py"
filename = 'example_radionuclides_output.nc';
% filename = './consult/example_radionuclides_output.nc';
ncdisp(filename);
%% Read the variables from the nc file
trajectory = nc_varget(filename,'trajectory');
time = nc_varget(filename,'time'); % seconds since 1970-01-01 00:00:00
origin_marker = nc_varget(filename,'origin_marker');
lon = nc_varget(filename,'lon');
lat = nc_varget(filename,'lat');
sea_floor_depth_below_sea_level = nc_varget(filename,'sea_floor_depth_below_sea_level');
z = nc_varget(filename,'z');
diameter = nc_varget(filename,'diameter');
% land_binary_mask = nc_varget(filename,'land_binary_mask');
% x_sea_water_velocity = nc_varget(filename,'x_sea_water_velocity');
% y_sea_water_velocity = nc_varget(filename,'y_sea_water_velocity');
% moving = nc_varget(filename,'moving');
% status = nc_varget(filename,'status');
%% Adjust time format
time = seconds(time)+datetime(1970,01,01);
%% Adjust longitude and sea_floor_depth_below_sea_level
lon(lon<0) = lon(lon<0)+360;
sea_floor_depth_below_sea_level = -sea_floor_depth_below_sea_level;
%% Fixed the dimensions
if length(trajectory) == 1
    origin_marker = permute(origin_marker,[2 1]);
    lon = permute(lon,[2 1]);
    lat = permute(lat,[2 1]);
    sea_floor_depth_below_sea_level = permute(sea_floor_depth_below_sea_level,[2 1]);
    z = permute(z,[2 1]);
    diameter = permute(diameter,[2 1]);
%     land_binary_mask = permute(land_binary_mask,[2 1]);
%     x_sea_water_velocity = permute(x_sea_water_velocity,[2 1]);
%     y_sea_water_velocity = permute(y_sea_water_velocity,[2 1]);
%     moving = permute(moving,[2 1]);
%     status = permute(status,[2 1]);
end
%% Find stranded points
stranded_trajectory = [];
not_stranded_trajectory = [];
for i = 1:length(trajectory)
    stranded_lat = find(lat(i,:)>9.9*(10^35));
    stranded_lon = find(lon(i,:)>9.9*(10^35));
    if (isempty(stranded_lat)==0) & (isempty(stranded_lon)==0) & ...
            (length(stranded_lat)==length(stranded_lon)) & (length(stranded_lat)>1) & ...
            (length(trajectory)>1)
        lat(i,stranded_lat) = NaN;
        lon(i,stranded_lon) = NaN;
        stranded_marker_lat(i,1) = lat(i,stranded_lat(1)-1);
        stranded_marker_lon(i,1) = lon(i,stranded_lon(1)-1);
        stranded_trajectory = [stranded_trajectory i];
    elseif (isempty(stranded_lat)==0) & (isempty(stranded_lon)==0) & ...
            (length(stranded_lat)==length(stranded_lon)) & (length(stranded_lat)==1) & ...
            (length(trajectory)>1)
        lat(i,stranded_lat) = lat(i,stranded_lat-1);
        lon(i,stranded_lon) = lon(i,stranded_lon-1);
        stranded_marker_lat(i,1) = NaN;
        stranded_marker_lon(i,1) = NaN;
        not_stranded_trajectory = [not_stranded_trajectory i];
    else
        lat(i,stranded_lat) = NaN;
        lon(i,stranded_lon) = NaN;
        stranded_marker_lat(i,1) = lat(i,stranded_lat(1)-1);
        stranded_marker_lon(i,1) = lon(i,stranded_lon(1)-1);
        stranded_trajectory = [stranded_trajectory i];
    end
end
stranded_count = length(find(isnan(stranded_marker_lat)==0));
not_stranded_count = length(trajectory)-stranded_count;
%% Spatial range of latitude and longitude 
LAT_lim = [floor(min(lat(:)))-5 ceil(max(lat(:)))+5];
LON_lim = [floor(min(lon(:)))-5 ceil(max(lon(:)))+5];
% LAT_lim = [0 60];
% LON_lim = [100 180];
%% Plotting data for checks
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
m_proj('miller','lon',[LON_lim(1) LON_lim(end)],'lat',[LAT_lim(1) LAT_lim(end)]);
m_gshhs_h('patch',[0 0 0]);
hold on;
for ind = not_stranded_trajectory
%     ind = not_stranded_trajectory(i);
    init = m_plot(lon(ind,1),lat(ind,1),'Marker','.','MarkerSize',15,'Color','g');
    hold on;
    m_plot(lon(ind,:),lat(ind,:),'-b');
    hold on;
    active = m_plot(lon(ind,end),lat(ind,end),'Marker','.','MarkerSize',15,'Color','b');
    hold on
end
for ind = stranded_trajectory
%     ind = stranded_trajectory(i);
    init = m_plot(lon(ind,1),lat(ind,1),'Marker','.','MarkerSize',15,'Color','g');
    hold on;
    m_plot(lon(ind,:),lat(ind,:),'-r');
    hold on;
    stranded = m_plot(stranded_marker_lon(ind),stranded_marker_lat(ind),'Marker','.','MarkerSize',15,'Color','r');
    hold on
end
m_grid('tickdir','out','FontSize',25,'FontWeight','bold','LineWidth',3)
title([char(time(1)) ' - ' char(time(end))],'FontSize',15)
if stranded_count == 0
    lgd = legend([init active],{['initial (' num2str(not_stranded_count) ')'],...
        ['active (' num2str(not_stranded_count) ')']});
elseif (stranded_count ~= 0) & (not_stranded_count ~= 0)
    lgd = legend([init stranded active],{['initial (' num2str(not_stranded_count+stranded_count) ')'],...
        ['stranded (' num2str(stranded_count) ')'],...
        ['active (' num2str(not_stranded_count) ')']});
else
    lgd = legend([init stranded],{['initial (' num2str(not_stranded_count+stranded_count) ')'],...
        ['stranded (' num2str(stranded_count) ')']});
end