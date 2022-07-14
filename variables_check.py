# import numpy as np
# import netCDF4
# rootgrp = netCDF4.Dataset('E:/git-repos/OpenDrift/pre_process/my_cmems_2000.nc', 'r', format='NETCDF4')
# f = open('testoutput.csv','wb')

# # np.set_printoptions(threshold='nan')
# f.write(str(rootgrp.variables['sea_floor_depth_below_sea_level'][:]))
# f.close()
# rootgrp.close()
#%%
# from netCDF4 import Dataset

# nc = Dataset('E:/git-repos/OpenDrift/pre_process/my_cmems_2000.nc')
# my_array = nc.variables['sea_floor_depth_below_sea_level'][:]
#%%
import netCDF4 as nc
import numpy as np
# fn ='E:/git-repos/OpenDrift/pre_process/my_cmems_2000.nc'
fn ='https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be'
ds = nc.Dataset(fn) 
print(ds.variables.keys())

# topo_variable =ds.variables["topo"]
# print(topo_variable[:])
# water_u_variable =ds.variables["water_u"]
# print(water_u_variable[:])
water_u_variable =ds.variables["h"]
print(water_u_variable[:])