`ifndef CFS_MD_AGENT_MASTER_SV
    `define CFS_MD_AGENT_MASTER_SV
    
    // Implements means that all the functions in the interface class must be implemented
    class cfs_md_agent_master#(int unsigned DATA_WIDTH = 32) extends cfs_md_agent#(DATA_WIDTH);

        `uvm_component_param_utils(cfs_md_agent_master#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            cfs_md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(cfs_md_agent_config_master#(DATA_WIDTH)::get_type(),"agent_config", this);
            cfs_md_sequencer#(cfs_md_item_drv_master)::type_id::set_inst_override(cfs_md_sequencer_master#(DATA_WIDTH)::get_type(),"sequencer", this);
            cfs_md_driver#(cfs_md_item_drv_master)::type_id::set_inst_override(cfs_md_driver_master#(DATA_WIDTH)::get_type(),"driver", this);
        endfunction
    endclass
`endif