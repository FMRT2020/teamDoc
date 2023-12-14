module test();

	reg clk,reset,l2_miss,en_back;
	reg [2:0] group_id;
	reg [127:0] data;
	wire error;
	wire [127:0] dataa;

	memory mem(clk,reset,l2_miss,en_back,group_id,dataa,error);

	initial begin
		clk <= 1'b1;
		reset <=1'b1;
		l2_miss <= 1'b0;
		en_back <= 1'b0;
		#10;
		reset <= 1'b0;
		l2_miss <= 1'b1;
		group_id <= 3'h0;
		#30;
		en_back <= 1'b1;
		group_id <= 3'h2;
		data <= 128'haaaaaaaa_fafafafa_ffffffff_afafafaf;
		#20;
		en_back <= 1'b0;
		group_id <= 3'h1;
		#40;
		$finish;
	end

	assign dataa = en_back ? data : 128'hz;

	initial begin
		$fsdbDumpfile("test.fsdb");
		$fsdbDumpvars(0);
	end

	initial begin
		forever begin
			#5;
			clk <= ~clk;
		end
	end
endmodule