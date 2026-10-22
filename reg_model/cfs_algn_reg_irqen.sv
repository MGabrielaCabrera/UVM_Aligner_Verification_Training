`ifndef CFS_ALGN_REG_IRQEN_SV
    `define CFS_ALGN_REG_IRQEN_SV

    class cfs_algn_reg_irqen extends uvm_reg;

        `uvm_object_utils(cfs_algn_reg_irqen)

        // The fields must be declared as rand
        rand uvm_reg_field RX_FIFO_EMPTY;
        rand uvm_reg_field RX_FIFO_FULL;
        rand uvm_reg_field TX_FIFO_EMPTY;
        rand uvm_reg_field TX_FIFO_FULL;
        rand uvm_reg_field MAX_DROP;

        function new(string name = "cfs_algn_reg_irqen");
            // The new() of uvm_reg takes three arguments
            super.new(.name(name), .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
        
        endfunction

        virtual function void build();
            RX_FIFO_EMPTY = uvm_reg_field::type_id::create(.name("RX_FIFO_EMPTY"), .parent(null), .contxt(get_full_name()));
            RX_FIFO_FULL = uvm_reg_field::type_id::create(.name("RX_FIFO_FULL"), .parent(null), .contxt(get_full_name()));
            TX_FIFO_EMPTY = uvm_reg_field::type_id::create(.name("TX_FIFO_EMPTY"), .parent(null), .contxt(get_full_name()));
            TX_FIFO_FULL = uvm_reg_field::type_id::create(.name("TX_FIFO_FULL"), .parent(null), .contxt(get_full_name()));
            MAX_DROP = uvm_reg_field::type_id::create(.name("MAX_DROP"), .parent(null), .contxt(get_full_name()));

            RX_FIFO_EMPTY.configure(
                .parent(this),
                .size(1),
                .lsb_pos(0),
                .access("RW"),
                .volatile(0), // If the field is volatile, it means that the value of the field can change without any action from the software. For example, a status register that is updated by hardware.
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            RX_FIFO_FULL.configure(
                .parent(this),
                .size(1),
                .lsb_pos(1),
                .access("RW"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            TX_FIFO_EMPTY.configure(
                .parent(this),
                .size(1),
                .lsb_pos(2),
                .access("RW"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            TX_FIFO_FULL.configure(
                .parent(this),
                .size(1),
                .lsb_pos(3),
                .access("RW"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            MAX_DROP.configure(
                .parent(this),
                .size(1),
                .lsb_pos(4),
                .access("RW"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

        endfunction
    endclass
`endif