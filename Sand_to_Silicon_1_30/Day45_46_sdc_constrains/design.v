module vitalguard_core (
    input  wire        clk_50mhz,
    input  wire        rst_n,
    
    // Asynchronous Control Input (CDC Path)
    input  wire        ext_trigger,
    
    // ADC Domain Interface
    input  wire [11:0] adc_data_in,
    input  wire        adc_valid,
    output reg         adc_clk_out,
    
    // Processed Output Interface
    output reg  [15:0] ecg_filtered_out,
    output reg         alarm_flag
);

    // =========================================================================
    // 1. Clock Divider: 50 MHz to 1 MHz ADC Clock Generation
    // =========================================================================
    reg [5:0] clk_div_count;
    
    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_count <= 6'd0;
            adc_clk_out   <= 1'b0;
        end else begin
            if (clk_div_count == 6'd24) begin
                clk_div_count <= 6'd0;
                adc_clk_out   <= ~adc_clk_out;
            end else begin
                clk_div_count <= clk_div_count + 1'b1;
            end
        end
    end

    // =========================================================================
    // 2. CDC Synchronizer: 2-FF Synchronizer for Async Trigger
    // =========================================================================
    reg sync_ff1, sync_ff2;
    
    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= ext_trigger;
            sync_ff2 <= sync_ff1;
        end
    end

    // =========================================================================
    // 3. Multi-Cycle Path: Heavy ECG Accumulator/Filter (2 Clock Cycles)
    // =========================================================================
    (* keep = "true", mark_debug = "true" *) reg [15:0] accum_stage1;
    (* keep = "true", mark_debug = "true" *) reg [15:0] accum_stage2;
    
    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            accum_stage1     <= 16'd0;
            accum_stage2     <= 16'd0;
            ecg_filtered_out <= 16'd0;
            alarm_flag       <= 1'b0;
        end else if (sync_ff2) begin
            // Complex arithmetic logic target for multicycle setup
            accum_stage1     <= (adc_data_in * 8'd125) + 16'h00FF;
            accum_stage2     <= (accum_stage1 * 3'd5) - 16'h0010;
            ecg_filtered_out <= accum_stage2;
            alarm_flag       <= (accum_stage2 > 16'hA000);
        end
    end

endmodule