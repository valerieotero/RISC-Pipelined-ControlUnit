`include "PPU.v"

module ppu_tb;

/* CPU Signals */
reg clk, Reset;


/* Modules instances */
//main PPU(clk, reset);


/*--------------------------------------  Toggle Clock  --------------------------------------*/

    initial #22 $finish; //finish simulation on tick 22

    initial begin

        clk = 1'b0; //before tick starts, clk=0

        repeat(22) #1 clk = ~clk; end  //enough repeats to read all instructions 

    /*--------------------------------------  Toggle Reset  --------------------------------------*/

    initial fork       

        Reset = 1'b1; //before tick starts, reset=0

        #2 Reset = 1'b0; //after two ticks, change value to 0                    
      
    join 
  
    initial begin
          
        $display("\n\n                    ------------------ID State-------------------            ------------------EX State------------------           --------MEM State------          -------WB State-------       -------Instruction-------");
        $display("         PC      B_instr | shift_imm |   alu  | load | R F | mem_r_w           shift_imm | alu  | load | R F | mem_r_w                load | R F | mem_r_w                load | R F              ");
        //$monitor("%d           %b   |     %b     |  %b  |  %b   |  %b  |  %b                      %b  | %b |   %b  |  %b  | %b                         %b |  %b  | %b                         %b |  %b             %b",  PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, WB_load_instr, WB_RF_Enable, DO_CU);

    end

endmodule