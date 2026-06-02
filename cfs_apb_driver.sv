`ifndef CFS_APB_DRIVER_SV
    `define CFS_APB_DRIVER_SV

    class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv));

        `uvm_component_utils(cfs_apb_driver)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            cfs_apb_item_drv item;

            forever begin
                seq_item_port.get_next_item(item);
                `uvm_info(get_type_name(), $sformatf("Driving item: %s", item.convert2string()), UVM_MEDIUM)
                drive_item(item);
                seq_item_port.item_done();
            end
        endtask

        virtual task drive_item(cfs_apb_item_drv item);
            // Implement the logic to drive the APB signals based on the item properties
            // This is a placeholder and should be replaced with actual driving code
            `uvm_info(get_type_name(), $sformatf("Driving APB transaction: %s", item.convert2string()), UVM_MEDIUM)
            // Example: Drive signals based on item.dir, item.addr, item.data, etc.
        endtask

    endclass
`endif