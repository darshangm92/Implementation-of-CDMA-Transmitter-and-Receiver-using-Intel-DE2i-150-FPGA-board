module oscilloscope(  
       CLOCK_50,
		signal,
      oVGA_CLK,
		oVS,
         oHS,
		    	oBLANK_n	,
                    b_data,  
                    	g_data,
                    	r_data);

input CLOCK_50;
input [15:0] signal;
output oVGA_CLK ;
output oVS;
output oHS;
output oBLANK_n;
output reg [7:0] b_data;
output reg [7:0] g_data;  
output reg [7:0] r_data;  
wire [15:0] signal_tx;                   

// Variables for VGA Clock 
reg vga_clk_reg ;                   
wire [16:0] iVGA_CLK;

// CHECK THIS OUT
//parameter ivga_CLK=25;

//Variables for (x,y) coordinates VGA
wire [10:0] CX;
wire [9:0] CY;

//Oscilloscope parameters
	//Horizontal
	parameter DivX= 10.0;  				// number of horizontal division
	parameter Ttotal=0.000025;   		// total time represented in the screen
	parameter pixelsH=640.0;  		// number of horizontal pixels
	parameter IncPixX= 0.05;				// totaltime/#pixels - time between two consecutive pixels
	//Amplitude
	parameter DivY= 8.0;  					// number of vertical divisions
	parameter Atotal=16.0;				// total volts represented in the screen
	parameter pixelsV=480.0;  			// number of vertical pixels	
	parameter IncPixY=Atotal/(pixelsV-1.0);	// volts between two consecutive pixels

// Sinusoidal wave amplitude	
parameter Amp=2.0;					// maximum amplitude of sinusoidal wave [-Amp, Amp]
parameter integer Apixels=Amp/IncPixY;	// number of pixels to represent the maximum amplitude	

//Vector to store the input signal (Section 6.1)
parameter integer nc=0.75;						
reg [15:0] capturedVals [63:0]; 		// vector with values of input signal
reg [31:0] i=0;							// index of the vector

//Read the signal values from the vector (Section 6.2)
reg [31:0] j ; 								// read the correct element of the vector
parameter integer nf=1; //(nc*256)/640 					//Vector points between two consecutive pixels 

//Value of the current pixel (Section 6.2 and 6.3)
reg [9:0] ValforVGA; 
reg [9:0] oldValforVGA; 

//////////////////////////////////////////////////////////////////////////////////////////
reg [6:0] counter;
reg [1:0]counter_ini;
// 25 MHz clock for the VGA clock

always @(posedge CLOCK_50)
begin
	vga_clk_reg = ~(vga_clk_reg);
	
end
assign iVGA_CLK = vga_clk_reg ;

assign oVGA_CLK = ~(iVGA_CLK);


// instance VGA controller

VGA_Controller VGA_ins( .reset(1'b0),
                        .vga_clk(iVGA_CLK),
                        .BLANK_n(oBLANK_n),
                       	.HS(oHS),
						.VS(oVS),
				 	    .CoorX(CX),
					    .CoorY(CY)
					);
						

// Store input signal in a vector (Section 6.1)			

always@(negedge CLOCK_50)
begin

	capturedVals[i]<=signal;
		if (i==63)
			begin
				i<=32'd0;
			end
		else
			begin
				i<=i+1;
			end


end

// Read the correct point of the signal stored in the vector and calculate the pixel associated given the amplitude and the parameters of the oscilloscope (Section 6.2)
always@(posedge iVGA_CLK)

		begin
			if (oBLANK_n == 1'd1) 
				begin
					ValforVGA <= 239+Apixels-((capturedVals[j]*2*Apixels));
					//ValforVGA <= j*100;
					if(counter==63)
					begin
						counter<=0;
						if (j >=63) 
							begin
								j <= 32'd0;
							end
						else
							begin
								j <= j+ 4;
							end
					end
					else
					begin
						counter<=counter+1;
					end
				end	
			else	
				begin 
					j<=8;
				end
		
	end
// Calculate the RGB values

always@(negedge iVGA_CLK)
begin
	oldValforVGA <= ValforVGA;
	if (CY==ValforVGA)
	begin
		b_data <= 8'b00000000;
		g_data <= 8'b00000000;
		r_data <= 8'b11111111; //select this color to display the signal
	end
	else if (CY < ValforVGA && CY > oldValforVGA)
	begin
		b_data <= 8'b00000000;
		g_data <= 8'b00000000;
		r_data <= 8'b11111111;
	end
	//connect points with vertical lines (old value > current value)
	else if (CY > ValforVGA && CY < oldValforVGA)
	begin
		b_data <= 8'b00000000;
		g_data <= 8'b00000000;
		r_data <= 8'b11111111;
	end

	//display the vertical guide lines
	 else if (CY==59 || CY==119 || CY==179 || CY==239 || CY== 299 || CY==359 || CY== 419 || CY==479 )
		begin
		b_data<=8'b11111111;
		g_data<=8'b11111111;  
		r_data<=8'b11111111; 
		end
	//display the horizontal guide lines
	else if (CX==63 || CX==127 || CX==191 || CX==255 || CX==319 || CX==383 || CX==447 || CX==511 || CX==576 || CX==639 )
		begin
		 b_data<=8'b11111111; //
		 g_data<=8'b11111111;  
		 r_data<=8'b11111111; 
		end
	//Everything else is black
	else
		begin
		b_data<=8'b00000000;
		g_data<=8'b00000000;  
		r_data<=8'b00000000; 
		end
end

endmodule
