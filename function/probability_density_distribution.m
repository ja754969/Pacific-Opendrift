function [lon,lat,pd_distribution] = ...
    probability_density_distribution(LON_lim,LAT_lim,...
    spatial_resolution,lon_input,lat_input)
%PROBABILITY_DENSITY_DISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here
    %%
    lon = LON_lim(1):spatial_resolution:LON_lim(end);
    lat = LAT_lim(1):spatial_resolution:LAT_lim(end);
    pd_distribution = zeros(length(lat),length(lon));
    %%
    lon_length = length(lon_input);
    lat_length = length(lat_input);
    
    if lon_length == lat_length
        for i = 1:lon_length
            lon_diff = lon_input(i)-lon;
            [min_lon_diff,min_lon_diff_ind] = min(abs(lon_diff));
            lat_diff = lat_input(i)-lat;
            [min_lat_diff,min_lat_diff_ind] = min(abs(lat_diff));
            pd_distribution(min_lat_diff_ind,min_lon_diff_ind) = ...
                pd_distribution(min_lat_diff_ind,min_lon_diff_ind)+1;
        end
    else
        disp('The length of latitude and longitude must be the same.');
    end
    probability_denominator = max(pd_distribution(:));
    pd_distribution = pd_distribution./probability_denominator;
    pd_distribution(pd_distribution==0) = NaN;
end

