`ifndef CFS_ALGN_TEST_REG_ACCESS_SV
    `define CFS_ALGN_TEST_REG_ACCESS_SV
     class cfs_algn_test_reg_access extends cfs_algn_test_base;

        // Mandatory for all the test classes to have the UVM macro to register
        // the class with the factory, enabling the core UVM infrastructure 
        // to work with your component.
        // The argument is the name of the class
        `uvm_component_utils(cfs_algn_test_reg_access)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction
     endclass
`endif