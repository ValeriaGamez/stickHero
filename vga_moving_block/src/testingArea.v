`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
    wire currPlatform;
    wire nextPlatform;
    wire lilGuy;

    wire tensA;
    wire tensB;
    wire tensC;
    wire tensD;
    wire tensE;
    wire tensF;
    wire tensG;

    wire onesA;
    wire onesB;
    wire onesC;
    wire onesD;
    wire onesE;
    wire onesF;
    wire onesG;

    reg [5:0] score;
	reg [9:0] stickLen;
    reg [9:0] stickWidth;
    reg [9:0] moveDistance;
	reg stickGrowthFlag;
	reg gameOverFlag;

	//these two values dictate the bottom left of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] currxpos, currypos, currWidth, currHeight;
    reg [9:0] nextxpos, nextypos, nextWidth, nextHeight;
    reg [9:0] guyxpos, guyypos, guyWidth, guyHeight;

    reg [4:0] state;

    integer seed;

    localparam
    INIT = 5'b00001, WAIT = 5'b00010, PLAY = 5'b00100, MOVE = 5'b01000, GAMEOVER = 5'b10000;

	parameter RED   = 12'b1111_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = 12'b1111_1100_1100; 
        else if (currPlatform || nextPlatform)
            rgb = 12'b1100_1100_1100;
		else if (lilGuy)
            rgb = 12'b0000_1111_1111;
        else if (tensA)
            if(score < 10) rgb=WHITE;
            else rgb=background;
        else if (tensB)
            if(((score%10) != 5) && ((score%10) != 6)) rgb = WHITE;
            else rgb=background;
        else if (tensC)
            if(score < 10) rgb=WHITE;
            else rgb=background;
        else if (tensD)
            if(score < 10) rgb=WHITE;
            else rgb=background;
        else if (tensE)
            if(score < 10) rgb=WHITE;
            else rgb=background;
        else if (tensF)
            if(score < 10) rgb=WHITE;
            else rgb=background;
        else if (tensG)
            if(score < 10) rgb=background;
            else rgb=background;
        else if (onesA)
            if(((score%10) != 1) && ((score%10) != 4) && ((score%10) != 6)) rgb = WHITE;
            else rgb=background;       
        else if (onesB)
            if(((score%10) != 5) && ((score%10) != 6)) rgb = WHITE;
            else rgb=background;
        else if (onesC)
            if((score%10) != 2) rgb = WHITE;
            else rgb = background;
        else if (onesD)
            if(((score%10) != 1) && ((score%10) != 4) && ((score%10) != 7) && ((score%10) != 9)) rgb = WHITE;
            else rgb = background;
        else if (onesE)
            if(((score%10) == 2) || ((score%10) == 6) || ((score%10) == 8) || ((score%10) == 0)) rgb = WHITE;
            else rgb = background;
        else if (onesF)
            if(((score%10) != 1) && ((score%10) != 2) && ((score%10) != 3) && ((score%10) != 7)) rgb = WHITE;
            else rgb = background;
        else if (onesG)
            if(((score%10) != 0) && ((score%10) != 1) && ((score%10) != 7)) rgb = WHITE;
            else rgb = background;


        else
			rgb=background;
	end
        // graphics assignments!
	    assign block_fill = vCount>=(ypos-stickLen) && vCount<=(ypos) && hCount>=(xpos) && hCount<=(xpos+stickWidth);
        assign lilGuy = vCount>=(guyypos-guyHeight) && vCount<=(guyypos) && hCount>=(guyxpos) && hCount<=(guyxpos+guyWidth);
        assign currPlatform = vCount>=(currypos-currHeight) && vCount<=(currypos) && hCount>=(currxpos) && hCount<=(currxpos+currWidth);
        assign nextPlatform = vCount>=(nextypos-nextHeight) && vCount<=(nextypos) && hCount>=(nextxpos) && hCount<=(nextxpos+nextWidth);

        assign tensA = vCount>=(38) && vCount<=(40) && hCount>=(744) && hCount <= (752);
        assign tensB = vCount>=(40) && vCount<=(48) && hCount>=(752) && hCount<=(754);
        assign tensC = vCount>=(50) && vCount<=(58) && hCount>=(752) && hCount<=(754);
        assign tensD = vCount>=(58) && vCount<=(60) && hCount>=(744) && hCount<=(752);
        assign tensE = vCount>=(50) && vCount<=(58) && hCount>=(742) && hCount<=(744);
        assign tensF = vCount>=(40) && vCount<=(48) && hCount>=(742) && hCount<=(744);
        assign tensG = vCount>=(48) && vCount<=(50) && hCount>=(744) && hCount<=(752);

        assign onesA = vCount>=(38) && vCount<=(40) && hCount>=(760) && hCount <= (768);
        assign onesB = vCount>=(40) && vCount<=(48) && hCount>=(768) && hCount<=(770);
        assign onesC = vCount>=(50) && vCount<=(58) && hCount>=(768) && hCount<=(768);
        assign onesD = vCount>=(58) && vCount<=(60) && hCount>=(760) && hCount<=(768);
        assign onesE = vCount>=(50) && vCount<=(58) && hCount>=(758) && hCount<=(760);
        assign onesF = vCount>=(40) && vCount<=(48) && hCount>=(758) && hCount<=(760);
        assign onesG = vCount>=(48) && vCount<=(50) && hCount>=(760) && hCount<=(768);

	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
            state <= INIT;
			// initialize vector placement
			xpos<=395;
			ypos<=345;

            guyxpos <= 380;
            guyypos<=365;
            guyWidth <= 15;
            guyHeight <= 30;

            currxpos <= 200;
            currypos <= 515;
            currWidth <= 200;
            currHeight <= 150;

            nextxpos <= 500;
            nextypos <= 515;
            nextWidth <= 200;
            nextHeight <= 150;

			stickLen<=4;
            stickWidth<=4;
            moveDistance<=0;
			stickGrowthFlag <= 0;
			gameOverFlag <= 0;
            score <= 0;

		end
		else
            case(state)
                INIT:
                    begin
                        state <= WAIT;
                        stickLen<=4;
                        stickWidth<=4;
                        stickGrowthFlag<=0;
                    end
                WAIT:
                    begin
                    if(up) state <= PLAY;
                    else begin
                            xpos<=395;
			                ypos<=345;

                            guyxpos <= 380;
                            guyypos<=365;
                            guyWidth <= 15;
                            guyHeight <= 30;
                            if (score == 0) begin
                                currxpos <= 200;
                                currypos <= 515;
                                currWidth <= 200;
                                currHeight <= 150;
                            end
                            else begin
                                currWidth <= 200-(((score-1)%5)*35);
                                currHeight <= 150;
                                currxpos <= (guyxpos+20) - nextWidth - 35;
                                currypos <= 515;
                            end

                            // range platform width from 20-200 and xpos from 500-580
                            nextxpos <= ((score%5)*20)+500;
                            nextypos <= 515;
                            nextWidth <= 200-((score%5)*35);
                            nextHeight <= 150;

			                stickLen<=4;
                            stickWidth<=4;
                            moveDistance<=0;
                        end
                    end

                PLAY:
        			if(up) begin // up button pressed, grow stick
                        if(stickGrowthFlag == 0) begin // reset stick dimensions
        
                            stickGrowthFlag<=1;
                        end
				        stickLen <= stickLen+1;
			        end

			        else begin // up button released, drop stick
			            if(stickGrowthFlag) begin
                            state <= MOVE;
			                stickGrowthFlag <= 0;
                            moveDistance <= stickLen;
                            ypos <= 365;
                            stickLen <= stickWidth;
                            stickWidth <= stickLen;
			            end
			        end

                MOVE:
                    begin
                    if(stickWidth < (nextxpos - xpos))
                        begin
                            gameOverFlag <= 1;
                            background <= 12'b1111_0000_0000;
                        end
                    else if (stickWidth > ((nextxpos+nextWidth)-xpos))
                        begin
                            gameOverFlag <= 1;
                            background <= 12'b1111_0000_1111;
                        end
                    


                    // GAME OVER MVMT 
                    if (gameOverFlag) begin
                    if(moveDistance > 0) begin
                        moveDistance <= moveDistance-1;
                        if(currxpos>144) currxpos <= currxpos-1;
                        else if (currWidth > 0) currWidth <= currWidth-1;

                        if (xpos > 144) xpos <= xpos-1;
                        else stickWidth <= stickWidth-1;

                        if (nextxpos > 144) nextxpos <= nextxpos-1;
                        else if (nextWidth > 0) nextWidth <= nextWidth-1;
                    end
                    else begin
                        state <= GAMEOVER;
                        gameOverFlag <= 0;
                    end
                    end
                    else begin


                    // GAME CONT MVMT
                    // move platforms left
                    if(currxpos > 144) currxpos <= currxpos-1;
                    else if (currWidth > 0) currWidth <= currWidth - 1;

                    if (xpos > 144) xpos <= xpos-1;
                    else stickWidth <= stickWidth-1;

                    if ((nextxpos+nextWidth) > (guyxpos+20)) nextxpos <= nextxpos-1;
                    else // movement done, make new platform!
                        begin
                        if (gameOverFlag) begin
                            state <= GAMEOVER;
                            gameOverFlag <= 0;
                        end
                        else begin
                            score <= score+1;
                            state <= WAIT;
                        end
                        end
                    end
                    end

                GAMEOVER: 
                    begin
                        if (guyypos < 515) guyypos <= guyypos+4;
                        else if (guyHeight > 4) guyHeight <= guyHeight-4;
                        else begin
                        guyHeight <= 0;
                        state <= INIT;
                        // display score
                        end
                    end
           endcase
        end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b0000_0000_0011;
	end

	
	
endmodule