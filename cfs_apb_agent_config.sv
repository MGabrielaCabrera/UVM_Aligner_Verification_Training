`ifndef CFS_APB_AGENT_CONFIG_SV
    `define CFS_APB_AGENT_CONFIG_SV

    class cfs_apb_agent_config extends uvm_component;

        // Virtual interface
        local cfs_apb_vif vif;

        // An agent is active when it has a driver, and passive when it doesn't
        // have a driver. This is useful to determine if the agent will drive
        // the signals or just monitor them.
        local uvm_active_passive_enum active_passive;

        `uvm_component_utils(cfs_apb_agent_config)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            active_passive = UVM_ACTIVE; // By default, we set the agent to active
        endfunction

        virtual function cfs_apb_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(cfs_apb_vif value);
            // To prevent it is only set once, we check if it is already set before assigning the value
            if (vif == null) begin
                vif = value;
            end
            else begin
                `uvm_fatal("ALGORITHM_ISSUE", "Trying to set the APB virtual interface more than once")
            end
        endfunction

        virtual function uvm_active_passive_enum get_active_passive();
            return active_passive;  
        endfunction

        virtual function void set_active_passive(uvm_active_passive_enum value);
            active_passive = value;
        endfunction

        // UVM phase (it can be implemented because it's a uvm_component)
        virtual function void start_of_simulation_phase(uvm_phase phase);
            super.start_of_simulation_phase(phase);
            // We can also check if the virtual interface has been set before the start of the simulation
            if (vif == null) begin
                `uvm_fatal("ALGORITHM_ISSUE", "APB virtual interface not configured at the start of the simulation phase")
            end
            else begin
                `uvm_info("APB_CONFIG", "APB virtual interface configured successfully", UVM_LOW)
            end
        endfunction

    endclass

`endif