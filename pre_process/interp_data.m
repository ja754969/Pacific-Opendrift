function data_interp = interp_data(lat,lon,data,lat_to_be,lon_to_be)
    %INTERP_DATA Summary of this function goes here
    %   "data" : the gridded geophysical data
    %   "lat", "lon" : must be gridded array with same size of "data"
    %   "lat_to_be", "lon_to_be" : must be gridded array (meshgrid)
    %   "lat", "lon" : lower resolution
    %   "lat_to_be", "lon_to_be" : higher resolution
    %%
    size_of_data = size(data);
    
    %% Interpolating the data
    if size_of_data(3) == 1 
        data_interp = interp2(lon,lat,data,lon_to_be,lat_to_be);
    else
        data_interp = [];
        for i = 1:size_of_data(3)
            data_interp(:,:,i) = interp2(lon,lat,data(:,:,i),lon_to_be,lat_to_be);
        end
    end
    
end

