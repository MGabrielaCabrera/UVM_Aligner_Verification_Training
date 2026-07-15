`ifndef CFS_ALGN_TEST_BASE_SV
    `define CFS_ALGN_TEST_BASE_SV
     class cfs_algn_test_base extends uvm_test;
        cfs_algn_env env;

        // Mandatory for all the test classes to have the UVM macro to register
        // the class with the factory, enabling the core UVM infrastructure 
        // to work with your component.
        // The argument is the name of the class
        `uvm_component_utils(cfs_algn_test_base)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        // The build phase is where you create and configure the components
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = cfs_algn_env::type_id::create("env", this);
        endfunction
     endclass
`endif