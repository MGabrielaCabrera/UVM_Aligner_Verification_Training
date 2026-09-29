`ifndef CFS_MD_DRIVER_SV
    `define CFS_MD_DRIVER_SV

    class cfs_md_driver#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) extends uvm_ext_driver#(.VIRTUAL_INTF(virtual cfs_md_if#(DATA_WIDTH)), .ITEM_DRV(ITEM_DRV));
    
        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_md_agent_config#(DATA_WIDTH) agent_config;

        `uvm_component_param_utils(cfs_md_driver#(DATA_WIDTH, ITEM_DRV))
 
        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        // Temporary solution for the agent.config to be accessible from the monitor class
        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);

            super.agent_config = agent_config;
        endfunction

    endclass
`endif