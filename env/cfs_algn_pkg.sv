`ifndef CFS_ALGN_PKG_SV
    `define CFS_ALGN_PKG_SV
    `include "uvm_macros.svh"

    `include "uvm_ext_pkg.sv"
    `include "cfs_apb_pkg.sv"
    `include "cfs_md_pkg.sv"
    `include "cfs_algn_reg_pkg.sv"

    package cfs_algn_pkg;
        import uvm_pkg::*;
        import uvm_ext_pkg::*;
        import cfs_apb_pkg::*;
        import cfs_md_pkg::*;
        import cfs_algn_reg_pkg::*;
        `include "cfs_algn_model.sv"
        `include "cfs_algn_env.sv"

    endpackage
`endif
