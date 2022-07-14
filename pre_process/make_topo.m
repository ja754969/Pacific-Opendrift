clear all
topo=ncread('etopo2.nc','topo');
lat=ncread('etopo2.nc','lat');
lon=ncread('etopo2.nc','lon');

lon2= double(min(lon):1/32:max(lon))';
lat2= double(min(lat):1/32:max(lat))';
%%
[lat4,lon4]=meshgrid(lat2,lon2);
[lat3,lon3]=meshgrid(lat(:),lon(:));

topo3=interp2(lat3,lon3,topo,lat4,lon4);
topo3(topo3>=0)=NaN;
topo3=-(topo3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
film='mytopo2.nc';
nc=netcdf([film],'clobber');
%result = redef(nc);

nc('lon') = length(lon2);
nc('lat') = length(lat2);

% nc('time').Datatype='Double';

nc{'lon'}=ncdouble('lon') ;
nc{'lat'}=ncdouble('lat') ;
nc{'h'}=ncdouble('lat','lon');
% nc{'surf_el'}=ncshort('time', 'lat', 'lon');
% nc{'salinity'}=ncshort('time', 'depth', 'lat', 'lon');
% nc{'water_temp'}=ncshort('time', 'depth', 'lat', 'lon');
%result = endef(nc);


close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

ncwriteatt(film,'h','standard_name',['sea_floor_depth_below_sea_level']);
ncwriteatt(film,'h','units',['meter']);
ncwriteatt(film,'lat','standard_name',['latitude']);
ncwriteatt(film,'lat','axis',['Y']);
ncwriteatt(film,'lon','standard_name',['longitude']);
ncwriteatt(film,'lon','axis',['X']);


ncwrite(film,'lon',lon2);
ncwrite(film,'lat',lat2);
ncwrite(film,'h',topo3);
ncdisp(film)