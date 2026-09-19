`ifndef CFS_MD_AGENT_CONFIG_SV
    `define CFS_MD_AGENT_CONFIG_SV

    class cfs_md_agent_config#(int unsigned DATA_WIDTH = 32) extends uvm_ext_agent_config#(.VIRTUAL_INTF(virtual cfs_md_if#(DATA_WIDTH)));

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        // Delay used when detecting start of an MD transaction in the monitor
        local time sample_delay_start_tr;

        // Number of clock cycles whoch an MD transfer is considered
        // stuck and an error is triggered
        local int unsigned stuck_threshold;

        `uvm_component_utils(cfs_md_agent_config)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            sample_delay_start_tr = 1ns; // By default, we set the sample delay to 0
            stuck_threshold = 1000;
        endfunction

        virtual function void set_vif(cfs_md_vif value);
            super.set_vif(value); // UVM_ext parent
            // Sync with the has_checks of the interface
            set_has_checks(get_has_checks());
        endfunction

        virtual function void set_has_checks(bit value);
            super.set_has_checks(value); // UVM_ext parent

            // Mechanisism to ensure that the has_checks value is syncronize
            // with the interface has_check variable
            if (vif != null) begin
                vif.has_checks = has_checks;
            end
        endfunction

        virtual function void set_stuck_threshold(int unsigned value);
            stuck_threshold = value;
        endfunction

        virtual function int unsigned get_stuck_threshold();
            return stuck_threshold;
        endfunction

        virtual function time get_sample_delay_start_tr();
            return sample_delay_start_tr;
        endfunction

        virtual function void set_sample_delay_start_tr(time value);
            sample_delay_start_tr = value;
        endfunction

        // Task for waiting the reset to start (asynchronous)
        virtual task wait_reset_start();
            if(vif.reset_n !== 0) begin
                @(negedge vif.reset_n);
            end
        endtask

        // Task for waiting the reset to end (synchronous)
        virtual task wait_reset_end();
            while (vif.reset_n == 0) begin
                @(posedge vif.clk);
            end
        endtask

        virtual task run_phase(uvm_phase phase);
            // Mechanism to avoid the user to modify the has_check value from the interface
            forever begin
                @(vif.has_checks);
                
                if(vif.has_checks != get_has_checks()) begin
                    `uvm_error("ALGORITHM_ISSUE", $sformatf("Can not change \"has_checks\" from MD interface directly - use %0s.set_has_checks()", get_full_name()))
                end
            end
        endtask

    endclass 
`endif
