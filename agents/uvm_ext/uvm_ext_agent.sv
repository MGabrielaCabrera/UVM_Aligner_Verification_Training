`ifndef UVM_EXT_AGENT_SV
    `define UVM_EXT_AGENT_SV


    class uvm_ext_agent#(type VIRTUAL_INTF = int, type ITEM_MON = uvm_sequence_item, type ITEM_DRV = uvm_sequence_item) extends uvm_agent implements uvm_ext_reset_handler;
    
        `uvm_component_param_utils(uvm_ext_agent#(VIRTUAL_INTF, ITEM_MON, ITEM_DRV))

        uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;

        uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV) driver;

        uvm_ext_sequencer#(ITEM_DRV) sequencer;

        uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON) monitor;

        uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON) coverage;

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // We create the configuration object and set it as a child of the agent
            agent_config = uvm_ext_agent_config#(VIRTUAL_INTF)::type_id::create("agent_config", this);
            monitor = uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON)::type_id::create("monitor", this);

            if (agent_config.get_has_coverage()) begin
                coverage = uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)::type_id::create("coverage", this);
            end

            // We create the sequencer and set it as a child of the agent
            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver = uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV)::type_id::create("driver", this);
                sequencer = uvm_ext_sequencer#(ITEM_DRV)::type_id::create("sequencer", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            VIRTUAL_INTF vif;
            super.connect_phase(phase);

            if (uvm_config_db#(VIRTUAL_INTF)::get(this, "", "vif", vif) == 0) begin
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
                uvm_ext_reset_handler reset_handler;
                
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
