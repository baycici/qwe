module tb_mac_row;

  // Parameters (same as in DUT)
  parameter nz = 8;
  parameter bw = 4;
  parameter psum_bw = 20;
  parameter ncol = 2;
  parameter col = 4;

  // Signals
  logic clk;
  logic reset;
  logic execute;
  logic load;
  logic a_select;
  logic acc_done;

  logic [bw-1:0] nzero_weights [nz-1:0];
  logic [bw-1:0] in_activation [1:0];
  logic [psum_bw-1:0] in_psum [col-1:0];
  logic [1:0] act_index [1:0];
  logic [1:0] w_indexes [nz-1:0];

  logic [psum_bw-1:0] final_psum [col-1:0];
  logic load_out;

  // Instantiate DUT
  mac_row dut (
    .clk(clk),
    .reset(reset),
    .execute(execute),
    .load(load),
    .a_select(a_select),
    .nzero_weights(nzero_weights),
    .w_indexes(w_indexes),
    .in_activation(in_activation),
    .in_psum(in_psum),
    .act_index(act_index),
    .final_psum(final_psum),
    .load_out(load_out)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    execute = 0;
    load = 0;
    a_select = 0;
    acc_done = 0;

    // Initialize inputs to zero
    for (int i=0; i<nz; i++) begin
      nzero_weights[i] = 0;
      w_indexes[i] = 0;
    end
    for (int i=0; i<col; i++) begin
      in_psum[i] = 0;
      final_psum[i] = 0;
    end
    for (int i=0; i<2; i++) begin
      in_activation[i] = 0;
      act_index[i] = 0;
    end

    #15;
    reset = 0;

    // Phase 1: Load active, activations should NOT change here
    load = 1;
    execute = 1;

    // Set in_psum and weights (weights can be constant here)
    in_psum[0] = 20'd5;
    in_psum[1] = 20'd10;
    in_psum[2] = 20'd15;
    in_psum[3] = 20'd20;

    for (int i=0; i<nz; i++) begin
      nzero_weights[i] = i + 1;
    
    end

    w_indexes[0] = 2'd1;
    w_indexes[1] = 2'd0;
    w_indexes[2] = 2'd2;
    w_indexes[3] = 2'd1;
    w_indexes[4] = 2'd3;
    w_indexes[5] = 2'd2;
    w_indexes[6] = 2'd3;
    w_indexes[7] = 2'd2;

    // Set some activations and act_index BEFORE load=1
    in_activation[0] = 4'd3;
    in_activation[1] = 4'd7;
    act_index[0] = 2'd1;
    act_index[1] = 2'd2;

    #10;

    // Now try to change activations while load is high - should be ignored by DUT per your design request
    in_activation[0] = 4'd9;
    in_activation[1] = 4'd10;
    act_index[0] = 2'd3;
    act_index[1] = 2'd0;

    #10;

    // Deassert load, now activations can update
    load = 0;

    // Provide new activations now that load is low
    in_activation[0] = 4'd11;
    in_activation[1] = 4'd13;
    act_index[0] = 2'd0;
    act_index[1] = 2'd3;

    #20;

    // Phase 2: Another execute without load
    execute = 1;
    #20;

    // Phase 3: Final execute with load again, activations should remain stable again
    load = 1;
    execute = 1;

    // Attempt to change activations - should NOT be applied while load is high
    in_activation[0] = 4'd1;
    in_activation[1] = 4'd1;
    act_index[0] = 2'd1;
    act_index[1] = 2'd1;

    #10;

    // Deassert load to allow new activations
    load = 0;

    in_activation[0] = 4'd7;
    in_activation[1] = 4'd8;
    act_index[0] = 2'd2;
    act_index[1] = 2'd2;

    #20;

    $display("\nFinal psum values:");
    for (int i=0; i < col; i++) begin
      $display("final_psum[%0d] = %0d", i, final_psum[i]);
    end

    $finish;
  end

endmodule