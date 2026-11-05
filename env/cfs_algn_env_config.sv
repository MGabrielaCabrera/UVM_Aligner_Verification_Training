`ifndef CFS_ALGN_ENV_CONFIG_SV
    `define CFS_ALGN_ENV_CONFIG_SV

    class cfs_algn_env_config extends uvm_component;

        // Switch to enable checks
        local bit has_checks;

        // Aligner data_width
        local int unsigned algn_data_width;

        `uvm_component_utils(cfs_algn_env_config)

        function new(string name = "", uvm_component parent = null);
            super.new(name, parent);

            has_checks = 1;
            algn_data_width = 8;
        endfunction

        virtual function bit get_has_checks();
            return has_checks;
        endfunction

        virtual function void set_has_checks(bit value);
            has_checks = value;
        endfunction

        virtual function int unsigned get_algn_data_width();
            return algn_data_width;
        endfunction

        virtual function void set_algn_data_width(int unsigned value);
            if(value < 8) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Aligner data width must be greater than or equal to 8. Current value: %0d", value));
            end
            
            if ($countones(value) != 1) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Aligner data width must be a power of 2. Current value: %0d", value));
            end

            algn_data_width = value;
        endfunction

    endclass
`endif