

module mac_tile_wrapper(clk, reset, w_index, a_index, a_select, in_weight, in_activation, out_psum, w_index_out, execute);
	parameter bw = 4;
	parameter psum_bw = 16;   
	parameter row = 4; 
	parameter col = 4;
	parameter nz = 2;                                                      
	parameter depth = 4;      
	

	input execute;
	input clk, reset;
        input a_select;
	input [bw-1:0] in_activation [1:0]; //activation 
	//input [psum_bw-1:0] in_psum [col-1:0]; // psum_bw 16, 4 element array
	input [bw-1:0] in_weight [depth-1:0]; // 4 weights of bitwidth 4
	input [1:0] w_index [depth-1:0];   // 4 weight indexes 
	input [1:0] a_index [1:0]; //activation index


        logic [bw-1:0] act_select;
        logic [bw-1:0] act_select_q;
        logic [1:0] act_select_index;   
	logic [1:0] act_select_index_q;                                                            
	logic [psum_bw-1:0] product;  //product
	logic [bw-1:0] select_w; 
        logic [bw-1:0] select_w_q; //selected value of w for multiplication
	logic [1:0] select_w_index;
        logic [1:0] select_w_index_q; //selected weight index 
	logic [psum_bw-1:0] psum_buffer [col-1:0]; 
        logic execute_q;
	
	     
	
	output logic [psum_bw-1:0] out_psum;      //output psums
        output logic [1:0] w_index_out;
        assign w_index_out = select_w_index_q;
	 
        
	    

	
	
	
       
	                               
	                               
	
            assign act_select = (a_select==1) ? in_activation[1] : in_activation[0];
            assign act_select_index = (a_select==1) ? a_index[1] : a_index[0];
	    assign select_w = in_weight[act_select_index];   //weights are selected based on activation index
	    assign select_w_index = w_index[act_select_index];  //weight indexes selected based on activation index
	    
	    assign product = (act_select_q)*(select_w_q); //multiplying input activation by selected weight
	 
		  

    
    always_ff @ (posedge clk) begin
	
    		
    	if(reset)  begin
    		out_psum <= 0;
    		
	end
        else begin 
              act_select_q <= act_select;
              act_select_index_q <= act_select_index;
              select_w_q <= select_w;
              select_w_index_q <= select_w_index;
              execute_q <= execute;
    
             
    
    	      if (execute==1) begin         
    	   		    				     
    		
    		out_psum <= product;
    	     end
       end
    end       
   
 endmodule
    		
    		
    		 
    		
    		
    		
	
	
	
    
 
	

    
    			
    	   	