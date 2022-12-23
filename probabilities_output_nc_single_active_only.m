clear;clc;close all;
folder = pwd;
%% Read the nc file outputted from "example_radionuclides_basic_for_surface.py"
filename = './nc_output/NECB_opnedrift_radionuclides_output_2000_01_17.nc';
% filename = 'simulation_radionuclides_Fukutoku-Okanoba_output.nc';
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
            (length(stranded_lat)==length(stranded_lon)) & (length(stranded_lat)>=1) & ...
            (length(trajectory)>=1)
        lat(i,stranded_lat) = NaN;
        lon(i,stranded_lon) = NaN;
        stranded_marker_lat(i,1) = lat(i,stranded_lat(1)-1);
        stranded_marker_lon(i,1) = lon(i,stranded_lon(1)-1);
        stranded_trajectory = [stranded_trajectory i];
    elseif (isempty(stranded_lat)==1) & (isempty(stranded_lon)==1)
        stranded_marker_lat(i,1) = NaN;
        stranded_marker_lon(i,1) = NaN;
        not_stranded_trajectory = [not_stranded_trajectory i];
    end
end
stranded_count = length(find(isnan(stranded_marker_lat)==0));
not_stranded_count = length(trajectory)-stranded_count;
%% Spatial range of latitude and longitude 
LAT_lim = [floor(min(lat(:)))-5 ceil(max(lat(:)))+5];
LON_lim = [floor(min(lon(:)))-5 ceil(max(lon(:)))+5];
LAT_lim_zoomin = [10 25];
LON_lim_zoomin = [115 130];
% LAT_lim = [0 60];
% LON_lim = [100 190];
%%
lon_input = lon(not_stranded_trajectory,:);
lat_input = lat(not_stranded_trajectory,:);
lon_input = lon_input(:);
lat_input = lat_input(:);
cd('./function')
[lon_distribution,lat_distribution,pd_distribution] = ...
    probability_density_distribution([110.125 179.875],[10.125 49.875],...
    0.25,lon_input,lat_input);
cd(folder)
%% Plotting data for checks
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
ax1 = axes;
m_proj('Mercator','lon',[LON_lim(1) LON_lim(end)],'lat',[LAT_lim(1) LAT_lim(end)]);
% m_proj('Mercator','lon',[LON_lim_zoomin(1) LON_lim_zoomin(end)],...
%     'lat',[LAT_lim_zoomin(1) LAT_lim_zoomin(end)]);
m_pcolor(lon_distribution-0.25/2,lat_distribution-0.25/2,pd_distribution*100);
shading flat;
% shading interp;
cb1 = colorbar;
%---imread colormap---%
[X1,cmap1] = imread('./colormap/jet.png');
RGB1 = ind2rgb(X1,cmap1);
colormap(ax1,reshape(RGB1(10,:,:),size(RGB1,2),3));
%---imread colormap---%
cb1.Label.String = 'Probabilities [%]';
cb1.FontSize = 15;
caxis([5 50])
hold on;
m_gshhs_h('patch',[0 0 0]);
hold on;
m_grid('tickdir','out','FontSize',25,'FontWeight','bold','LineWidth',3)
title([char(time(1)) ' - ' char(time(end))],'FontSize',15)
% lgd = legend([init active],{['initial (' num2str(not_stranded_count) ')'],...
%     ['active (' num2str(not_stranded_count) ')']});