`ifndef CFS_APB_AGENT_SV
    `define CFS_APB_AGENT_SV

    class cfs_apb_agent extends uvm_agent;
        `uvm_component_utils(cfs_apb_agent)


        cfs_apb_agent_config agent_config;


        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // We create the configuration object and set it as a child of the agent
            agent_config = cfs_apb_agent_config::type_id::create("agent_config", this);
        endfunction

    endclass

`endif