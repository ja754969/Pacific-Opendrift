clear;clc;close all;
folder = pwd;
lon_diff_target = 7;
number_of_trajectory = 1000;
simulation_days = 150;
year_range = 1993:2020;
year_i_count = 0;
eastward_probability_all = NaN(length(year_range),12);
eastward_count_all = NaN(length(year_range),12);
%%
for year_i = year_range
    close all
    %% Year of late spring and early summer
    start_year = year_i;
    end_year = year_i;
    eastward_probability_month_i_in_year_i = NaN(1,12);
    eastward_count_month_i_in_year_i = NaN(1,12);
    for month_i = 1:12
        %% Find the days
        first_date = datetime(start_year,month_i,01);
        last_date = datetime(end_year,month_i+1,01)-days(1);
        date_array = first_date:days(1):last_date;
        period_ind = find(month(date_array)>=month_i & month(date_array)<=month_i);
        date_period = date_array(period_ind);
        index_num = length(date_period);
        %%
        lon_input = [];
        lat_input = [];
        lon_init = [];
        lat_init = [];
        eastward_count_month_i = 0;
        not_eastward_count_month_i = 0;
        sum_of_count_month_i = 0;
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
%             filename = ['D:/Data/used_by_projects/Pacific-Opendrift/nc_output/' ...
%                 'Kuroshio_Luzon_path/number_of_trajectory_' ...
%                 num2str(number_of_trajectory) '/seed_radius_km_100/' ...
%                 'init_lat_21.125_lon_122.375/Opendrift_' ...
%                 num2str(simulation_days) 'days_Kuroshio_Luzon_path_' ...
%                 yyyy '_' MM '_' dd '.nc'];
            filename = ['D:/Data/used_by_projects/Pacific-Opendrift/nc_output/' ...
                'Kuroshio_upstream_path/number_of_trajectory_' ...
                num2str(number_of_trajectory) '/seed_radius_km_100/' ...
                'init_lat_18.375_lon_122.875/Opendrift_' num2str(simulation_days) ...
                'days_Kuroshio_upstream_path_' ...
                yyyy '_' MM '_' dd '.nc'];
%             ncdisp(filename);
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
    %             is_lat_in_range_1 = (lat(trajectory_i,1)>=17 & lat(trajectory_i,1)<=21);
                is_lat_in_range_end = (lat(trajectory_i,end)>=17 & lat(trajectory_i,end)<=21);
                
                if (lon_diff>=lon_diff_target) & (is_lat_in_range_end==true)
                    eastward_trajectory_i = [eastward_trajectory_i trajectory_i];
                    eastward_count_month_i = eastward_count_month_i+1;
                else
                    not_eastward_count_month_i = not_eastward_count_month_i+1;
                end
                
            end
            sum_of_count_month_i = eastward_count_month_i + not_eastward_count_month_i;
            
            %%
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
        
        if sum_of_count_month_i ~= trajectories_count
            break
            error('Error occurred.');
        end
        cd('./function')
        [lon_distribution,lat_distribution,pd_distribution] = ...
            probability_density_distribution([110.125 179.875],[10.125 49.875],...
            0.25,lon_input,lat_input);
        cd(folder)
        disp(['Trajectories: ' num2str(eastward_count_month_i) ' out of ' ...
            num2str(trajectories_count)  ' are eastward. (' ...
            num2str(round(eastward_count_month_i/trajectories_count*100,2)) '%)'])
        disp(['Trajectories: ' num2str(not_eastward_count_month_i) ' out of ' ...
            num2str(trajectories_count)  ' are not eastward. (' ...
            num2str(round(not_eastward_count_month_i/trajectories_count*100,2)) '%)'])
        eastward_probability_month_i_in_year_i(1,month_i) = eastward_count_month_i/trajectories_count*100;
        eastward_count_month_i_in_year_i(1,month_i) = eastward_count_month_i;
    end
    %% Plotting data for checks
    fig = figure;
    fig.PaperUnits = 'centimeters';
    fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
    fig.PaperType = '<custom>';
    fig.WindowState = 'maximized';
    fig
    ax1 = axes;
    bar(1:12,eastward_probability_month_i_in_year_i);
    xlabel('Month')
    ylabel('%')
    ax1.XTickLabel = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
    ax1.FontSize = 20;
    saving_folder = ['./image/eastward_monthly_probabilities/' ...
        num2str(simulation_days) 'days'];
    mkdir(saving_folder);
    saveas(fig,[saving_folder '/eastward_more_than_' ...
        num2str(lon_diff_target) 'deg_' num2str(start_year) '_' num2str(end_year) ...
        '.png']);
    %%
    year_i_count = year_i_count+1;
    eastward_probability_all(year_i_count,1:12) = eastward_probability_month_i_in_year_i;
    eastward_count_all(year_i_count,1:12) = eastward_count_month_i_in_year_i;
end

%%
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
ax2 = axes;
year_all = 1993:2019;
hiatus_year_ind = zeros(length(year_all),1);
hiatus_year_ind(year_all>=1998 & year_all<=2013) = 1;
plot(1:12,sum(eastward_count_all(find(hiatus_year_ind==1),1:12),1),'rs-',...
    'MarkerSize',12,'MarkerFaceColor','r'); % hiatus
hold on;
plot(1:12,sum(eastward_count_all(find(hiatus_year_ind==0),1:12),1),'bs-',...
    'MarkerSize',12,'MarkerFaceColor','b'); % non-hiatus
hold off;
xlabel('Month');
ax2.XTick = 1:12;
ax2.XTickLabel = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
ylabel('Numbers');
ax2.FontSize = 20;
saving_folder = ['./image/eastward_monthly_numbers/' num2str(simulation_days) 'days'];
mkdir(saving_folder);
saveas(fig,[saving_folder '/eastward_more_than_' ...
        num2str(lon_diff_target) 'deg_' num2str(year_range(1)) '_' num2str(year_range(end)) ...
        '_hiatus(red)_and_nonhiatus(blue).png']);
%%
fig = figure;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [29.7 21]; % A4 papersize (horizontal,21-by-29.7 cm,[width height])
fig.PaperType = '<custom>';
fig.WindowState = 'maximized';
fig
ax3 = axes;
year_all = 1993:2019;
plot(1:12,sum(eastward_count_all(:,1:12),1),'bs-',...
    'MarkerSize',12,'MarkerFaceColor','b'); % hiatus and non-hiatus
hold off;
xlabel('Month');
ax3.XTick = 1:12;
ax3.XTickLabel = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';...
    'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
ylabel('Numbers');
ax3.FontSize = 20;
saving_folder = ['./image/eastward_monthly_numbers/' num2str(simulation_days) 'days'];
mkdir(saving_folder);
saveas(fig,[saving_folder '/eastward_more_than_' ...
        num2str(lon_diff_target) 'deg_' ...
        num2str(year_range(1)) '_' num2str(year_range(end)) ...
        '_all_time.png']);