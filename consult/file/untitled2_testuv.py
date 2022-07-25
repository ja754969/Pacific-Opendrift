# -*- coding: utf-8 -*-
"""
Created on Fri Apr 22 00:30:22 2022

@author: S607
"""

from datetime import datetime, timedelta
from opendrift.models.oceandrift import OceanDrift
#from opendrift.models.oceandrift import OpenOil
import numpy as np
from opendrift.readers.reader_netCDF_CF_generic import Reader
from opendrift.readers.basereader import BaseReader, StructuredReader
import xarray as xr



# from pprint import pprint
# pprint(OceanDrift.required_variables)

# Basic ocean drift module: current + 2% of wind
o = OceanDrift(loglevel=0)
reader_hycom = Reader('myncfile.nc')
#reader_hycom2 = Reader('myncfile2.nc')
#reader_wind = Reader('windfilm.nc')
#o.set_config('drift:vertical_mixing', True)
#from opendrift.readers import reader_global_landmask
#reader_landmask = reader_global_landmask.Reader(
#                       extent=[24, 121, 27,124]) 
o.add_reader([reader_hycom])#,,reader_wind,reader_landmask,reader_hycom2
o.seed_elements(lat=25, lon=122, time=datetime(2008,7,28,12,0,0,0),            #datetime.utcnow()
                number=500, z=np.linspace(0, 0, 500), radius=10000)
o.run(time_step=timedelta(minutes=60),
       duration=timedelta(days=2))#,outfile='test.nc'
o.animation(background=['x_sea_water_velocity', 'y_sea_water_velocity'],filename='HYCOM_oil.mp4')
o.plot(linecolor='z',background=['x_sea_water_velocity', 'y_sea_water_velocity'])
#o.plot(background=['x_sea_water_velocity', 'y_sea_water_velocity'])