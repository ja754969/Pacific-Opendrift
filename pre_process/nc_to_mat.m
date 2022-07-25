function [U_1,V_1,LAT,LON,time] = nc_to_mat(input_file_for_u,input_file_for_v,output_file)
    % clear;clc;close all
    %%
    % input_file = './data/CMEMS_ADT-current_Jan_to_June_2000.nc';
    ncdisp(input_file_for_u)
    ncdisp(input_file_for_v)
    %%
    % LAT = single(nc_varget(filename,'latitude'));
    % LON = single(nc_varget(filename,'longitude'));
    LAT = nc_varget(input_file_for_u,'latitude');
    LON = nc_varget(input_file_for_u,'longitude');
    U_1 = permute(nc_varget(input_file_for_u,'ugos'),[2 3 1]);
    V_1 = permute(nc_varget(input_file_for_v,'vgos'),[2 3 1]);
    time = days(nc_varget(input_file_for_v,'time'))+datetime(1950,01,01);
    %%
    save(['./data/nc_to_mat/' output_file],'U_1','V_1','LAT','LON','time');
    % save('CMEMS_2000.mat','U_1','V_1','LAT','LON');

end
