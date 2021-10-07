
if [ "$add_sample_data" = true ];
then
    write_log "Inserting sample datasets..."
    geonature db upgrade geonature-samples@head

    write_log "Inserting sample dataset of taxons for taxonomic schema..."
    geonature db upgrade taxonomie_taxons_example@head
fi

if [ "$install_sig_layers" = true ];
then
    geonature db upgrade ref_geo_fr_departments -x data-directory=tmp
    geonature db upgrade ref_geo_fr_municipalities -x data-directory=tmp
fi

if [ "$install_grid_layer" = true ];
then
    geonature db upgrade ref_geo_inpn_grids_1 -x data-directory=tmp
    geonature db upgrade ref_geo_inpn_grids_5 -x data-directory=tmp
    geonature db upgrade ref_geo_inpn_grids_10 -x data-directory=tmp
fi

if  [ "$install_default_dem" = true ];
then
    geonature db upgrade ign_bd_alti@head -x local-srid=$srid_local -x data-directory=tmp
    if [ "$vectorise_dem" = true ];
    then
        geonature db upgrade ign_bd_alti_vector@head -x data-directory=tmp
    fi
fi
