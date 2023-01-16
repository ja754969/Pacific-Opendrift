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
import os

# Boundary dates
start_date = datetime(2020, 1, 1)
end_date = datetime(2020, 12, 31)
days_diff = end_date - start_date
num_days = days_diff.days+1
print('From '+str({start_date})+' to '+str({end_date})+' : '+str(num_days)+' days')
# print(num_days)

latseed = 18.375;   lonseed = 122.875 # Kuroshio upstream
saving_dir = 'D:/Data/used_by_projects/Pacific-Opendrift/nc_output/Kuroshio_upstream_path'
# latseed= 21.125;   lonseed= 122.375 # Kuroshio at Luzon
# saving_dir = 'D:/Data/used_by_projects/Pacific-Opendrift/nc_output/Kuroshio_Luzon_path'
num_of_simulation_days = 150
ntraj = 1000 # number of trajectory
seed_radius = 100 # km
saving_path_1 = f'{saving_dir}/number_of_trajectory_{ntraj:0.0f}'
saving_path = f'{saving_path_1}/seed_radius_km_{seed_radius:0.0f}/init_lat_{latseed}_lon_{lonseed}'
is_exist = os.path.exists(saving_path)
if is_exist is False:
    os.makedirs(saving_path)
else:
    print('The directory has already existed.')
    pass
print(saving_path)

final_date = end_date + timedelta(days = num_of_simulation_days)

for i in range(0, num_days):
    try:
        o = RadionuclideDrift(loglevel=20, seed=20)  # Set loglevel to 0 for debug information

        # Read Files
        for year_i in range(start_date.year,final_date.year+1):
            file_name_year_i_1 = f'D:/Data/used_by_projects/Pacific-Opendrift/CMEMS/my_cmems_{year_i}_1.nc'
            reader_ncfile_year_i_1 = reader_netCDF_CF_generic.Reader(file_name_year_i_1)
            file_name_year_i_2 = f'D:/Data/used_by_projects/Pacific-Opendrift/CMEMS/my_cmems_{year_i}_2.nc'
            reader_ncfile_year_i_2 = reader_netCDF_CF_generic.Reader(file_name_year_i_2)
            o.add_reader([reader_ncfile_year_i_1,reader_ncfile_year_i_2],
                                variables=['sea_floor_depth_below_sea_level','x_sea_water_velocity', 'y_sea_water_velocity','land_binary_mask'])
        

        # # Adjusting some configuration
        # # o.set_config()
        o.set_config('radionuclide:transfer_setup','custom')
        o.set_config('general:use_auto_landmask', False)  # Disabling the automatic GSHHG landmask
        o.set_config('general:coastline_action', 'stranding')
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
        td=start_date+timedelta(days=i)
        time_i = datetime(td.year, td.month, td.day, 0)

        output_filename = f"{saving_path}/Opendrift_{num_of_simulation_days:02.0f}days_Kuroshio_upstream_path_{td.year:04.0f}_{td.month:02.0f}_{td.day:02.0f}.nc"
        # output_filename = f"{saving_path}/Opendrift_{num_of_simulation_days:02.0f}days_Kuroshio_Luzon_path_{td.year:04.0f}_{td.month:02.0f}_{td.day:02.0f}.nc"
    
        
        iniz=np.linspace(0.,0.,ntraj) # seeding the radionuclides in the upper 0m (surface) 
        terminal_velocity = 0 # Neutral particles (No Rising, no sinking)

        o.seed_elements(lonseed, latseed, z=iniz, radius=seed_radius,number=ntraj,time=time_i)
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
        o.run(steps=num_of_simulation_days, time_step=timedelta(days=1), time_step_output=timedelta(days=1),outfile=output_filename)
        # o.run(steps=90, time_step=timedelta(days=1), time_step_output=timedelta(days=1),outfile='./nc_output/NECB_opnedrift_radionuclides_output_test.nc')
        print("Saving ",output_filename, " completed.")
    except TypeError or ValueError:
         # 👇️ this runs
        print('The specified type or value is not correct.')
        pass  # 👈️ ignore the error
