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
    wire scarf;

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
    reg [5:0] tens;
	reg [9:0] stickLen;
    reg [9:0] stickWidth;
    reg [9:0] moveDistance;
	reg stickGrowthFlag;
	reg gameOverFlag;
	reg fellFlag;

	//these two values dictate the bottom left of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] currxpos, currypos, currWidth, currHeight;
    reg [9:0] nextxpos, nextypos, nextWidth, nextHeight;
    reg [9:0] guyxpos, guyypos, guyWidth, guyHeight;
    reg [9:0] scarfxpos, scarfypos, scarfWidth, scarfHeight;

    reg [4:0] state;


    localparam
    INIT = 5'b00001, WAIT = 5'b00010, PLAY = 5'b00100, MOVE = 5'b01000, GAMEOVER = 5'b10000;

	parameter RED   = 12'b1111_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter BLACK = 12'b0000_0000_0000;
    parameter DARKRED = 12'b1001_0010_0011;
    parameter BLUE = 12'b0100_1000_1100;
	
	// color definitions for platforms, character+scarf, stick, and score
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
        else if ((state == GAMEOVER) && (fellFlag == 1))
            rgb = DARKRED;
		else if (block_fill) 
			rgb = 12'b1111_1100_1100; 
        else if (currPlatform || nextPlatform)
            rgb = 12'b1100_1100_1100;
        else if (scarf)
            rgb = RED;
		else if (lilGuy)
            rgb = BLACK;
        else if (tensA)
            if(((tens%10) != 1) && ((tens%10) != 4) && ((tens%10) != 6)) rgb = WHITE;
            else rgb=BLUE; 
        else if (tensB)
            if(((tens%10) != 5) && ((tens%10) != 6)) rgb = WHITE;
            else rgb=BLUE;
        else if (tensC)
            if((tens%10) != 2) rgb = WHITE;
            else rgb = BLUE;
        else if (tensD)
            if(((tens%10) != 1) && ((tens%10) != 4) && ((tens%10) != 7) && ((tens%10) != 9)) rgb = WHITE;
            else rgb = BLUE;
        else if (tensE)
            if(((tens%10) == 2) || ((tens%10) == 6) || ((tens%10) == 8) || ((tens%10) == 0)) rgb = WHITE;
            else rgb = BLUE;
        else if (tensF)
            if(((tens%10) != 1) && ((tens%10) != 2) && ((tens%10) != 3) && ((tens%10) != 7)) rgb = WHITE;
            else rgb = BLUE;
        else if (tensG)
            if(((tens%10) != 0) && ((tens%10) != 1) && ((tens%10) != 7)) rgb = WHITE;
            else rgb = BLUE;
        else if (onesA)
            if(((score%10) != 1) && ((score%10) != 4) && ((score%10) != 6)) rgb = WHITE;
            else rgb=BLUE;       
        else if (onesB)
            if(((score%10) != 5) && ((score%10) != 6)) rgb = WHITE;
            else rgb=BLUE;
        else if (onesC)
            if((score%10) != 2) rgb = WHITE;
            else rgb = BLUE;
        else if (onesD)
            if(((score%10) != 1) && ((score%10) != 4) && ((score%10) != 7) && ((score%10) != 9)) rgb = WHITE;
            else rgb = BLUE;
        else if (onesE)
            if(((score%10) == 2) || ((score%10) == 6) || ((score%10) == 8) || ((score%10) == 0)) rgb = WHITE;
            else rgb = BLUE;
        else if (onesF)
            if(((score%10) != 1) && ((score%10) != 2) && ((score%10) != 3) && ((score%10) != 7)) rgb = WHITE;
            else rgb = BLUE;
        else if (onesG)
            if(((score%10) != 0) && ((score%10) != 1) && ((score%10) != 7)) rgb = WHITE;
            else rgb = BLUE;
        else
			rgb=BLUE;
	end


        // graphics dimensions assignments!
	    assign block_fill = vCount>=(ypos-stickLen) && vCount<=(ypos) && hCount>=(xpos) && hCount<=(xpos+stickWidth);
        assign lilGuy = vCount>=(guyypos-guyHeight) && vCount<=(guyypos) && hCount>=(guyxpos) && hCount<=(guyxpos+guyWidth);
        assign currPlatform = vCount>=(currypos-currHeight) && vCount<=(currypos) && hCount>=(currxpos) && hCount<=(currxpos+currWidth);
        assign nextPlatform = vCount>=(nextypos-nextHeight) && vCount<=(nextypos) && hCount>=(nextxpos) && hCount<=(nextxpos+nextWidth);
        assign scarf = vCount>=(scarfypos-scarfHeight) && vCount<=(scarfypos) && hCount>=(scarfxpos) && hCount<=(scarfxpos+scarfWidth);

        assign tensA = vCount>=(38) && vCount<=(40) && hCount>=(744) && hCount <= (752);
        assign tensB = vCount>=(40) && vCount<=(48) && hCount>=(752) && hCount<=(754);
        assign tensC = vCount>=(50) && vCount<=(58) && hCount>=(752) && hCount<=(754);
        assign tensD = vCount>=(58) && vCount<=(60) && hCount>=(744) && hCount<=(752);
        assign tensE = vCount>=(50) && vCount<=(58) && hCount>=(742) && hCount<=(744);
        assign tensF = vCount>=(40) && vCount<=(48) && hCount>=(742) && hCount<=(744);
        assign tensG = vCount>=(48) && vCount<=(50) && hCount>=(744) && hCount<=(752);

        assign onesA = vCount>=(38) && vCount<=(40) && hCount>=(760) && hCount <= (768);
        assign onesB = vCount>=(40) && vCount<=(48) && hCount>=(768) && hCount<=(770);
        assign onesC = vCount>=(50) && vCount<=(58) && hCount>=(768) && hCount<=(770);
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

            scarfxpos <= 378;
            scarfypos <= 340;
            scarfWidth<= 19;
            scarfHeight<= 2;

            currxpos <= 200;
            currypos <= 515;
            currWidth <= 200;
            currHeight <= 150;

            nextxpos <= 500;
            nextypos <= 515;
            nextWidth <= 200;
            nextHeight <= 150;

            // initialize flags
			stickLen<=4;
            stickWidth<=4;
            moveDistance<=0;
			stickGrowthFlag <= 0;
			gameOverFlag <= 0;
			fellFlag <= 0;
            score <= 0;
            tens <= 0;

		end
		else
            case(state)
                INIT: // define stick boundaries + flag, straight to WAIT state
                    begin 
                        state <= WAIT;
                        stickLen<=4;
                        stickWidth<=4;
                        stickGrowthFlag<=0;
                    end
                WAIT:
                    begin
                    if(up) state <= PLAY; // button pressed, go to PLAY to grow stick
                    else begin
                            // placement for guy, stick, and scarf
                            xpos<=395;
			                ypos<=345;
                            guyxpos <= 380;
                            guyypos<=365;
                            guyWidth <= 15;
                            guyHeight <= 30;
                            scarfxpos <= 378;
                            scarfypos <= 340;
                            scarfWidth<= 19;
                            scarfHeight<= 2;

                            // placement for curr platform
                            if (score == 0) begin
                                currxpos <= 200;
                                currypos <= 515;
                                currWidth <= 200;
                                currHeight <= 150;
                            end
                            else begin // define currPlatform dimensions as previous nextPlatform dimensions
                                currWidth <= 200-(((score-1)%5)*35);
                                currHeight <= 150;
                                currxpos <= (guyxpos+20) - nextWidth - 35; // <-- platform bug probably here
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
				        stickLen <= stickLen+1; // grow stick while button pressed
			        end

			        else begin // up button released, drop stick
			            if(stickGrowthFlag) begin
                            state <= MOVE;
			                stickGrowthFlag <= 0;
                            moveDistance <= stickLen;
                            ypos <= 365;
                            stickLen <= stickWidth; // rotate stick 90 degrees
                            stickWidth <= stickLen;
			            end
			        end

                MOVE:
                    begin
                    // logic to determine if about to lose :()
                    if(stickWidth < (nextxpos - xpos))
                        begin
                            gameOverFlag <= 1;
                        end
                    else if (stickWidth > ((nextxpos+nextWidth)-xpos))
                        begin
                            gameOverFlag <= 1;
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
                            // update score + tens for score display
                            score <= score+1; 
                            if((score+1) == 10) tens<=1;
                            else if((score+1) == 20) tens <=2;
                            else if((score+1) == 30) tens <=3;
                            else if((score+1) == 40) tens <=4;
                            else if((score+1) == 50) tens <=5;
                            else if((score+1) == 60) tens <=6;
                            else if((score+1) == 70) tens <=7;
                            else if((score+1) == 80) tens <=8;
                            else if((score+1) == 90) tens <=9;
                            else if((score+1) == 100) tens <=0;
                            state <= WAIT;
                        end
                        end
                    end
                    end

                GAMEOVER: 
                    begin // lil guy gonna fall and then screen turn red
                        if (scarfypos < 515) scarfypos <= scarfypos+4;
                        else scarfHeight <= 0;

                        if (guyypos < 515) guyypos <= guyypos+4;
                        else if (guyHeight > 4) guyHeight <= guyHeight-4;
                        else begin
                        guyHeight <= 0;
                        fellFlag<=1;
                        end
                    end
           endcase
        end

endmodule
