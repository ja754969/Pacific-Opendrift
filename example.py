from opendrift.models.oceandrift import OceanDrift
from opendrift.models.leeway import Leeway
from opendrift.models.openoil import OpenOil
from datetime import timedelta
o = OpenOil(loglevel=0)
from opendrift.readers import reader_netCDF_CF_generic
reader_norkyst = reader_netCDF_CF_generic.Reader('./examples/opendrift/tests/test_data/16Nov2015_NorKyst_z_surface/norkyst800_subset_16Nov2015.nc')
reader_norkyst = reader_netCDF_CF_generic.Reader(
    'https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be')
print(reader_norkyst)

from pprint import pprint
pprint(OpenOil.required_variables)
from opendrift.readers import reader_global_landmask
reader_landmask = reader_global_landmask.Reader(
                       extent=[2, 59, 8, 63])  # lonmin, latmin, lonmax, latmax
o.add_reader([reader_landmask, reader_norkyst])
o.add_readers_from_list(['somelocalfile.nc',
       'https://thredds.met.no/thredds/dodsC/sea/norkyst800m/1h/aggregate_be',
       'https://thredds.met.no/thredds/dodsC/sea/nordic4km/zdepths1h/aggregate_be'])
print(o)
from numpy import random
o.seed_elements(lon=4.3, lat=60, number=100, radius=1000,
                density=random.uniform(880, 920, 100),
                time=reader_norkyst.start_time)
o.elements_scheduled
o.seed_cone(lon=[4, 4.8], lat=[60, 61], number=1000, radius=[0, 5000],
            time=[reader_norkyst.start_time, reader_norkyst.start_time+timedelta(hours=5)])
o.list_configspec()
o.set_config('seed:wind_drift_factor', .02)
wind_drift_factor = o.get_config('seed:wind_drift_factor')
o.plot(linecolor='z')
o.plot(background=['x_sea_water_velocity', 'y_sea_water_velocity'])
o.animation(compare=o2, legend=['Current + 3 % wind drift', 'Current only'])