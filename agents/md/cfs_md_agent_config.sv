`ifndef CFS_MD_AGENT_CONFIG_SV
    `define CFS_MD_AGENT_CONFIG_SV

    class cfs_md_agent_config#(int unsigned DATA_WIDTH = 32) extends uvm_component;
        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        // Virtual interface
        local cfs_md_vif vif;

        // An agent is active when it has a driver, and passive when it doesn't
        // have a driver. This is useful to determine if the agent will drive
        // the signals or just monitor them.
        local uvm_active_passive_enum active_passive;

        //Switch to enable the checks
        local bit has_checks;

        //Switch to enable coverage
        local bit has_coverage;

        `uvm_component_utils(cfs_md_agent_config)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            active_passive = UVM_ACTIVE; // By default, we set the agent to active
            has_checks = 1; // By default, we enable the checks
            has_coverage =1;
        endfunction


        virtual function cfs_md_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(cfs_md_vif value);
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

        virtual function bit get_has_coverage();
            return has_coverage;
        endfunction

        virtual function void set_has_coverage(bit value);
            has_coverage = value;
        endfunction


    endclass 
`endif
