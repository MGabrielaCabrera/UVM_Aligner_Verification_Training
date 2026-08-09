`ifndef CFS_ALGN_TEST_RANDOM_SV
    `define CFS_ALGN_TEST_RANDOM_SV

class cfs_algn_test_random extends cfs_algn_test_base;

        // Mandatory for all the test classes to have the UVM macro to register
        // the class with the factory, enabling the core UVM infrastructure 
        // to work with your component.
        // The argument is the name of the class
        `uvm_component_utils(cfs_algn_test_random)

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

            repeat(4) begin
                cfs_md_sequence_simple_master seq_simple = cfs_md_sequence_simple_master::type_id::create("seq_simple");
                seq_simple.set_sequencer(env.md_rx_agent.sequencer); // This is needed because in the randomisation we are using 
                                                                     // get_data_width() from the sequencer, so we need to set the
                                                                     // sequencer before the randomization.

                void'(seq_simple.randomize());

                seq_simple.start(env.md_rx_agent.sequencer);
            end
            
            #(100ns);
 

            `uvm_info("DEBUG", "End of test", UVM_LOW);

            phase.drop_objection(this, "TEST_DONE");
        endtask
     endclass

`endif