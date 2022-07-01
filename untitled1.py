# -*- coding: utf-8 -*-
"""
Created on Sat Apr  9 01:12:57 2022

@author: S607
"""
import datetime
from datetime import datetime, timedelta 
from opendrift.models.openoil import OceanDrift
o = OceanDrift()
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.readers.reader_netCDF_CF_generic import Reader


from opendrift.readers import reader_global_landmask
reader_landmask = reader_global_landmask.Reader(
                       extent=[2, 59, 8, 63])

reader_norkyst = reader_netCDF_CF_generic.Reader('https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be')

# path=("C:\\Users\\S607\\opendrift\\tests\\test_data\\16Nov2015_NorKyst_z_surface\\")
# reader_norkyst = reader_netCDF_CF_generic.Reader(path+'norkyst800_subset_16Nov2015.nc')
# reader_norkyst.plot()

o.add_reader([reader_landmask, reader_norkyst])
o.seed_elements(lon=4.85, lat=60, time=reader_norkyst.start_time, number=1000, radius=1000)

o.run(duration=timedelta(hours=24))
o.plot(linecolor='z')

#o.seed_elements(lon=4.3, lat=60, number=100, radius=1000,
#                 density=random.uniform(880, 920, 100),
#                 time=reader_norkyst.start_time)
#o.seed_elements(lon=4.3, lat=60, number=100, radius=10,
#                time=reader_norkyst.start_time)

# o.add_reader([reader_landmask, reader_norkyst ,reader_arome])#,reader_nordic])

#o.add_readers_from_list(['C:\\Users\\S607\\opendrift\\tests\\test_data\\16Nov2015_NorKyst_z_surface\\norkyst800_subset_16Nov2015.nc',
#      'https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be',
#     'https://thredds.met.no/thredds/dodsC/sea/nordic4km/zdepths1h/aggregate_be'])
# o.seed_cone(lon=[4, 4.8], lat=[60, 61], number=10, radius=[0, 100],
#             time=[reader_norkyst.start_time])#, reader_norkyst.start_time+timedelta(hours=15)])
# #o.seed_elements(lon=4.3, lat=60, time=datetime.datetime(2017,2,20,0 ,0,0))
#o.run(end_time=reader_norkyst.start_time+timedelta(hours=15), time_step=900,
#      time_step_output=3600)