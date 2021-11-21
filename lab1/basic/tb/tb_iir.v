
 
// -- 		  nb=8
// -- 		  IIR filter implementation could have overflow
// -- 		  we used  17 bits(2*nb+1) in the internal calculation

module tb_iir ();

   wire CLK_i;
   wire RST_n_i;
   wire [7:0] DIN_i;
   wire VIN_i;
   wire [7:0] a0_i;
   wire [7:0] a1_i;
   wire [7:0] a2_i;
   wire [7:0] b1_i;
   wire [7:0] b2_i;
   wire [7:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .a0(a0_i),
		 .a1(a1_i),
		 .a2(a2_i),
		 .b1(b1_i),
		 .b2(b2_i),
		 .END_SIM(END_SIM_i));

   IIR_filter UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .VIN(VIN_i),
		  .VOUT(VOUT_i),
		 .a0(a0_i),
		 .a1(a1_i),
		 .a2(a2_i),
		 .b1(b1_i),
		 .b2(b2_i),
             .DIN(DIN_i),
	     .DOUT(DOUT_i));
             

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
