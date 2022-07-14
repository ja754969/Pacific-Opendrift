clear;clc;close all
%%
filename = './data/CMEMS_ADT-current_Jan_to_June_2000.nc';
ncdisp(filename)
%%
% LAT = single(nc_varget(filename,'latitude'));
% LON = single(nc_varget(filename,'longitude'));
LAT = nc_varget(filename,'latitude');
LON = nc_varget(filename,'longitude');
U_1 = permute(nc_varget(filename,'ugos'),[2 3 1]);
V_1 = permute(nc_varget(filename,'vgos'),[2 3 1]);
%%
save('CMEMS_2000.mat','U_1','V_1','LAT','LON');
