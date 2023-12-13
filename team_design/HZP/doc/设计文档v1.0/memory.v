module memory(
	input clk,reset,
	input l2_miss,en_back,

	input [2:0] group_id,
	//input [27:0] group_id,

	inout [127:0] data_block,
	output error_mem);

	//reg [136:0] DRAM [268435455:0];
	reg [136:0] DRAM [7:0];

	reg [1:0] old_state;
	reg [1:0] state;

	reg error;
	reg [127:0] outdata;
	wire [8:0] contro_hasio_n;
	wire [127:0] old_data,cdata,data_state;
	wire [8:0] contro_hasio_old;
	wire secr,dedr;

	//nextstate logic
	always @(*) begin
		if (reset) begin
			state <= 2'b00;
		end
		else if (l2_miss & old_state==2'b00) begin
			if (en_back) begin
				state <= 2'b01;
			end
			else begin
				state <= 2'b10;
			end
		end
		else if (old_state==2'b01) begin
			state <= 2'b10;
		end
		else if (old_state==2'b10) begin
			state <= 2'b11;
		end
		else begin
			state <= 2'b00;
		end
	end

	//state logic
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			old_state <= 2'b00;
		end
		else if (state==2'b01) begin
			DRAM[group_id] <= {contro_hasio_n,data_state};
			outdata <= 0;
		end
		else if (state==2'b10) begin
			if(secr)begin
				DRAM[group_id] <= {contro_hasio_n,cdata};
			end
			outdata <= cdata;
		end
		else if (state==2'b11) begin
			outdata <= cdata;
		end
		else begin
			outdata <= 0;
		end
		old_state <= state;
	end

	//logic
	assign {contro_hasio_old,old_data} = DRAM[group_id];
	assign data_state = state[1] ? old_data : data_block;
	hasioCoder #(.DW(128)) coder(data_state,contro_hasio_n);
	hasioDecoder #(.DW(128)) decoder(old_data,contro_hasio_old,contro_hasio_n,cdata,secr,dedr);
	always @(*) begin
		if (state==2'b11) begin
			error <= dedr;
		end
		else begin
			error <= 1'b0;
		end
	end

	assign error_mem = error;
	assign data_block = &state ? outdata : 128'hz;

	initial begin
		DRAM[0] <= 137'h20_f0f0f0f0_0f0f0f0f_a0a0a0a0_0a0a0a0a;//2-0
		DRAM[1] <= 137'h22_feffffff_afaf0f0f_8aaaaaaa_fafa0a0a;//f-e/a-8
		//DRAM[2] <= 137'h173_aaaaaaaa_fafafafa_ffffffff_afafafaf
	end
endmodule
//对数据进行hasio编码
module hasioCoder #(
	parameter DW=32,
	parameter PW=$clog2(1+DW+$clog2(1+DW))+1
	)(
	input [DW-1:0] data,
	output [PW-1:0] contro_hasio);

	integer i,c,j;
	reg [DW-1:0] m [PW-1:0];
	reg [PW-1:0] con;

	always @(*) begin
		for(i=0;i<DW;i=i+1) begin
			c = (i+1) + $clog2(1+(i+1)+$clog2(1+(i+1)));
			c[PW-1]=~^c[PW-2:0];
			for(j=0;j<PW;j=j+1) begin
				m[j][i] = c[j] & data[i];
				con[j] = ^m[j];
			end
		end
	end

	assign contro_hasio = con;
endmodule
//对数据进行hasio解码
module hasioDecoder #(
	parameter DW=32,
	parameter PW=$clog2(1+DW+$clog2(1+DW))+1
	)(
	input [DW-1:0] data,
	input [PW-1:0] contro_hasio,
	input [PW-1:0] contro_hasio_new,
	output [DW-1:0] cdata,
	output secr,dedr);

	wire [PW-1:0] con_xor;

	assign con_xor = contro_hasio_new ^ contro_hasio;

	integer i,c;
	reg [DW-1:0] overturn;
	always @(*) begin
		for(i=0;i<DW;i=i+1)begin
			c=(i+1)+$clog2(1+(i+1)+$clog2(1+(i+1)));
			c[PW-1]=~^c[PW-2:0];
			overturn=(c==con_xor);
		end
	end

	assign cdata = overturn^data;
	assign secr = |con_xor & ^con_xor;
	assign dedr = |con_xor & ~^con_xor;
endmodule
