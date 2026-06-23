`ifndef CFS_APB_IF_SV
    `define CFS_APB_IF_SV
    `ifndef CFS_APB_MAX_ADDR_WIDTH
        `define CFS_APB_MAX_ADDR_WIDTH 16
    `endif

    `ifndef CFS_APB_MAX_DATA_WIDTH
        `define CFS_APB_MAX_DATA_WIDTH 32
    `endif

    interface cfs_apb_if (input pclk);

        logic preset_n;
        logic [`CFS_APB_MAX_ADDR_WIDTH-1:0] paddr;
        logic psel;
        logic penable;
        logic pwrite;
        logic [`CFS_APB_MAX_DATA_WIDTH-1:0] pwdata;
        logic pready;
        logic [`CFS_APB_MAX_DATA_WIDTH-1:0] prdata;
        logic pslverr;

        bit has_checks;

        initial begin
            has_checks = 1;
        end

        // Sequence for the setup phase
        sequence setup_phase_s;
            // We can have one single transaction or several in a row:
      (psel == 1) && (($past(psel) == 0) || ($past(psel) == 1 && $past(pready) == 1));        endsequence;

        sequence access_phase_s;
            ((psel == 1) && (penable == 1));
        endsequence

        property penable_at_setup_phase_p;
            // The property is disable if reset or if has_checks is zero
            @(posedge pclk) disable iff (!preset_n || !has_checks)
            // In the same clock cycle (|->) of the setup_phase, we should have penable
            setup_phase_s |-> penable == 0;
        endproperty

        property penable_entering_access_phase_p;
            // The property is disable if reset or if has_checks is zero
            @(posedge pclk) disable iff (!preset_n || !has_checks)
            // In the next clock cycle (|=>) after setup phase, penable must be one
            setup_phase_s |=> penable == 1;
        endproperty

        property penable_exiting_access_phase_p;
            // The property is disable if reset or if has_checks is zero
            @(posedge pclk) disable iff (!preset_n || !has_checks)
            access_phase_s and (pready ==1) |=> penable == 0;
        endproperty

        property penable_stable_at_access_phase_p;
            @(posedge pclk) disable iff (!preset_n || !has_checks)
            access_phase_s |-> penable == 1;
        endproperty

        property pwrite_stable_at_access_phase_p;
            @(posedge pclk) disable iff (!preset_n || !has_checks)
            // To ensure the value of pwrite is the same of the one before the previous clock cycle
            access_phase_s |-> $stable(pwrite);
        endproperty

        PENABLE_AT_SETUP_PHASE_A: assert property(penable_at_setup_phase_p) else begin
            $error("PENABLE at setup phase is not equal to 0"); // $error is used here and not the uvm
                                                               // library because one of the reasons 
                                                               // of adding the assertions in the interface
                                                           // is to reuse them in formal verification
        end

        PENABLE_ENTERING_ACCESS_PHASE_A: assert property(penable_entering_access_phase_p) else begin
            $error("PENABLE entering access phase is not equal to 1");
        end

        PENABLE_EXITING_ACCESS_PHASE_A: assert property(penable_exiting_access_phase_p) else begin
            $error("PENABLE exiting access phase is not equal to 0");
        end


        PENABLE_STABLE_AT_ACCESS_PHASE_A: assert property(penable_stable_at_access_phase_p) else begin
            $error("PENABLE during access phase is not equal to 1");
        end

        PWRITE_STABLE_AT_ACCESS_PHASE_A: assert property(pwrite_stable_at_access_phase_p) else begin
            $error("PWRITE during access phase is not equal to 1");
        end

    endinterface

`endif
