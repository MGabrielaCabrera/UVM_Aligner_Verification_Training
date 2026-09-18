`ifndef CFS_MD_DRIVER_SV
    `define CFS_MD_DRIVER_SV

    class cfs_md_driver#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) extends uvm_driver#(.REQ(ITEM_DRV)) implements cfs_md_reset_handler;
        
        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_md_agent_config#(DATA_WIDTH) agent_config;

        // Process for driver_transactions() task
        protected process process_drive_transactions;

        `uvm_component_param_utils(cfs_md_driver#(DATA_WIDTH, ITEM_DRV))
 
        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        // Task for waiting the reset to end (synchronous)
        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual task run_phase(uvm_phase phase);
            forever begin
                fork
                    begin
                        wait_reset_end();
                        driver_transactions();
                        
                        disable fork;
                    end
                join
            end
        endtask

        protected virtual task driver_transactions();
            fork
                begin
                    process_drive_transactions = process::self();

                    forever begin

                        ITEM_DRV item;

                        seq_item_port.get_next_item(item);
                        
                        driver_transaction(item);
                        
                        seq_item_port.item_done();
                    end
                end
            join 
        endtask

        // Function to handle the reset
        virtual function void handler_reset(uvm_phase phase);


            if(process_drive_transactions != null) begin
                process_drive_transactions.kill();
                process_drive_transactions = null;
            end

        endfunction

        protected virtual task driver_transaction(ITEM_DRV item);
            `uvm_fatal("ALGORITHM_ISSUE", "driver_transaction() must be implemented in the derived class");
        endtask

    endclass
`endif