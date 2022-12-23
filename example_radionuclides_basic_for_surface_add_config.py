#!/usr/bin/env python
"""
Radionuclides
=============
"""

from opendrift.readers import reader_netCDF_CF_generic, reader_ROMS_native
from opendrift.models.radionuclides import RadionuclideDrift
from opendrift.readers import reader_global_landmask
from datetime import timedelta, datetime
import numpy as np
import netCDF4 as nc
from pprint import pprint


o = RadionuclideDrift(loglevel=20, seed=20)  # Set loglevel to 0 for debug information

# Read Files
# file_name = './pre_process/processed_data/my_cmems_2000_1.nc'
# reader_ncfile = reader_netCDF_CF_generic.Reader(file_name)
# pprint(reader_ncfile)
# o.add_reader([reader_ncfile],variables=['sea_floor_depth_below_sea_level','x_sea_water_velocity', 'y_sea_water_velocity'])
file_name_1 = './pre_process/processed_data/my_cmems_2000_1.nc'
reader_ncfile_1 = reader_netCDF_CF_generic.Reader(file_name_1)
# pprint(reader_ncfile_2)
file_name_2 = './pre_process/processed_data/my_cmems_2000_2.nc'
reader_ncfile_2 = reader_netCDF_CF_generic.Reader(file_name_2)
# pprint(reader_ncfile_2)
file_name_3 = './pre_process/processed_data/my_cmems_2001_1.nc'
reader_ncfile_3 = reader_netCDF_CF_generic.Reader(file_name_3)
# pprint(reader_ncfile_3)
file_name_4 = './pre_process/processed_data/my_cmems_2001_2.nc'
reader_ncfile_4 = reader_netCDF_CF_generic.Reader(file_name_4)
pprint(reader_ncfile_4)
o.add_reader([reader_ncfile_1,reader_ncfile_2,reader_ncfile_3,reader_ncfile_4],
                        variables=['sea_floor_depth_below_sea_level','x_sea_water_velocity', 'y_sea_water_velocity'])
reader_landmask = reader_global_landmask.Reader(
                       extent=[-180, 0, 180, 63])  # lonmin, latmin, lonmax, latmax
# pprint(reader_landmask)
o.add_reader(reader_landmask, variables='land_binary_mask')

# Adjusting some configuration
# o.set_config()
o.set_config('radionuclide:transfer_setup','custom')
# o.set_config('radionuclide:species:LMM', False)
# o.set_config('environment:constant:ocean_mixed_layer_thickness',50)
# o.set_config('radionuclide:particle_diameter',0.0005)
# o.set_config('radionuclide:species:Polymer', True)
# o.set_config('radionuclide:particle_diameter',5.e-5)  # m
# o.set_config('radionuclide:sediment:resuspension_depth',0)
# o.set_config('radionuclide:sediment:resuspension_depth_uncert',0.1)
# o.set_config('radionuclide:sediment:resuspension_critvel',0.15)
# o.list_configspec()

# SEEDING
td=datetime(2000,6,1,0,0,0)   
time = datetime(td.year, td.month, td.day, 0)
latseed= 25.03;   lonseed= 122.24 # Pacific
# latseed= 25.11;   lonseed= 120.73 # Pacific
# latseed= 24.28;   lonseed= 141.48 # Fukutoku-Okanoba volcano

ntraj=1000 # number of trajectory
iniz=np.linspace(0.,0.,ntraj) # seeding the radionuclides in the upper 0m (surface) 
terminal_velocity = 0 # Neutral particles (No Rising, no sinking)

o.seed_elements(lonseed, latseed, z=iniz, radius=1000,number=ntraj,time=time,density=500)
# o.seed_elements(lonseed, latseed, z=iniz, radius=1000,number=ntraj,time=time,density=0.01,terminal_velocity=terminal_velocity,diameter=0.5,neutral_buoyancy_salinity=36.1,current_drift_factor=0.9)
# o.seed_elements(lonseed, latseed, z=..., radius=...,number=...,time=...,density=..., neutral_buoyancy_salinity=...,specie =...,wind_drift_factor=...,
# current_drift_factor=...,terminal_velocity=...,origin_marker=...)
# seed:origin_marker                  [0] float min: None, max: None [None] An integer kept cons...  
# seed:diameter                       [0.0] float min: None, max: None [m] Seeding value of dia...  
# seed:neutral_buoyancy_salinity      [31.25] float min: None, max: None [[]] Seeding value of neu...  
# seed:density                        [2650.0] float min: None, max: None [kg/m^3] Seeding value of den...  
# seed:specie                         [0] float min: None, max: None [] Seeding value of spe...  


#%%
# Running model (save to nc file)
o.list_configspec()
# o.run(steps=60, time_step=timedelta(days=1), time_step_output=timedelta(days=1))
o.run(steps=180, time_step=timedelta(days=1), time_step_output=timedelta(days=1),outfile='./nc_output/example_radionuclides_add_config_output.nc')
# 
#%%
# Running model (save to image files)
# o.run(steps=360, time_step=timedelta(days=1), time_step_output=timedelta(days=1))
# o.animation(background=['x_sea_water_velocity', 'y_sea_water_velocity'],filename='example_radionuclides_animation.mp4')
# o.plot(linecolor='z',background=['x_sea_water_velocity', 'y_sea_water_velocity'],filename = 'example_radionuclides.jpg')
