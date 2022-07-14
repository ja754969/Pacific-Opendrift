clear all
load('NP_topography_regrid.mat','NP_topography');
load('NP_topography_regrid.mat','lat');
load('NP_topography_regrid.mat','lon');
% lon2= double(min(lon):1/32:max(lon))';
% lat2= double(min(lat):1/32:max(lat))';
lat = lat(:,1);
lon = lon(1,:)';
topo = permute(NP_topography,[2 1]);
%%
dim_lon = length(lon);
dim_lat = length(lat);
%%
file_name = 'my_topo.nc';
delete(file_name);

% Create a netCDF file.
ncid = netcdf.create(file_name,'NC_WRITE');

% Define a dimension in the file.
dimid_lon = netcdf.defDim(ncid,'lon',dim_lon);
dimid_lat = netcdf.defDim(ncid,'lat',dim_lat);
% dimid3 = netcdf.defDim(ncid,'lon',dim_lon,'lat',dim_lat,'time',dim_time);

% Define a new variable in the file.
varid_lon = netcdf.defVar(ncid,'lon','double',dimid_lon);
varid_lat = netcdf.defVar(ncid,'lat','double',dimid_lat);
varid_topo = netcdf.defVar(ncid,'topo','double',[dimid_lon dimid_lat]);

% Leave define mode and enter data mode to write data.
netcdf.endDef(ncid);

% Write data to variable.
netcdf.putVar(ncid,varid_lon,lon);
netcdf.putVar(ncid,varid_lat,lat);
netcdf.putVar(ncid,varid_topo,topo);


% Re-enter define mode.
netcdf.reDef(ncid);

% Create an attribute associated with the variable.
netcdf.putAtt(ncid,varid_lon,'standard_name','longitude');
netcdf.putAtt(ncid,varid_lon,'axis','X');
netcdf.putAtt(ncid,varid_lat,'standard_name','latitude');
netcdf.putAtt(ncid,varid_lat,'axis','Y');
netcdf.putAtt(ncid,varid_topo,'standard_name','sea_floor_depth_below_sea_level');

% Define fill parameters for NetCDF variable
% netcdf.defVarFill(ncid,varid,false,-30000);
% netcdf.defVarFill(ncid,varid_water_u,false,-30000);
% netcdf.defVarFill(ncid,varid_water_v,false,-30000);

% Close netCDF file
netcdf.close(ncid);