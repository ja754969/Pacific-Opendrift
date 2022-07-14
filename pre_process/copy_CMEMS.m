clear all
load('CMEMS_1993_2006.mat')
%%
n=datenum(1993,01,01,0,0,0):1:datenum(2006,12,31,0,0,0);
n2=(datenum(2000,01,01,0,0,0):1:datenum(2006,12,31,0,0,0))';

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
film='my_cmems_2000_2006.nc';
nc=netcdf([film],'clobber');
nc('lon') = length(LON(:));
nc('lat') = length(LAT(:));
nc('time') = length(time);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'lon'}=ncdouble('lon') ;
nc{'lon'}.standard_name = ncchar('longitude');
nc{'lon'}.standard_name = 'longitude';
nc{'lon'}.axis = ncchar('X');
nc{'lon'}.axis = 'X';

nc{'lat'}=ncdouble('lat') ;
nc{'lat'}.standard_name = ncchar('latitude');
nc{'lat'}.standard_name = 'latitude';
nc{'lat'}.axis = ncchar('Y');
nc{'lat'}.axis = 'Y';

nc{'time'}= ncdouble('time');
nc{'time'}.units = ncchar('hours since 1990-01-01 00:00:00');
nc{'time'}.units = 'hours since 1990-01-01 00:00:00';
nc{'time'}.time_origin = ncchar('1990-01-01 00:00:00');
nc{'time'}.time_origin = '1990-01-01 00:00:00';
nc{'water_v'}=ncdouble('time', 'lat', 'lon');
nc{'water_v'}.standard_name = ncchar('northward_sea_water_velocity');
nc{'water_v'}.standard_name = 'northward_sea_water_velocity';
nc{'water_v'}.scale_factor = 0.001;
nc{'water_v'}.missing_value = -30000;
close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ncwriteatt(film,'water_u','standard_name',['eastward_sea_water_velocity']);
% ncwriteatt(film,'water_v','standard_name',['northward_sea_water_velocity']);
% ncwriteatt(film,'water_v','_FillValue',[-30000]);
% ncwriteatt(film,'water_v','missing_value',[-30000]);
% ncwriteatt(film,'water_u','_FillValue',[-30000]);
% ncwriteatt(film,'water_u','missing_value',[-30000]);
% ncwriteatt(film,'water_u','scale_factor',[0.001]);
% ncwriteatt(film,'water_v','scale_factor',[0.001]);
% ncwriteatt(film,'time','units',['hours since 1990-01-01 00:00:00']);
% ncwriteatt(film,'time','time_origin',['1990-01-01 00:00:00']);
% ncwriteatt(film,'lat','standard_name',['latitude']);
% ncwriteatt(film,'lat','axis',['Y']);
% ncwriteatt(film,'lon','standard_name',['longitude']);
% ncwriteatt(film,'lon','axis',['X']);

ncdisp(film)
ncwrite(film,'water_v',V_3);
ncwrite(film,'time',time);
ncwrite(film,'lon',LON);
ncwrite(film,'lat',LAT);
clear nc film
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
film2='my_cmems2_2000_2006.nc';
nc=netcdf([film2],'clobber');
nc('lon') = length(LON(:));
nc('lat') = length(LAT(:));
nc('time') = length(time);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'lon'}=ncdouble('lon') ;
nc{'lon'}.standard_name = ncchar('longitude');
nc{'lon'}.standard_name = 'longitude';
nc{'lon'}.axis = ncchar('X');
nc{'lon'}.axis = 'X';

nc{'lat'}=ncdouble('lat') ;
nc{'lat'}.standard_name = ncchar('latitude');
nc{'lat'}.standard_name = 'latitude';
nc{'lat'}.axis = ncchar('Y');
nc{'lat'}.axis = 'Y';

nc{'time'}= ncdouble('time');
nc{'time'}.units = ncchar('hours since 1990-01-01 00:00:00');
nc{'time'}.units = 'hours since 1990-01-01 00:00:00';
nc{'time'}.time_origin = ncchar('1990-01-01 00:00:00');
nc{'time'}.time_origin = '1990-01-01 00:00:00';

nc{'water_u'}=ncdouble('time', 'lat', 'lon');
nc{'water_u'}.standard_name = ncchar('eastward_sea_water_velocity');
nc{'water_u'}.standard_name = 'eastward_sea_water_velocity';
nc{'water_u'}.scale_factor = 0.001;
nc{'water_u'}.missing_value = -30000;
close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncdisp(film2)
ncwrite(film2,'water_u',U_3);
ncwrite(film2,'time',time);
ncwrite(film2,'lon',LON);
ncwrite(film2,'lat',LAT);
