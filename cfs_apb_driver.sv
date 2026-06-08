`ifndef CFS_APB_DRIVER_SV
    `define CFS_APB_DRIVER_SV

    class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv));

        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_apb_agent_config agent_config;

        `uvm_component_utils(cfs_apb_driver)
 
        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            driver_transactions();
        endtask

        protected virtual task driver_transactions();
            cfs_apb_item_drv item;

            forever begin
                seq_item_port.get_next_item(item);
                
                driver_transaction(item);
                
                seq_item_port.item_done();
            end
        endtask

        protected virtual task driver_transaction(cfs_apb_item_drv item);
            `uvm_info("DEBUG", $sformatf("Driving item: \"%s\": %s", item.get_full_name(), item.convert2string()), UVM_NONE)

        endtask

    endclass
`endif