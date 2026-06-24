`ifndef CFS_APB_AGENT_CONFIG_SV
    `define CFS_APB_AGENT_CONFIG_SV

    class cfs_apb_agent_config extends uvm_component;

        // Virtual interface
        local cfs_apb_vif vif;

        // An agent is active when it has a driver, and passive when it doesn't
        // have a driver. This is useful to determine if the agent will drive
        // the signals or just monitor them.
        local uvm_active_passive_enum active_passive;

        //Switch to enable the checks
        local bit has_checks;

        // Number of clock cycles whoch an APB transfer is considered
        // stuck and an error is triggered
        local int unsigned stuck_threshold;

        `uvm_component_utils(cfs_apb_agent_config)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            active_passive = UVM_ACTIVE; // By default, we set the agent to active
            has_checks = 1; // By default, we enable the checks
            stuck_threshold = 1000;
        endfunction

        virtual function cfs_apb_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(cfs_apb_vif value);
            // To prevent it is only set once, we check if it is already set before assigning the value
            if (vif == null) begin
                vif = value;

                // Sync with the has_checks of the interface
                set_has_checks(get_has_checks());
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

        virtual function bit get_has_checks();
            return has_checks;
        endfunction

        virtual function void set_has_checks(bit value);
            has_checks = value;

            // Mechanisism to ensure that the has_checks value is syncronize
            // with the interface has_check variable
            if (vif != null) begin
                vif.has_checks = has_checks;
            end
        endfunction

        virtual function void set_stuck_threshold(int unsigned value);
            if (value <= 2) begin
                `uvm_error("ALGORITHM_ISSUE", "The stuck threshold must be greater than 2 clock cycles")
            end
            stuck_threshold = value;
        endfunction

        virtual function int unsigned get_stuck_threshold();
            return stuck_threshold;
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
    
        virtual task run_phase(uvm_phase phase);
            // Mechanism to avoid the user to modify the has_check value from the interface
            forever begin
                @(vif.has_checks);
                
                if(vif.has_checks != get_has_checks()) begin
                    `uvm_error("ALGORITHM_ISSUE", $sformatf("Can not change \"has_checks\" from APB interface directly - use %0s.set_has_checks()", get_full_name()))
                end
            end
        endtask
    endclass

`endif