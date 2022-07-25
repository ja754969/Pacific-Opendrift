# -*- coding: utf-8 -*-
"""
Created on Fri Apr 22 00:30:22 2022

@author: S607
"""

from datetime import datetime, timedelta
from opendrift.models.oceandrift import OceanDrift
#from opendrift.models.oceandrift import OpenOil
from opendrift.readers import reader_global_landmask
import numpy as np
from opendrift.readers.reader_netCDF_CF_generic import Reader
from opendrift.readers.basereader import BaseReader, StructuredReader
import xarray as xr
from pprint import pprint



# from pprint import pprint
# pprint(OceanDrift.required_variables)

# Basic ocean drift module: current + 2% of wind
o = OceanDrift(loglevel=0)
reader_hycom = Reader('E:/git-repos/OpenDrift/pre_process/my_cmems_2000.nc')
print(reader_hycom)
pprint(OceanDrift.required_variables)
# %%
#reader_hycom2 = Reader('myncfile2.nc')
#reader_wind = Reader('windfilm.nc')
#o.set_config('drift:vertical_mixing', True)
#from opendrift.readers import reader_global_landmask
#reader_landmask = reader_global_landmask.Reader(
#                       extent=[24, 121, 27,124]) 
o.add_reader(reader_hycom,variables=['sea_floor_depth_below_sea_level','x_sea_water_velocity', 'y_sea_water_velocity'])#,,reader_wind,reader_landmask,reader_hycom2
latseed= 25.03;   lonseed= 122.24 # Pacific
o.seed_elements(lat=latseed, lon=lonseed, time=datetime(2000,1,1,0,0,0,0),            #datetime.utcnow()
                number=500, z=np.linspace(0, 0, 500), radius=1000)
# o.run(time_step=timedelta(days=1),
#        duration=timedelta(days=160))#,outfile='test.nc'
o.run(steps=140, time_step=timedelta(days=1), time_step_output=timedelta(days=1),outfile='example_radionuclides_output.nc')
o.animation(background=['x_sea_water_velocity', 'y_sea_water_velocity'],filename='test_uv_output.mp4')
# o.animation(filename='test_uv_output.mp4')
# o.plot(linecolor='z')
o.plot(linecolor='z',background=['x_sea_water_velocity', 'y_sea_water_velocity'])
#o.plot(background=['x_sea_water_velocity', 'y_sea_water_velocity'])