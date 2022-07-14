clear all 
clc
data='roms_his_remake_ntide.nc';
lat=ncread(data,'lat_rho');
lon=ncread(data,'lon_rho');
mask_rho=ncread(data,'mask_rho');
lon2=min(min(lon)):1/16:max(max(lon))';
lat2=min(min(lat)):1/16:max(max(lat))';

%depth=([0:2:9 10:50:320 500:200:2000])';
load('u_v.mat')
u(u==0)=NaN;v(v==0)=NaN;
w(w==0)=NaN;
% u=ncread(data,'u');u=u(:,:,:,t_star:t_end);u(end+1,:,:,:)=u(end,:,:,:);
% v=ncread(data,'v');v=v(:,:,:,t_star:t_end);v(:,end+1,:,:)=v(:,end,:,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lat_r,lon_r,depth_r]=meshgrid(squeeze(lat(1,:)),squeeze(lon(:,1)),depth);
[lat3,lon3,depth3]=meshgrid(lat2,lon2,depth);
depth3=single(depth3);
depth_r=single(depth_r);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=datenum(2008,07,19,0,0,0);
n2=(datenum(2008,07,28,0,0,0):1/24:datenum(2008,07,30,23,0,0))';
time=(24.*(n2-datenum(2000,01,01)));
t_star=(n2(1)-n)*24+1;
t_end=(n2(end)-n)*24+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mask_rho2=mask_rho;
mask_rho2(mask_rho==0)=1;
mask_rho2(mask_rho==1)=0;
mask_rho2=interp2(squeeze(lat_r(:,:,1)),squeeze(lon_r(:,:,1)),mask_rho2,squeeze(lat3(:,:,1)),squeeze(lon3(:,:,1)));

for i=1:t_end-t_star+1
    i
    u2(:,:,:,i)=interp3(lat_r,lon_r,depth_r,squeeze(u(:,:,:,i)),lat3,lon3,depth3);
    v2(:,:,:,i)=interp3(lat_r,lon_r,depth_r,squeeze(v(:,:,:,i)),lat3,lon3,depth3);
    w2(:,:,:,i)=interp3(lat_r,lon_r,depth_r,squeeze(w(:,:,:,i)),lat3,lon3,depth3);
end
lon=lon2';
lat=lat2';
% u2=roundn(u2,-3);
% v2=roundn(v2,-3);
%v2(:,:,i)=interp2(lat,lon,squeeze(v(:,:,20,i)),lat3,lon3);
%%
film='myncfile3.nc';
nc=netcdf([film],'clobber');
%result = redef(nc);

nc('lon') = length(lon(:));
nc('lat') = length(lat(:));
nc('time') = length(time);
nc('depth') =length(depth);

% nc('time').Datatype='Double';

nc{'lon'}=ncdouble('lon') ;
nc{'lat'}=ncdouble('lat') ;
nc{'time'}= ncdouble('time');
nc{'depth'}= ncdouble('depth');
nc{'water_u'}=ncdouble('time', 'depth', 'lat', 'lon');
%nc{'water_v'}=ncdouble('time', 'depth', 'lat', 'lon');
nc{'water_v'}=ncdouble('time', 'depth', 'lat', 'lon');
%nc{'water_w'}=ncdouble('time', 'depth', 'lat', 'lon');
% nc{'surf_el'}=ncshort('time', 'lat', 'lon');
%nc{'salinity'}=ncshort('time', 'depth', 'lat', 'lon');
%nc{'water_tempurature'}=ncdouble('time', 'depth', 'lat', 'lon');
close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
ncwriteatt(film,'water_u','standard_name',['eastward_sea_water_velocity']);
ncwriteatt(film,'water_v','standard_name',['northward_sea_water_velocity']);
ncwriteatt(film,'water_v','_FillValue',[-30000]);
ncwriteatt(film,'water_v','missing_value',[-30000]);
ncwriteatt(film,'water_v','scale_factor',[0.001]);
ncwriteatt(film,'water_u','_FillValue',[-30000]);
ncwriteatt(film,'water_u','missing_value',[-30000]);
ncwriteatt(film,'water_u','scale_factor',[0.001]);

ncwriteatt(film,'time','units',['hours since 2000-01-01 00:00:00']);
ncwriteatt(film,'time','time_origin',['2000-01-01 00:00:00']);
ncwriteatt(film,'lat','standard_name',['latitude']);
ncwriteatt(film,'lat','axis',['Y']);
ncwriteatt(film,'lon','standard_name',['longitude']);
ncwriteatt(film,'lon','axis',['X']);ncdisp(film)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncwrite(film,'water_v',v2);
ncwrite(film,'water_u',u2);
ncwrite(film,'time',time);
ncwrite(film,'lon',lon(:));
ncwrite(film,'lat',lat(:));
ncwrite(film,'depth',depth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
film='myncfile2.nc';
nc=netcdf([film],'clobber');
%result = redef(nc);

nc('lon') = length(lon(:));
nc('lat') = length(lat(:));
nc('time') = length(time);
nc('depth') =length(depth);

nc{'lon'}=ncdouble('lon') ;
nc{'lat'}=ncdouble('lat') ;
nc{'time'}= ncdouble('time');
nc{'depth'}= ncdouble('depth');
% nc{'water_u'}=ncdouble('time', 'depth', 'lat', 'lon');
%nc{'water_v'}=ncdouble('time', 'depth', 'lat', 'lon');
nc{'water_w'}=ncdouble('time', 'depth', 'lat', 'lon');
nc{'mask'}=ncdouble('lat', 'lon');
%nc{'water_w'}=ncdouble('time', 'depth', 'lat', 'lon');
% nc{'surf_el'}=ncshort('time', 'lat', 'lon');
%nc{'salinity'}=ncshort('time', 'depth', 'lat', 'lon');
%nc{'water_tempurature'}=ncdouble('time', 'depth', 'lat', 'lon');
close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncwriteatt(film,'water_w','standard_name',['upward_sea_water_velocity']);
ncwriteatt(film,'water_w','_FillValue',[-30000]);
ncwriteatt(film,'water_w','missing_value',[-30000]);
ncwriteatt(film,'water_w','scale_factor',[0.001]);
ncwriteatt(film,'mask','standard_name',['land_binary_mask']);
ncwriteatt(film,'mask','option_1',['land']);
ncwriteatt(film,'mask','option_0',['water']);

ncwriteatt(film,'time','units',['hours since 2000-01-01 00:00:00']);
ncwriteatt(film,'time','time_origin',['2000-01-01 00:00:00']);
ncwriteatt(film,'lat','standard_name',['latitude']);
ncwriteatt(film,'lat','axis',['Y']);
ncwriteatt(film,'lon','standard_name',['longitude']);
ncwriteatt(film,'lon','axis',['X']);ncdisp(film)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ncwrite(film,'water_v',v2);
% ncwrite(film,'water_u',u2);
ncwrite(film,'water_w',w2);
ncwrite(film,'mask',mask_rho2);
ncwrite(film,'time',time);
ncwrite(film,'lon',lon(:));
ncwrite(film,'lat',lat(:));
ncwrite(film,'depth',depth);
% ncdisp(film)