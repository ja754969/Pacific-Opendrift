clear;clc;close all;
%%
filename = 'ADT_2016-01-17.nc';
ncdisp(filename)
%%
adt = permute(nc_varget(filename,'adt'),[2 3 1]);
latitude = nc_varget(filename,'latitude');
longitude = nc_varget(filename,'longitude');
time = nc_varget(filename,'time');
%%
[lon,lat] = meshgrid(longitude,latitude);
longitude_to_be = [120.125:1/60:130.875];
latitude_to_be = [20.125:1/60:30.875];
longitude_to_be_length = length(longitude_to_be);
latitude_to_be_length = length(latitude_to_be);
[lon_to_be,lat_to_be] = meshgrid(longitude_to_be,latitude_to_be);
%%
% data_flag = NaN(latitude_to_be_length,longitude_to_be_length);
% for i = 1:numel(data_flag)
%     lon_is_in_array_or_not = is_in_array(lon,lon_to_be(i));
%     lat_is_in_array_or_not = is_in_array(lat,lat_to_be(i));
%     if lon_is_in_array_or_not==1 & lat_is_in_array_or_not==1
%         data_flag(i) = 1;
%     else
%         data_flag(i) = 0;
%     end
% end
%%


%%
% data_interp = interp_data(lat,lon,adt,lat_to_be,lon_to_be);
%%
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
ax = axes;
ax.Position = [0.05 0.05 0.4 0.9];
m_proj('miller','lon',[120 130],'lat',[20 30]);
hold on;
m_pcolor(lon,lat,adt);shading flat;
% m_pcolor(lon_to_be,lat_to_be,adt_q);shading flat;
c1 = colorbar;
colormap('jet');
% % %---imread colormap---%
% % [X1,cmap1] = imread('./colormap/temp_19lev.png');
% % RGB1 = ind2rgb(X1,cmap1);
% % colormap(ax1,reshape(RGB1(10,:,:),size(RGB1,2),3));
% % %---imread colormap---%
% c1.Label.String = '[m]';
% c1.FontSize = 15;
hold on;
m_gshhs_f('patch',[0.5 0.5 0.5]);
m_grid('tickdir','out','FontSize',25,'FontWeight','bold','LineWidth',3)

% caxis([-0.4 0.4])
ax1.TickDir = 'out';