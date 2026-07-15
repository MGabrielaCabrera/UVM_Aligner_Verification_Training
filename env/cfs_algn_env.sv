`ifndef CFS_ALGN_ENV_SV
    `define CFS_ALGN_ENV_SV
        class cfs_algn_env extends uvm_env;

            cfs_apb_agent apb_agent;
    
            // Mandatory for all the test classes to have the UVM macro to register
            // the class with the factory, enabling the core UVM infrastructure 
            // to work with your component.
            // The argument is the name of the class
            `uvm_component_utils(cfs_algn_env)
    
            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // We create the APB agent and set it as a child of the environment
                apb_agent = cfs_apb_agent::type_id::create("apb_agent", this);
            endfunction
        endclass
`endif