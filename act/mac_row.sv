module mac_row (clk, reset, execute, load, a_select, nzero_weights, w_indexes, in_activation, in_psum, act_index, final_psum, load_out);

	parameter nz = 8;
	parameter bw = 4;                                                   
	parameter psum_bw = 20;
	parameter ncol = 2; 
	parameter col = 4;
 

    	
	input logic clk, reset, execute, a_select;
	input logic [bw-1:0] nzero_weights [nz-1:0];       //array of 8 non-zero weights
	input logic [bw-1:0] in_activation [1:0];   //activation value
	input logic [psum_bw-1:0] in_psum [col-1:0];  //input psum (1 array of 4)
	input logic [1:0] act_index [1:0];      //activation index
    input logic [1:0] w_indexes [nz-1:0];	
    input logic load;  //array of w_indexes
    logic load_q;

	logic [psum_bw-1:0] out_psum [ncol-1:0]; //output psum
        logic [psum_bw-1:0] int_psum [col-1:0];
        output logic [psum_bw-1:0] final_psum [col-1:0];
        logic [psum_bw-1:0] temp_psum [col-1:0];
        output logic load_out;
        assign load_out = load_q;
        
        

  
        logic [1:0] w_index_out [ncol-1:0];
        logic execute_q;

        always_comb begin
           temp_psum = int_psum;
           for( int i = 0; i < ncol; i=i+1) begin
	      temp_psum[w_index_out[i]] = temp_psum[w_index_out[i]] +  out_psum[i];
           end
       end	
	    



		    
	
	
	
	always_ff @ (posedge clk) begin
		int i;    
                execute_q <= execute;
                load_q <= load;
            if(reset) begin
		int_psum <= '{default: 0};
                final_psum <= '{default: 0};

             end
            else if (execute_q == 1) begin
                 if(load==1) begin
			for (i=0; i < col; i++) begin
				int_psum[i] <= in_psum[i];
                        end
                 end
                 else
                        int_psum <= temp_psum;            
              
            end
        end 
		
		
		

	






generate
  genvar i;
  for (i=0; i < ncol ; i=i+1) begin : col_num       
  	localparam int slice_start = (i) * col;
      mac_tile_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
     .clk(clk),
     .reset(reset),            
     .execute(execute_q), 
     .a_select(a_select),  //execute instruction passing column by column
     .in_weight(nzero_weights[slice_start +: col]), //the first tile has the first 4 weights and the second tile has the next 4;
	 .in_activation(in_activation),
	 .w_index(w_indexes[slice_start +: col]),
	 .a_index(act_index),  
	 .out_psum (out_psum[i]),
         .w_index_out(w_index_out[i])
	 );
  end   
endgenerate

endmodule
