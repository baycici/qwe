`timescale 1ns/1ps

module DP1M4_row_tb;

    // Parameters
    parameter col = 4;
    parameter bw = 4;
    parameter psum_bw = 20;    
    parameter nnz = 8;
    parameter ncol = 2;
    parameter total_mask_bits = 16;

    // Inputs
    logic clk;
    logic reset;
    logic [bw-1:0] weights [nnz-1:0];
    logic [total_mask_bits-1:0] weight_mask;
    logic [bw-1:0] activation;
    logic [1:0] activation_index;
    logic load;
    logic execute;
    logic [psum_bw-1:0] psum_in [col-1:0];

    // Outputs
    logic load_out;
    logic [psum_bw-1:0] psum_out [col-1:0];

    // DUT instantiation
    DP1M4_row #(
        .col(col), .bw(bw), .psum_bw(psum_bw),
        .nnz(nnz), .ncol(ncol)
    ) dut (
        .clk(clk), .reset(reset),
        .weights(weights),
        .weight_mask(weight_mask),
        .activation(activation),
        .activation_index(activation_index),
        .load(load),
        .execute(execute),
        .psum_in(psum_in),
        .load_out(load_out),
        .psum_out(psum_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        reset = 1;
        load = 0;
        execute = 0;
        activation = 0;
        activation_index = 0;
        weight_mask = 16'b0110100101101010;
        for (int i = 0; i < nnz; i++) weights[i] = i;
        for (int i = 0; i < col; i++) psum_in[i] = i;

        #10;
        reset = 0;

        // === Load Cycle ===
        // Load psum_in and hold activation stable
        activation = 4'd3;
        activation_index = 2'd1;
        load = 1;
        execute = 1;
        #10;
        load = 0;

        // === Execution phase ===
        // Change activation only after load
        activation = 4'd2;
        activation_index = 2'd2;
        execute = 1;
        #40;

        // More cycles
        activation = 4'd1;
        activation_index = 2'd3;
        #40;

        $finish;
    end

endmodule