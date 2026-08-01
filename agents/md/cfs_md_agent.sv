`ifndef CFS_MD_AGENT_SV
    `define CFS_MD_AGENT_SV
    
    // Implements means that all the functions in the interface class must be implemented
    class cfs_md_agent#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) extends uvm_agent implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        cfs_md_agent_config#(DATA_WIDTH) agent_config;

        cfs_md_sequencer#(ITEM_DRV) sequencer;

        `uvm_component_param_utils(cfs_md_agent#(DATA_WIDTH, ITEM_DRV))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // We create the configuration object and set it as a child of the agent
            agent_config = cfs_md_agent_config#(DATA_WIDTH)::type_id::create("agent_config", this);

            // We create the sequencer and set it as a child of the agent
            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                sequencer = cfs_md_sequencer#(ITEM_DRV)::type_id::create("sequencer", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            cfs_md_vif vif;
            super.connect_phase(phase);

            if (uvm_config_db#(cfs_md_vif)::get(this, "", "vif", vif) == 0) begin
                `uvm_fatal("CFS_MD_NO_VIF", "Could not get from the database the MD virtual interface")
            end
            else begin
                agent_config.set_vif(vif);
            end

        endfunction
       
        virtual function void handler_reset(uvm_phase phase);
            uvm_component children[$];
            
            // The children are the atributes created in the agent hierarchy using "this" as parent
            get_children(children);
            
            foreach(children[idx]) begin
                cfs_md_reset_handler reset_handler;
                
                // If the chindren can be casted to cfs_md_reset_handler
                if($cast(reset_handler, children[idx])) begin
                    // Each children execute their handler_reset method
                    reset_handler.handler_reset(phase);
                end
            end

        endfunction

        // Task for waiting the reset to start (asynchronous)
        virtual task wait_reset_start();
            agent_config.wait_reset_start();
        endtask

        // Task for waiting the reset to end (synchronous)
        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual task run_phase(uvm_phase phase);
            forever begin
                wait_reset_start();
                handler_reset(phase);
                wait_reset_end();
            end
        endtask
    endclass

`endif
