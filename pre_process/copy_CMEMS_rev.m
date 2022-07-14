clear;clc;close all
load('CMEMS_2000.mat')
%%
n=datenum(2000,01,01,0,0,0):1:datenum(2000,06,30,0,0,0);
n2=(datenum(2000,01,01,0,0,0):1:datenum(2000,06,30,0,0,0))';

timex=(24.*(n-datenum(1990,01,01)));
time=(24.*(n2-datenum(1990,01,01)));
U_2=U_1(:,:,find(timex==time(1)):find(timex==time(1))+length(time)-1);
V_2=V_1(:,:,find(timex==time(1)):find(timex==time(1))+length(time)-1);
for i=1:length(time)
    U_3(:,:,i)=squeeze(U_2(:,:,i))';
    V_3(:,:,i)=squeeze(V_2(:,:,i))';
end
% time=(24.*(n2-datenum(1990,01,01)));
datestr(time/24+datenum(1990,01,01));
%%
% topo = zeros(size(U_3,1),size(U_3,2))-100;
[ELEV_topo,LON_topo,LAT_topo] = m_etopo2([LON(1) LON(end) LAT(1) LAT(end)]);
ELEV_topo(ELEV_topo>0) = 0;
ELEV_topo = -ELEV_topo;
%%
[LON_grid,LAT_grid] = meshgrid(LON,LAT);
topo = regrid_data(LAT_topo,LON_topo,ELEV_topo,LAT_grid,LON_grid);
%%
h = permute(topo,[2 1]);
%%
dim_lon = length(LON);
dim_lat = length(LAT);
dim_time = length(time);
%%
file_name = 'my_cmems_2000.nc';
delete(file_name);

% Create a netCDF file.
ncid = netcdf.create(file_name,'NC_WRITE');

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
netcdf.putVar(ncid,varid_lon,LON);
netcdf.putVar(ncid,varid_lat,LAT);
netcdf.putVar(ncid,varid_time,time);
netcdf.putVar(ncid,varid_water_u,U_3);
netcdf.putVar(ncid,varid_water_v,V_3);
netcdf.putVar(ncid,varid_h,h);


% Re-enter define mode.
netcdf.reDef(ncid);

% Create an attribute associated with the variable.
netcdf.putAtt(ncid,varid_lon,'standard_name','longitude');
netcdf.putAtt(ncid,varid_lon,'units','degree_north');
netcdf.putAtt(ncid,varid_lon,'axis','X');
netcdf.putAtt(ncid,varid_lat,'standard_name','latitude');
netcdf.putAtt(ncid,varid_lat,'units','degree_east');
netcdf.putAtt(ncid,varid_lat,'axis','Y');
netcdf.putAtt(ncid,varid_time,'units','hours since 1990-01-01 00:00:00');
netcdf.putAtt(ncid,varid_time,'time_origin','1990-01-01 00:00:00');
netcdf.putAtt(ncid,varid_water_u,'standard_name','eastward_sea_water_velocity');
netcdf.putAtt(ncid,varid_water_u,'units','meter second-1');
netcdf.putAtt(ncid,varid_water_u,'missing_value',-30000);
netcdf.putAtt(ncid,varid_water_u,'scale_factor',0.001);
netcdf.putAtt(ncid,varid_water_v,'standard_name','northward_sea_water_velocity');
netcdf.putAtt(ncid,varid_water_v,'units','meter second-1');
netcdf.putAtt(ncid,varid_water_v,'missing_value',-30000);
netcdf.putAtt(ncid,varid_water_v,'scale_factor',0.001);
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