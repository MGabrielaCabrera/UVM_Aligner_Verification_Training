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
        
        // The run phase is where the main stimulus generation and checking happens.
        virtual task run_phase(uvm_phase phase);
            // Objection mechanim to control when the test ends. An objection
            // is like a counter. When you raise an objection, you are 
            // incrementing the counter, and when you drop an objection
            // you are decrementing the counter. When the counter goes
            // to zero, the test ends. 
            // As all the run_phases run in parallel, the UVM needs to know
            // when to finish, this is why the objection are used.
            phase.raise_objection(this, "TEST_DONE");
 
            `uvm_info("DEBUG", "Start of test", UVM_LOW);
            #100ns;
            
            // We create some random items and print them to the console. This is just to show how to
            // use the item class and the randomization. In a real test, you would send these items
            // to the driver to drive the DUT.
            for (int i = 0; i < 10; i++) begin
                cfs_apb_item_drv item = cfs_apb_item_drv::type_id::create("item");
                void'(item.randomize());
                `uvm_info("DEBUG", $sformatf("[Item %0d]: %s", i, item.convert2string()), UVM_LOW);
            end

            `uvm_info("DEBUG", "End of test", UVM_LOW);

            phase.drop_objection(this, "TEST_DONE");
        endtask
     endclass

`endif