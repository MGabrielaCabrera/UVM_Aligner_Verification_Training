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

            uvm_status_e status;
            uvm_reg_data_t data;

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

            // Writing in the CTRL register
            begin
                // env.model.reg_block.CTRL.SIZE.set(2);
                // env.model.reg_block.CTRL.OFFSET.set(2);
                // env.model.reg_block.CTRL.update(status);
                
                void'(env.model.reg_block.CTRL.randomize());
                env.model.reg_block.CTRL.update(status);

                // env.model.reg_block.CTRL.write(status, 32'h00000202);

                /*cfs_apb_sequence_simple seq_simple = cfs_apb_sequence_simple::type_id::create("seq_simple");

                void'(seq_simple.randomize() with {
                    item.addr == 'h0;
                    item.dir  == CFS_APB_WRITE;
                    item.data == 32'h00000200;
                });

                seq_simple.start(env.apb_agent.sequencer);*/
            end

            //Read from CTRL register
            begin

                env.model.reg_block.CTRL.read(status, data);

                /*cfs_apb_sequence_simple seq_simple = cfs_apb_sequence_simple::type_id::create("seq_simple");

                void'(seq_simple.randomize() with {
                    item.addr == 'h0;
                    item.dir  == CFS_APB_READ;
                });

                seq_simple.start(env.apb_agent.sequencer);*/
            end      
          
            #100ns;

            `uvm_info("DEBUG", "End of test", UVM_LOW);

            phase.drop_objection(this, "TEST_DONE");
        endtask
     endclass

`endif