module cdma_top(CLOCK_50,
                         VGA_CLK,
                         VGA_VS,
                         VGA_HS,
			         VGA_BLANK_n,
                         VGA_B,
                         VGA_G,
                         VGA_R,data,data_rec,data_rec1);
input CLOCK_50 ;
output VGA_CLK;
output VGA_VS;
output VGA_HS;
output VGA_BLANK_n;
output wire [7:0] VGA_B ;
output wire [7:0] VGA_G;  
output wire [7:0] VGA_R;                        
input[0:3] data;
output[1:1] data_rec;
output[1:1] data_rec1;
//wire [2:0] signal_tx;
//wire [15:0] signal;
wire VGA_BLANK_n,VGA_HS,VGA_VS, VGA_CLK;

////////////////////////////////////////////
//wire to hold the signal
wire [15:0] ValSignal;

//////////CDMA instance//////////////////
//cdma cdma(.CLOCK_50(CLOCK_50),.data(data),.data_rec(data_rec),.data_rec1(data_rec1),.signal_tx(signal_tx));


///////////////////////////////////////////
// signal_generator instance

Signal_generator sig_ins(.CLOCK_50(CLOCK_50),
						 .signal(ValSignal),.data(data),
						 .data_rec(data_rec),.data_rec1(data_rec1));

/////////////////////////////////////////////
//oscilloscope instance
oscilloscope osc_ins(.CLOCK_50(CLOCK_50),
					 .signal(ValSignal),
					 .oVGA_CLK(VGA_CLK),
					 .oVS(VGA_VS),
                     .oHS(VGA_HS),
		    	     .oBLANK_n(VGA_BLANK_n),
                     .b_data(VGA_B),  
                     .g_data (VGA_G),
                     .r_data(VGA_R)
					 );
						

endmodule