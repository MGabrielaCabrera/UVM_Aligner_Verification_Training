`ifndef CFS_APB_AGENT_SV
    `define CFS_APB_AGENT_SV

    class cfs_apb_agent extends uvm_agent;

        cfs_apb_agent_config agent_config;
        
        // Sequencer handler and driver handler
        cfs_apb_sequencer sequencer;
        cfs_apb_driver driver;

        `uvm_component_utils(cfs_apb_agent)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // We create the configuration object and set it as a child of the agent
            agent_config = cfs_apb_agent_config::type_id::create("agent_config", this);
            
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

            // We connect the driver and the sequencer only if the agent is active
            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
        endfunction


    endclass

`endif