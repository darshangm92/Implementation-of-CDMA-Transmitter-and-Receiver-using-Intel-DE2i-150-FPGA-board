module cdma(CLOCK_50,data,data_rec,data_rec1,signal_tx);
input[0:3] data;//data to be transmitted
reg [0:3]chip =4'b0011; //1st  TX/RX chip sequence
reg [0:3]chip1=4'b0100; //2nd TX/RX chip sequence

reg[1:0] out; // reg for spread value of 1st TX
reg[1:0] out1;// reg for spread value of 2nd TX
input CLOCK_50;

// counters
reg[31:0] i=0;
reg[31:0] j=0;
reg[31:0] m=0;
reg[31:0] count=0;
reg[31:0]sync=0; // variable for syncronization

wire signed [1:0] signal1; //signal from TX1 transmitted
wire signed [1:0] signal2; //signal from TX2 transmitted
output wire signed [2:0] signal_tx;//total signal moving through the channel

output wire  data_rec; // received data of TX1
output wire  data_rec1;// received data of TX2

// variables for the receiver section used for correlation and decoding
reg signed [2:0] despread=0;
reg signed [2:0] ndespread;
reg signed [2:0] despread1=0;
reg signed [2:0] ndespread1;

reg[1:0] positive_vol=2'b01;// positive voltage of 1 V
reg[1:0] negative_vol=2'b11;//negative voltage of -1V

/////Transmitter section//////
always@(posedge CLOCK_50)
begin
if(sync>1)
begin
out<=data[i]^chip[j]; //spread data of transmitter one  with chip sequence chip
out1<=data[i]^chip1[j];//spread data of transmitter two with chip sequence chip1
j<=j+1;
//performing bit wise xor with each data bit and the whole chip sequence to spread the signal
if(j>=3)
	begin
		i<=i+1;
		j<=0;
		if(i>=3)
			begin
				i<=0;
			end	
	end
end
else
begin
sync<=sync+1;
end
end
//transmitting the data bits as signals of +1 and -1 V
assign signal1=(out==0)?negative_vol:positive_vol; //1st signal tranmitting
assign signal2=(out1==0)?negative_vol:positive_vol;//2nd signal transmitting
assign signal_tx=signal1+signal2; //added signal transmitted over the channel


//////Receiver section//////////////
always@(posedge CLOCK_50)
begin
if(count>2)
begin
	despread<=(chip[m]==1)?(despread-(signal_tx)):(despread+(signal_tx)); //correlation of the received signals with the chip
	despread1<=(chip1[m]==1)?(despread1-(signal_tx)):(despread1+(signal_tx)); //correlation of the received signals with the chip
	m<=m+1;
	if(m>=3)
	begin
		ndespread<=despread; //finished correlation of received and chip send to decoding block
		ndespread1<=despread1;//finished correlation of received and chip1 send to decoding block
		despread<=0;
		despread1<=0;
		m<=0;
		
	end	
end
else
	count<=count+1;
end

//decoding of the data at each reciever with specific chip sequence
assign data_rec=(ndespread>0)?1'b1:1'b0; //decoding data of transmitter 1 with chip sequence "defined by Chip"
assign data_rec1=(ndespread1>0)?1'b1:1'b0;  // decoding data of transmitter 2 with chip sequence chip1

endmodule