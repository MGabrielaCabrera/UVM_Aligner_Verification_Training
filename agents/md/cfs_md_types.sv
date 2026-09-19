`ifndef CFS_MD_TYPES_SV
    `define CFS_MD_TYPES_SV

    typedef enum bit {CFS_MD_OKAY = 0, CFS_MD_ERR = 1} cfs_md_response;
    
    typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

`endif