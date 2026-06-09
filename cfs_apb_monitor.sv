`ifndef CFS_APB_MONITOR_SV
    `define CFS_APB_MONITOR_SV

    class cfs_apb_monitor extends uvm_monitor;

        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_apb_agent_config agent_config;

        `uvm_component_utils(cfs_apb_monitor)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction
        
        virtual task run_phase(uvm_phase phase);
            collect_transactions();
        endtask

        protected virtual task collect_transactions();
        endtask
    endclass
`endif