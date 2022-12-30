clear;clc;close all;
folder = pwd;
%% Year of late spring and early summer
start_year = 1993;
end_year = 2019;
%%
LON_lim = [115 140];
LAT_lim = [15 30];
% LAT_lim = [floor(min(lat(:)))-5 ceil(max(lat(:)))+5];
% LON_lim = [floor(min(lon(:)))-5 ceil(max(lon(:)))+5];
LAT_lim_zoomin = [10 25];
LON_lim_zoomin = [115 140];
% LAT_lim = [0 60];
% LON_lim = [100 190];
for month_i = 1:12
    %% Find the days
    first_date = datetime(start_year,month_i,01);
    last_date = datetime(end_year,month_i+1,01)-days(1);
    date_array = first_date:days(1):last_date;
    period_ind = find((year(date_array)<=1997 | year(date_array)>=2014) &...
        month(date_array)>=month_i & month(date_array)<=month_i);
    date_period = date_array(period_ind);
    index_num = length(date_period);
    %%
    lon_input = [];
    lat_input = [];
    lon_init = [];
    lat_init = [];
    eastward_count = 0;
    trajectories_count = 0;
    for i = 1:index_num
        clc
        %%
        the_date = date_period(i);
        yyyy = num2str(year(the_date));
        MM = num2str(month(the_date),'%02.0f'); 
        dd = num2str(day(the_date),'%02.0f'); 
    %     HH = num2str(hour(the_date),'%02.0f');
        %% Read the nc file outputted from "Python"
    %     filename = ['D:/Data/used_by_projects/Pacific-Opendrift/nc_output/' ...
    %         'Kuroshio_Luzon_path/number_of_trajectory_1000/seed_radius_km_100/' ...
    %         'init_lat_21.125_lon_122.375/Opendrift_90days_Kuroshio_Luzon_path_' ...
    %         yyyy '_' MM '_' dd '.nc'];
        filename = ['D:/Data/used_by_projects/Pacific-Opendrift/nc_output/' ...
            'Kuroshio_upstream_path/number_of_trajectory_1000/seed_radius_km_100/' ...
            'init_lat_18.375_lon_122.875/Opendrift_90days_Kuroshio_upstream_path_' ...
            yyyy '_' MM '_' dd '.nc'];
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
        stranded_trajectory_i = [];
        not_stranded_trajectory_i = [];
        eastward_trajectory_i = [];
        for trajectory_i = 1:length(trajectory)
            trajectories_count = trajectories_count+1;
            stranded_lat = find(lat(trajectory_i,:)>9.9*(10^35));
            stranded_lon = find(lon(trajectory_i,:)>9.9*(10^35));
            if (isempty(stranded_lat)==0) & (isempty(stranded_lon)==0) & ...
                    (length(stranded_lat)==length(stranded_lon)) & ...
                    (length(stranded_lat)>=1) & ...
                    (length(trajectory)>=1)
                lat(trajectory_i,stranded_lat) = NaN;
                lon(trajectory_i,stranded_lon) = NaN;
                stranded_marker_lat(trajectory_i,1) = lat(trajectory_i,stranded_lat(1)-1);
                stranded_marker_lon(trajectory_i,1) = lon(trajectory_i,stranded_lon(1)-1);
                stranded_trajectory_i = [stranded_trajectory_i trajectory_i];
            elseif (isempty(stranded_lat)==1) & (isempty(stranded_lon)==1)
                stranded_marker_lat(trajectory_i,1) = NaN;
                stranded_marker_lon(trajectory_i,1) = NaN;
                not_stranded_trajectory_i = [not_stranded_trajectory_i trajectory_i];
            end
            %% Find the eastward trajectories
            lon_diff = lon(trajectory_i,end)-lon(trajectory_i,1);
            is_lat_in_range_1 = (lat(trajectory_i,1)>=17 & lat(trajectory_i,1)<=21);
            is_lat_in_range_end = (lat(trajectory_i,end)>=18 & lat(trajectory_i,end)<=21);
            lon_diff_target = 10;
            if (lon_diff>=lon_diff_target) & (is_lat_in_range_end==true)
                eastward_trajectory_i = [eastward_trajectory_i trajectory_i];
                eastward_count = eastward_count+1;
                disp('Stayed.');
            else
                disp('Not in the range.');
            end
        end
        stranded_count = length(find(isnan(stranded_marker_lat)==0));
        not_stranded_count = length(trajectory)-stranded_count;
        %% Spatial range of latitude and longitude  
    %     lon_input_i = lon(not_stranded_trajectory_i,:); % active only (lon)
    %     lat_input_i = lat(not_stranded_trajectory_i,:); % active only (lat)
    %     lon_input_i = lon(stranded_trajectory_i,:); % stranded only (lon)
    %     lat_input_i = lat(stranded_trajectory_i,:); % stranded only (lat)
        lon_input_i = lon(eastward_trajectory_i,:); % eastwardly active and stranded (lon)
        lat_input_i = lat(eastward_trajectory_i,:); % eastwardly active and stranded (lat)
    %     lon_input_i = lon(:,:); % active and stranded (lon)
    %     lat_input_i = lat(:,:); % active and stranded (lat)
        lon_input = [lon_input;lon_input_i(:)];
        lat_input = [lat_input;lat_input_i(:)];
        %%
        lon_init_i = lon_input_i(:,1);
        lat_init_i = lat_input_i(:,1);
        lon_init = [lon_init;lon_init_i(:)];
        lat_init = [lat_init;lat_init_i(:)];

    end
    cd('./function')
    [lon_distribution,lat_distribution,pd_distribution] = ...
        probability_density_distribution([110.125 179.875],[10.125 49.875],...
        0.25,lon_input,lat_input);
    cd(folder)
    disp(['Trajectories: ' num2str(eastward_count) ' out of ' ...
        num2str(trajectories_count)  ' are eastward. (' ...
        num2str(round(eastward_count/trajectories_count*100,2)) '%)'])
    eastward_probability(month_i) = eastward_count/trajectories_count*100;
end
%% Plotting data for checks
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
ax1 = axes;
bar(1:12,eastward_probability);
xlabel('Month')
ylabel('%')
ax1.XTickLabel = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
ax1.FontSize = 20;
saveas(fig,['./image/eastward_monthly_probabilities/eastward_more_than_' ...
    num2str(lon_diff_target) 'deg_' num2str(start_year) '_' num2str(end_year) ...
    '_non_hiatus.png']);
