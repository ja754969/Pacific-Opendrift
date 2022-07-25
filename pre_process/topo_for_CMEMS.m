clear;clc;close all
%%
LON_CMEMS = [-179.875:0.25:179.875]';
LAT_CMEMS = [-59.875:0.25:59.875]';
%%
[ELEV_topo,LON_topo,LAT_topo] = m_etopo2([LON_CMEMS(1) LON_CMEMS(end) ...
    LAT_CMEMS(1) LAT_CMEMS(end)]);
ELEV_topo(ELEV_topo>0) = 0;
ELEV_topo = -ELEV_topo;
%%
[LON_grid,LAT_grid] = meshgrid(LON_CMEMS,LAT_CMEMS);
topo = regrid_data(LAT_topo,LON_topo,ELEV_topo,LAT_grid,LON_grid);
%%
save('./data/topo_for_CMEMS.mat','topo','LAT_CMEMS','LON_CMEMS');