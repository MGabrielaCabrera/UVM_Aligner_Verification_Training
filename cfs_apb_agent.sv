`ifndef CFS_APB_AGENT_SV
    `define CFS_APB_AGENT_SV
    
    // Implements means that all the functions in the interface class must be implemented
    class cfs_apb_agent extends uvm_agent implements cfs_apb_reset_handler;

        cfs_apb_agent_config agent_config;
        
        // Sequencer handler and driver handler
        cfs_apb_sequencer sequencer;
        cfs_apb_driver driver;

        // Monitor handler
        cfs_apb_monitor monitor;

        // Coverage handler
        cfs_apb_coverage coverage;

        `uvm_component_utils(cfs_apb_agent)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // We create the configuration object and set it as a child of the agent
            agent_config = cfs_apb_agent_config::type_id::create("agent_config", this);
            
            monitor = cfs_apb_monitor::type_id::create("monitor", this);

            if (agent_config.get_has_coverage()) begin
                coverage = cfs_apb_coverage::type_id::create("coverage", this);
            end

            // We check if the agent is active or passive, and we create the sequencer
            // and driver only if it's active
            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                sequencer = cfs_apb_sequencer::type_id::create("sequencer", this);
                driver = cfs_apb_driver::type_id::create("driver", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            cfs_apb_vif vif;
            super.connect_phase(phase);

            if (uvm_config_db#(cfs_apb_vif)::get(this, "", "vif", vif) == 0) begin
                `uvm_fatal("APB_NO_VIF", "Could not get from the database the APB virtual interface")
            end
            else begin
                agent_config.set_vif(vif);
            end

            monitor.agent_config = agent_config;
            
            // Connection between the monitor and the coverage component, if coverage is enabled
            if(agent_config.get_has_coverage()) begin
                monitor.output_port.connect(coverage.port_item);
                coverage.agent_config = agent_config;
            end


            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                
                // We pass the agent config to the driver so it can access the virtual interface
                driver.agent_config = agent_config;
                
                // We connect the driver and the sequencer only if the agent is active
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end


        endfunction
       
        virtual function void handler_reset(uvm_phase phase);
            uvm_component children[$];
            
            // The children are the atributes created in the agent hierarchy using "this" as parent
            get_children(children);
            
            foreach(children[idx]) begin
                cfs_apb_reset_handler reset_handler;
                
                // If the chindren can be casted to cfs_apb_reset_handler
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