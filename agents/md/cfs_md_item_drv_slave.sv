`ifndef CFS_MD_ITEM_DRV_SLAVE_SV
    `define CFS_MD_ITEM_DRV_SLAVE_SV

    class cfs_md_item_drv_slave extends cfs_md_item_drv;

        rand int unsigned length;

        rand md_response response;

        rand bit ready_at_end;

        constraint length_default_c {soft length <= 5; }


        `uvm_object_utils(cfs_md_item_drv_slave)

        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();

            result = $sformatf("length: %0d, response: %0s, ready_at_end: %0d", length, response.name(), ready_at_end);
            return result;
            
        endfunction

    endclass
`endif
