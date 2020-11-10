`include "PPU.v"

module cpu_tb;

/* CPU Signals */
reg clk, reset;

/* Instruction RAM Signals */
integer file, fw, code, i; reg [31:0] data;
reg [31:0] Address; wire [31:0] DataOut;

/* Modules instances */
main PPU(clk, reset);
inst_ram256x8 ram1 (DataOut, Address, reset);


/*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

initial
    begin
    file = $fopen("ramintr.txt","rb");
    Address = 32'b00000000000000000000000000000000;
        while (!$feof(file)) begin //while not the end of file
        code = $fscanf(file, "%b", data);
        ram1.Mem[Address] = data;
        Address = Address + 1;
    end

$fclose(file);  
end

Address = #1 32'b00000000000000000000000000000000; //make sure adress starts back in 0 after precharge


/*--------------------------------------  Toggle Reset  --------------------------------------*/

 initial begin
    clk = 1'b0;
    reset = 1'b1;
    #30 $finish;
  end


/*--------------------------------------  Toggle Clock  --------------------------------------*/

 always begin
    #1 clk = ~clk; reset = 1'b0;
  end


endmodule