module DP1M4_row (
     clk, 
   reset,
    weights,
  weight_mask,
     activation,
   activation_index,
     load,
    execute,
    psum_in ,

    load_out,
   psum_out
);

    parameter col = 4;
    parameter bw = 4;
    parameter psum_bw = 20;    
    parameter nnz = 8;
    parameter ncol = 2; 
    parameter total = 16;   
    
    input logic clk;
    input logic reset;
    input logic [bw-1:0] weights [nnz-1:0];
    input logic [total-1:0] weight_mask;
    input logic [bw-1:0] activation;
    input logic [1:0] activation_index;
    input logic load;
    input logic execute;
    input logic [psum_bw-1:0] psum_in [col-1:0];

    output logic load_out;
    output logic [psum_bw-1:0] psum_out [col-1:0];

    logic load_q;
    logic execute_q;   
    logic load_2q;

    always @ (posedge clk) begin
        load_q <= load;
        execute_q <= execute;  
        load_2q <= load_q;
    end

    assign load_out = load_2q;

    generate
        genvar i;  
   
        for (i = 0; i < col; i = i + 1) begin : col_num       
            localparam int slice_start = i * ncol;   
     
            DP1M4 #(.bw(bw), .psum_bw(psum_bw)) DP1M4_instance (
                .clk(clk),
                .reset(reset),
                .load(load_q),
                .execute(execute_q),
                .weights(weights[slice_start +: ncol]),
                .w_index(weight_mask[i*4 +: 4]),
                .activation(activation),
                .activation_index(activation_index),
                .psum_in(psum_in[i]),
                .psum_out(psum_out[i])
              );
        end
    endgenerate

endmodule