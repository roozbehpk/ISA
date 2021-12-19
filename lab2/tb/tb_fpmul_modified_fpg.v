
module tb_fpmul_modified ();
	wire CLK_i;
	wire End_prc_i;
	wire D_R_i;
	wire Write_enable_i;
	reg  RST_n_i;
	wire [31:0] FP_IN;
	wire [31:0] FP_Z_i;
	wire ERR_i;

	clk_gen CG(
		.END_SIM(End_prc_i),
		.CLK(CLK_i)
	);

	data_maker SM(
		.RST_n(RST_n_i),
		.CLK(CLK_i),
		.END_SIM(End_prc_i),
		.DATA(FP_IN),
		.D_IN(D_R_i)
	);

	FPmul DUT(
		.FP_A(FP_IN),
		.FP_B(FP_IN),
		.FP_Z(FP_Z_i),
		.clk(CLK_i)
	);

	delayer #(6) DL(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.DIN(D_R_i),
		.DOUT(Write_enable_i)
	);

	data_sink DS(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.FP_Z(FP_Z_i),
		.ERR(ERR_i),
		.EN(Write_enable_i)
		);

	initial begin 	
		RST_n_i = 0; #2
		RST_n_i = 1;
	end

endmodule
