module  Signal_generator(
				 CLOCK_50 ,
				 signal,data,data_rec,data_rec1
					);
input CLOCK_50 ;
//input signal ;
output [15:0] signal;
input[0:3]data;
output[3:0]data_rec;
output[3:0]data_rec1;

//Signal generator elements
//reg [7:0]sinAddr;
//reg [15:0]sine;
//reg [255:0] val_cap;

//Variables to hold captured values

reg [15:0] signal; //i=0; //vector with values of ROM
reg [31:0] i;

cdma cdma_ins(CLOCK_50,data,data_rec,data_rec1);

always@(posedge CLOCK_50)
begin
signal <=data_rec;
end	
endmodule


