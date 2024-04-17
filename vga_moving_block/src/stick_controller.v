`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
    reg [9: 0] stickLen;
	
	parameter RED   = 12'b1111_0000_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = RED; 
		else	
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-stickLen) && vCount<=(ypos+2) && hCount>=(xpos-2) && hCount<=(xpos+2);
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
            stickLen <= 2;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			
			if(up) begin
                stickLen <= stickLen-2;
				if(stickLen == 216)
                    stickLen <= 2;
                    // game over
			end
		end
	end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;
		else 
			if(up)
				background <= 12'b0000_0000_1111; //blue
	end

	
	
endmodule
