`ifndef CFS_APB_DRIVER_SV
    `define CFS_APB_DRIVER_SV

    class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv)) implements cfs_apb_reset_handler;

        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_apb_agent_config agent_config;

        // Process for driver_transactions() task
        protected process process_drive_transactions;

        `uvm_component_utils(cfs_apb_driver)
 
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

                        cfs_apb_item_drv item;

                        seq_item_port.get_next_item(item);
                        
                        driver_transaction(item);
                        
                        seq_item_port.item_done();
                    end
                end
            join 
        endtask

        // Function to handle the reset
        virtual function void handler_reset(uvm_phase phase);
            // We get the virtual interface from the agent config
            // using get_vif() to protect the encapsulation
            // of the virtual interface inside the agent config class
            cfs_apb_vif vif = agent_config.get_vif();

            if(process_drive_transactions != null) begin
                process_drive_transactions.kill();
                process_drive_transactions = null;
            end

            // Initialize the signals
            vif.paddr <= '0;
            vif.pwrite <= 0;
            vif.pwdata <= '0;
            vif.psel <= 0;
            vif.penable <= 0;
        endfunction

        protected virtual task driver_transaction(cfs_apb_item_drv item);
            cfs_apb_vif vif = agent_config.get_vif();

            `uvm_info("DEBUG", $sformatf("Driving item: \"%s\": %s", item.get_full_name(), item.convert2string()), UVM_NONE)
            
            // Pre drive delay
            for (int i = 0; i < item.pre_drive_delay; i++) begin
                @(posedge vif.pclk);
            end

            // Setup phase
            vif.psel <= 1;
            vif.paddr <= item.addr;
            vif.pwrite <= bit'(item.dir);
            if (item.dir == CFS_APB_WRITE) begin
                vif.pwdata <= item.data;
            end

            @(posedge vif.pclk);
            vif.penable <= 1;

            @(posedge vif.pclk);
            // Access phase
            while(vif.pready !== 1) begin
                @(posedge vif.pclk);
            end

            // Once pready is one, we can deassert the signals
            vif.paddr <= 0;
            vif.pwrite <= 0;
            vif.pwdata <= 0;
            vif.psel <= 0;
            vif.penable <= 0;

            // Post drive delay
            for (int i = 0; i < item.post_drive_delay; i++) begin
                @(posedge vif.pclk);
            end

        endtask

    endclass
`endif