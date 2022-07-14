function data_regrid = regrid_data(lat,lon,data,lat_to_be,lon_to_be)
    %REGRID_DATA Summary of this function goes here
    %   Detailed explanation goes here
    %%
    lat_length = size(lat,1);
    lon_length = size(lon,2);

    lat_to_be_length = size(lat_to_be,1);
    lon_to_be_length = size(lon_to_be,2); 
    %%
    lat_grid = abs(mean(diff(lat_to_be(:,1))));
    lon_grid = abs(mean(diff(lon_to_be(1,:))));
    data_regrid = zeros(lat_to_be_length,lon_to_be_length);
    data_regrid_count = zeros(lat_to_be_length,lon_to_be_length);
    for i = 1:lat_to_be_length
        for j = 1:lon_to_be_length
            select_ind = find(lat>=lat_to_be(i,j)-lat_grid/2 & ...
                lat<lat_to_be(i,j)+lat_grid/2 & ...
                lon>=lon_to_be(i,j)-lon_grid/2 & ...
                lon<lon_to_be(i,j)+lon_grid/2);
            if isempty(select_ind)==0
                data_regrid(i,j) = mean(data(select_ind),'omitnan');
            else
                data_regrid(i,j) = NaN;
            end
        end
    end

end

