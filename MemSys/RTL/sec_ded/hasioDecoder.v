module hasioDecoder #(
	parameter DW=32,
	parameter PW=$clog2(1+DW+$clog2(1+DW))+1
	)(
	input [DW-1:0] data,
	input [PW-1:0] contro_hasio,
	output [DW-1:0] cdata,
	output [PW-1:0] contro_hasio_new,
	output secr,dede);

	wire [PW-1:0] con_new,con_xor;
	hasioCoder #(.DW(DW)) coder(.data(data),.contro_hasio(con_new));

	assign con_xor = con_new ^ contro_hasio;

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
	assign dede = |con_xor & ~^con_xor;
	assign contro_hasio_new = con_new;
endmodule