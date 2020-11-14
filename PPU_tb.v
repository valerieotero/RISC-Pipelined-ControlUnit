`include "PPU2.v"

module ppu_tb;

/* PPU Signals */
reg clk, Reset;

/* Modules instances */
main PPU(clk, Reset);


/*--------------------------------------  Toggle Clock  --------------------------------------*/

    initial #18 $finish; //finish simulation on tick 22

    initial begin

        clk = 1'b0; //before tick starts, clk=0

        repeat(18) #1 clk = ~clk; end  //enough repeats to read all instructions 

/*--------------------------------------  Toggle Reset  --------------------------------------*/

    initial fork       

        Reset = 1'b1; //before tick starts, reset=0

        #1 Reset = 1'b0; //after two ticks, change value to 0                    
      
    join   
  
endmodule