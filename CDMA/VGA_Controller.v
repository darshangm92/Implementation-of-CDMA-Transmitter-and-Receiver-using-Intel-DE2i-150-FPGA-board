module VGA_Controller(reset,
                      		     vga_clk,
                      		     BLANK_n,
                      		     HS,
                      		     VS,
		    		     CoorX,
		     		     CoorY);
                            
input reset;
input vga_clk;
output reg BLANK_n;
output reg HS;
output reg VS;
output [10:0] CoorX;
output [9:0] CoorY;

///////////////////
/*
--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line
--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line
*////////////////////////////////////////////
////////////////////////                       

   
//Resoultion: 640x480

parameter hori_line  =800;       //Total number of clock period in a line including the visible and not visible                
parameter hori_back  =48;
parameter hori_front = 16;
parameter vert_line  =525;      //Total number of lines in a frame including the visible and not visible
parameter vert_back  = 33;
parameter vert_front = 10;
parameter H_sync_cycle =96 ;
parameter V_sync_cycle =2 ;

//////////////////////////

reg  [10:0] h_cnt;
reg  [9:0] v_cnt;
wire cHD,cVD,cDEN,hori_valid,vert_valid;

////////////////////////
//Calculate CoorX and CoorY

assign CoorX  = (h_cnt<(hori_line-hori_front)&& h_cnt>=hori_back+H_sync_cycle ) ? h_cnt-hori_back-H_sync_cycle : 11'd640;

assign CoorY  = (v_cnt<(vert_line-vert_front)&& v_cnt>=vert_back+V_sync_cycle) ? v_cnt-vert_back-V_sync_cycle : 10'd480; 

//////////////////////////
//Calculate H_count and v_count

always@(negedge vga_clk,posedge reset)
begin
  if (reset)
  begin
     h_cnt<=11'd0;
     v_cnt<=10'd0;
  end
    else
    begin
      if (h_cnt==hori_line-1)
      begin 
         h_cnt<=11'd0;
         if (v_cnt==vert_line-1)
            v_cnt<=10'd0;
         else
            v_cnt<=v_cnt+1;
      end
      else
         h_cnt<=h_cnt+1;
    end
end

////////////////
//Calculate HS and VS

assign cHD = (h_cnt<H_sync_cycle)?1'b0:1'b1;
assign cVD = (v_cnt<V_sync_cycle)?1'b0:1'b1;

///////////////////
//Calculate BLANK_N

assign hori_valid = (h_cnt<(hori_line-hori_front)&& h_cnt>=hori_back+H_sync_cycle)? 1'b1:1'b0 ;
assign vert_valid = (v_cnt<(vert_line-vert_front)&& v_cnt>=vert_back+V_sync_cycle)? 1'b1:1'b0 ;

assign cDEN = (hori_valid && vert_valid);

//////////////
//Update values

always@(negedge vga_clk)
begin
  HS<=cHD;
  VS<=cVD;
  BLANK_n<=cDEN;
end

endmodule
