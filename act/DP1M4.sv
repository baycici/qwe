module latch_clock_gating(
    input  wire clk,
    input  wire enable,     // gating condition (signal && !load)
    output wire gated_clk
);

    reg latch_q;

    // Latch the enable signal when clk is low (level sensitive latch)
    always @(clk) begin
        if (!clk)
            latch_q <= enable;
    end

    assign gated_clk = clk & latch_q;

endmodule



module DP1M4 (clk , reset, weights, w_index, activation, activation_index, psum_in, load, execute, psum_out); 
    parameter bw = 4;
    parameter psum_bw = 20;  
    parameter nnz = 2;                    
    parameter n = 4;
	input logic clk, reset;
	input logic [bw-1:0] weights [nnz-1:0];
	input logic [n-1:0] w_index;
	input logic [bw-1:0] activation;
	input logic [1:0] activation_index;
	input logic [psum_bw-1:0] psum_in;    
	input logic load, execute;
	
	//output logic [bw-1:0] activation_out;
	//output logic [1:0] activation_out_index;
	//output logic load_out;
	//output logic execute_out;
	output logic [psum_bw-1:0] psum_out;  
	logic [1:0] w_indexes[nnz-1:0]; 
	logic [psum_bw-1:0] psum_q;
	logic execute_q;
	logic load_q; 

	logic gclk;
	logic signal;   
	
	logic [bw-1:0] activation_q;
	logic [1:0] activation_index_q;
	                  
	//assign activation_out = activation_q;
	//assign activation_out_index = activation_index_q;
	//assign load_out = load_q;
	//assign execute_out = execute_q;
	assign psum_out = psum_q;
	logic signal_q;         
	logic [bw-1:0] weight_sel;
	logic [psum_bw-1:0] product;
	
	
	
	always_comb begin 
	    int j;
	    j = 0;
		for(int i = 0; i<n; i=i+1) begin  
			if(w_index[i]) begin
				w_indexes[j] = i;
				j = j+1;
			end
		end   
	end         
	
     
	assign signal = (activation_index== w_indexes[0] || activation_index == w_indexes[1]) ? 1 : 0; 
	assign weight_sel = (signal) ? (activation_index == w_indexes[0] ? weights[0] : weights[1]) : weight_sel;  
	assign product = weight_sel*activation;   
	
	
	
   logic gating_cond;
	assign gating_cond = signal && !load && execute;
    logic gated_clk;

  latch_clock_gating clk_gate (
    .clk(clk),
    .enable(gating_cond),
    .gated_clk(gated_clk)
  );
	       
	       
	       
	       
always @(posedge gated_clk) begin
  if (reset) 
    psum_q <= 0;
  else 
    psum_q <= psum_q + weight_sel * activation;
end
	
	
	
	
	
	
always @(posedge clk) begin
  if (reset)
    psum_q <= 0;
  else if (execute && load)
    psum_q <= psum_in;
end
	
		   
		
endmodule	
			
			
		
			
	