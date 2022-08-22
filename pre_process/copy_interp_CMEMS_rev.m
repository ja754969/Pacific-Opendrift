clear;clc;close all
%%
% timex=datetime(2021,01,01):datetime(2021,06,30);
timex=datetime(2020,07,01):datetime(2020,12,31);
%%
data_folder=['D:/Data/origin/' ...
        'cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D/half-year_uv/'];
%%
if (year(timex(end))-year(timex(1))==0) & month(timex(1))==1 & day(timex(1))==1 & ...
        month(timex(end))==6 & day(timex(end))==30
    y = num2str(year(timex(1)));
    [U_1,V_1,LAT,LON,time] = nc_to_mat([data_folder 'CMEMS_ADT_u-current_Jan_to_Jun_' y '.nc'],...
        [data_folder 'CMEMS_ADT_v-current_Jan_to_Jun_' y '.nc'],['CMEMS_' y '_1.mat']);
    file_name = ['interp_cmems_' y '_1.nc'];
elseif (year(timex(end))-year(timex(1))==0) & month(timex(1))==7 & day(timex(1))==1 & ...
        month(timex(end))==12 & day(timex(end))==31
    y = num2str(year(timex(1)));
    [U_1,V_1,LAT,LON,time] = nc_to_mat([data_folder 'CMEMS_ADT_u-current_Jul_to_Dec_' y '.nc'],...
        [data_folder 'CMEMS_ADT_v-current_Jul_to_Dec_' y '.nc'],['CMEMS_' y '_2.mat']);
    file_name = ['interp_cmems_' y '_2.nc'];
end
%%
lat_to_be = [LAT(1):0.25:LAT(end)];
lon_to_be = [LON(1):0.25:LON(end)];
[lon_to_be,lat_to_be] = meshgrid(lon_to_be,lat_to_be);
U_1_interp = interp_data(LAT,LON,U_1,lat_to_be,lon_to_be);
V_1_interp = interp_data(LAT,LON,V_1,lat_to_be,lon_to_be);
%%
time = hours(timex - datetime(1990,01,01));
%%
U_2=U_1_interp(:,:,:);
V_2=V_1_interp(:,:,:);
%%
for i=1:length(time)
    U_3(:,:,i)=squeeze(U_2(:,:,i))';
    V_3(:,:,i)=squeeze(V_2(:,:,i))';
end
%%
[topo,LON_topo,LAT_topo] = m_etopo2([LON(1) LON(end) LAT(1) LAT(end)]);
topo(topo>0) = 0;
topo = -topo;
%%
h = permute(topo,[2 1]);
%%
dim_lon = length(lon_to_be);
dim_lat = length(lat_to_be);
dim_time = length(time);
%% Longitude for HYCOM format
lon_ind_west = find(lon_to_be<180);
lon_ind_east = find(lon_to_be>=180);
if isempty(lon_ind_east)==0
    LON_for_hycom = [(lon_to_be(lon_ind_east)-360);lon_to_be(lon_ind_west)];
    h_for_hycom = [h(lon_ind_east,:);h(lon_ind_west,:)];
else
    LON_for_hycom = lon_to_be;
    h_for_hycom = h;
end
%%
delete(['./processed_data/' file_name]);

% Create a netCDF file.
ncid = netcdf.create(['./processed_data/' file_name],'NC_WRITE');

% Define a dimension in the file.
dimid_lon = netcdf.defDim(ncid,'lon',dim_lon);
dimid_lat = netcdf.defDim(ncid,'lat',dim_lat);
dimid_time = netcdf.defDim(ncid,'time',dim_time);
% dimid3 = netcdf.defDim(ncid,'lon',dim_lon,'lat',dim_lat,'time',dim_time);
 
% Define a new variable in the file.
varid_lon = netcdf.defVar(ncid,'lon','double',dimid_lon);
varid_lat = netcdf.defVar(ncid,'lat','double',dimid_lat);
varid_time = netcdf.defVar(ncid,'time','double',dimid_time);
varid_water_u = netcdf.defVar(ncid,'water_u','double',[dimid_lon dimid_lat dimid_time]);
varid_water_v = netcdf.defVar(ncid,'water_v','double',[dimid_lon dimid_lat dimid_time]);
varid_h = netcdf.defVar(ncid,'h','double',[dimid_lon dimid_lat]);

% Leave define mode and enter data mode to write data.
netcdf.endDef(ncid);

% Write data to variable.
netcdf.putVar(ncid,varid_lon,LON_for_hycom);
netcdf.putVar(ncid,varid_lat,lat_to_be);
netcdf.putVar(ncid,varid_time,time);
netcdf.putVar(ncid,varid_water_u,U_3);
netcdf.putVar(ncid,varid_water_v,V_3);
netcdf.putVar(ncid,varid_h,h_for_hycom);


% Re-enter define mode.
netcdf.reDef(ncid);

% Create an attribute associated with the variable.
netcdf.putAtt(ncid,varid_lon,'standard_name','longitude');
netcdf.putAtt(ncid,varid_lon,'units','degree_east');
netcdf.putAtt(ncid,varid_lon,'axis','X');
netcdf.putAtt(ncid,varid_lat,'standard_name','latitude');
netcdf.putAtt(ncid,varid_lat,'units','degree_north');
netcdf.putAtt(ncid,varid_lat,'axis','Y');
netcdf.putAtt(ncid,varid_time,'units','hours since 1990-01-01 00:00:00');
netcdf.putAtt(ncid,varid_time,'time_origin','1990-01-01 00:00:00');
netcdf.putAtt(ncid,varid_water_u,'standard_name','eastward_sea_water_velocity');
netcdf.putAtt(ncid,varid_water_u,'units','meter second-1');
netcdf.putAtt(ncid,varid_water_u,'missing_value',-30000);
netcdf.putAtt(ncid,varid_water_u,'scale_factor',1);
netcdf.putAtt(ncid,varid_water_v,'standard_name','northward_sea_water_velocity');
netcdf.putAtt(ncid,varid_water_v,'units','meter second-1');
netcdf.putAtt(ncid,varid_water_v,'missing_value',-30000);
netcdf.putAtt(ncid,varid_water_v,'scale_factor',1);
netcdf.putAtt(ncid,varid_h,'standard_name','sea_floor_depth_below_sea_level');
netcdf.putAtt(ncid,varid_h,'grid_mapping','projection_stere');
netcdf.putAtt(ncid,varid_h,'grid','grid');
netcdf.putAtt(ncid,varid_h,'units','meter');

% Define fill parameters for NetCDF variable
% netcdf.defVarFill(ncid,varid,false,-30000);
netcdf.defVarFill(ncid,varid_water_u,false,-30000);
netcdf.defVarFill(ncid,varid_water_v,false,-30000);

% Close netCDF file
netcdf.close(ncid);