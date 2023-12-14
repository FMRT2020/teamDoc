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