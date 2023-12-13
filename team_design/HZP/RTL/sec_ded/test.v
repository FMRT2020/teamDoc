module test();

	reg [10:0] data;
	reg [4:0] control;
	wire [10:0] cdata;
	wire [4:0] control_new;
	wire secr,dede;

	sec_ded_hasio_decode #(.DW(11)) 
		ded(data,control,cdata,control_new,secr,dede);

	initial begin
		data <= 11'h7ff;
		control <= 5'h1f;
		#10;
		control <= 5'h1e;
		#10;
		data <= 11'h7ef;
		#10;
		$finish;
	end

	initial begin
		$fsdbDumpfile("test.fsdb");
		$fsdbDumpvars(0);
	end
endmodule