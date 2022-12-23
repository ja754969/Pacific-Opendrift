"""
This script allows to download a recurring period over several years via the Copernicus Marine MOTU Client
"""

import os
from datetime import datetime, timedelta
import getpass
import xarray as xr

# Copernicus Marine Credentials 
USERNAME = input('Enter your username: ')
# PASSWORD = getpass.getpass("Enter your password: ")
PASSWORD = input("Enter your password: ")
# Work directory
# out_dir = f'{os.getcwd()}/data_CMEMS'
out_dir = f'D:/Data/origin/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D/half-year_uv'

# product and dataset IDs
serviceID = "SEALEVEL_GLO_PHY_L4_MY_008_047-TDS"
productID = "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D"

#coordinates
lon = (-179.875 , 179.875)
lat = (-59.875 , 59.875)

# variable 
var_u = "ugos"
var_v = "vgos"

first_year = 1999
last_year = 1999
selected_year = range(first_year,last_year+1)
# print(selected_year)

for year_i in selected_year:
        # Boundary dates
        start_date = datetime(year_i, 7, 1, 0,0,0)
        end_date = datetime(year_i, 12, 31, 23, 59, 59)

        # # Output filename: ugos
        # out_name_u = f"CMEMS_ADT_u-current_Jul_to_Dec_{year_i}.nc"

        # query_u = f'python -m motuclient --motu https://my.cmems-du.eu/motu-web/Motu \
        #         --service-id {serviceID} --product-id {productID} \
        #         --longitude-min {lon[0]} --longitude-max {lon[1]} --latitude-min {lat[0]} --latitude-max {lat[1]} \
        #         --date-min {start_date} --date-max {end_date} --variable {var_u} \
        #         --out-dir {out_dir} --out-name {out_name_u} --user {USERNAME} --pwd {PASSWORD}'    
                
        # print(f"============== Running request on {start_date} ==============")
        # print(query_u[:-30])
                
        # # Run the command
        # os.system(query_u)

        # Output filename: vgos
        out_name_v = f"CMEMS_ADT_v-current_Jul_to_Dec_{year_i}.nc"

        query_v = f'python -m motuclient --motu https://my.cmems-du.eu/motu-web/Motu \
                --service-id {serviceID} --product-id {productID} \
                --longitude-min {lon[0]} --longitude-max {lon[1]} --latitude-min {lat[0]} --latitude-max {lat[1]} \
                --date-min {start_date} --date-max {end_date} --variable {var_v} \
                --out-dir {out_dir} --out-name {out_name_v} --user {USERNAME} --pwd {PASSWORD}'    
                
        print(f"============== Running request on {start_date} ==============")
        print(query_v[:-30])
                
        # Run the command
        os.system(query_v)
                
        print(f"============== Download completed! All files are in your directory {out_dir} ==============")
