`ifndef CFS_MD_DRIVER_MASTER_SV
    `define CFS_MD_DRIVER_MASTER_SV

    class cfs_md_driver_master#(int unsigned DATA_WIDTH = 32) extends cfs_md_driver#(.ITEM_DRV(cfs_md_item_drv_master)) implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        `uvm_component_param_utils(cfs_md_driver_master#(DATA_WIDTH))
 
        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        protected virtual task driver_transaction(ITEM_DRV item);
            cfs_md_vif vif = agent_config.get_vif();
            int unsigned data_width_in_bytes = DATA_WIDTH / 8;

            `uvm_info("DEBUG", $sformatf("Driving \"%0s\": %0s", item.get_full_name(), item.convert2string()), UVM_NONE)

            if(item.offset + item.data.size() > data_width_in_bytes) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Trying to drive an item with offset %0d and %0d bytes but the width of the data bus, in bytes, is %0d", item.offset, item.data.size(), data_width_in_bytes))
            end

        endtask

    endclass

`endif