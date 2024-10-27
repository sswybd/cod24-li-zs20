`define simple_reg(reg_name, reg_input) \
    always_ff @(posedge sys_clk) begin \
        if (sys_rst) begin \
            reg_name <= 'd0; \
        end \
        else if (wr_en) begin \
            reg_name <= reg_input; \
        end \
    end

`define simple_reg_with_reset(reg_name, reg_input, reset_val) \
    always_ff @(posedge sys_clk) begin \
        if (sys_rst) begin \
            reg_name <= reset_val; \
        end \
        else if (wr_en) begin \
            reg_name <= reg_input; \
        end \
    end