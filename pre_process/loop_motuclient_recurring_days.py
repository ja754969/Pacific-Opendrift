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
out_dir = f'{os.getcwd()}/data_MOTU'

# product and dataset IDs
serviceID = "ARCTIC_MULTIYEAR_PHY_002_003"
productID = "cmems_mod_arc_phy_my_topaz4_P1D-m"

#coordinates
lon = (46.94 , 74.32)
lat = (69.04 , 79.73)

# variable 
var = "--variable siconc "

# Boundary dates
start_date = datetime(2000, 1, 1, 12)
end_date = datetime(2020, 12, 31, 12)
delta_t=timedelta(days=13)
# Download loop 
while start_date <= end_date:

    # Output filename
    out_name = f"ARC_January_{start_date.year}.nc"
    
    if start_date.month == 1:
        # Motuclient command line
        query = f'python -m motuclient --motu https://my.cmems-du.eu/motu-web/Motu \
        --service-id {serviceID}-TDS --product-id {productID} \
        --longitude-min {lon[0]} --longitude-max {lon[1]} --latitude-min {lat[0]} --latitude-max {lat[1]}\
        --date-min "{start_date}" --date-max "{start_date+delta_t}" \
        {var} \
        --out-dir {out_dir} --out-name {out_name} --user {USERNAME} --pwd {PASSWORD}'    

        # query = f'python -m motuclient --motu https://my.cmems-du.eu/motu-web/Motu \
        #     --service-id SEALEVEL_GLO_PHY_L4_MY_008_047-TDS --product-id cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D \
        #     --longitude-min -179.875 --longitude-max 179.875 --latitude-min -59.875 --latitude-max 59.875 \
        #     --date-min "2009-01-01 00:00:00" --date-max "2009-06-30 23:59:59" --variable ugos \
        #     --out-dir <OUTPUT_DIRECTORY> --out-name <OUTPUT_FILENAME> --user <USERNAME> --pwd <PASSWORD>'    
    
        print(f"============== Running request on {start_date} ==============")
        print(query[:-30])
        
        # Run the command
        os.system(query)
        
        start_date=start_date.replace(year=start_date.year+1)
        
print(f"============== Download completed! All files are in your directory {out_dir} ==============")