clear;clc;close all;
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
land_binary_mask = nc_varget(filename,'land_binary_mask');
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
%% Catch the starting points
origin_lon = lon(:,1);
origin_lat = lat(:,1);
%%
figure;
subplot(2,1,1)
histogram(origin_lon,'BinWidth',0.005)
subplot(2,1,2)
histogram(origin_lat,'BinWidth',0.005)