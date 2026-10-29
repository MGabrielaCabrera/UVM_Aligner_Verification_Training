`ifndef CFS_ALGN_ENV_SV
    `define CFS_ALGN_ENV_SV
        class cfs_algn_env#(int unsigned ALGN_DATA_WIDTH = 32) extends uvm_env;

            cfs_apb_agent apb_agent;

            cfs_md_agent_master#(ALGN_DATA_WIDTH) md_rx_agent;
            cfs_md_agent_slave#(ALGN_DATA_WIDTH) md_tx_agent;

            // Model handler
            cfs_algn_model model;

            // Register predictor handler
            uvm_reg_predictor#(cfs_apb_item_mon) predictor;
    
            // Mandatory for all the test classes to have the UVM macro to register
            // the class with the factory, enabling the core UVM infrastructure 
            // to work with your component.
            // The argument is the name of the class
            `uvm_component_param_utils(cfs_algn_env#(ALGN_DATA_WIDTH))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                // We create the APB agent and set it as a child of the environment
                apb_agent = cfs_apb_agent::type_id::create("apb_agent", this);
            
                // MD agents
                md_rx_agent = cfs_md_agent_master#(ALGN_DATA_WIDTH)::type_id::create("md_rx_agent", this);
                
                // This is normally how the profesional projects works in terms of the agent_configuration. 
                // However for this project, only TX agent would use the agent_config from the database:
                begin
                    cfs_md_agent_config_slave#(ALGN_DATA_WIDTH) agent_config = cfs_md_agent_config_slave#(ALGN_DATA_WIDTH)::type_id::create("agent_config", this);

                    // The struck_threshold is changed. So, the agent_config is set in the database with the new value.
                    agent_config.set_stuck_threshold(100);


                    // In the configuration of the database, it is specified that the agent_config is only for the md_tx_agent      
                    uvm_config_db#(uvm_ext_pkg::uvm_ext_agent_config#(.VIRTUAL_INTF(virtual cfs_md_if#(ALGN_DATA_WIDTH))))::set(this, "md_tx_agent", "agent_config", agent_config);
                end
                
                md_tx_agent = cfs_md_agent_slave#(ALGN_DATA_WIDTH)::type_id::create("md_tx_agent", this);

                model = cfs_algn_model::type_id::create("model", this);
            
                predictor = uvm_reg_predictor#(cfs_apb_item_mon)::type_id::create("predictor", this);
            endfunction

            virtual function void connect_phase(uvm_phase phase);
                cfs_apb_reg_adapter adapter = cfs_apb_reg_adapter::type_id::create("adapter", this);
                
                super.connect_phase(phase);

                predictor.adapter = adapter;
                predictor.map = model.reg_block.default_map;

                apb_agent.monitor.output_port.connect(predictor.bus_in);
            endfunction
        endclass
`endif