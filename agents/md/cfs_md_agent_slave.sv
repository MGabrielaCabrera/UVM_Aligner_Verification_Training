`ifndef CFS_MD_AGENT_SLAVE_SV
    `define CFS_MD_AGENT_SLAVE_SV
    
    // Implements means that all the functions in the interface class must be implemented
    class cfs_md_agent_slave#(int unsigned DATA_WIDTH = 32) extends cfs_md_agent#(DATA_WIDTH, cfs_md_item_drv_slave);

        `uvm_component_param_utils(cfs_md_agent_slave#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            cfs_md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(cfs_md_agent_config_slave#(DATA_WIDTH)::get_type(),"agent_config", this);
            cfs_md_driver#(cfs_md_item_drv_slave)::type_id::set_inst_override(cfs_md_driver_slave#(DATA_WIDTH)::get_type(),"driver", this);
        endfunction
    endclass
`endif