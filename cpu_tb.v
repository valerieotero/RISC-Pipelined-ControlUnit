`include "PPU.v"

module PPU_tb;

    
    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg clk = 1'b1;
    reg [31:0] Address; wire [31:0] DataOut;

    main PPU(clk);
    inst_ram256x8 ram1 (DataOut, Address);

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

    /*-------------------------------------- Clock --------------------------------------*/
 
    
    initial begin
        repeat(37) //9instr x 4pipelines = 36 + 1 = 37
         begin
            #1 clk = 1'b1;
            #1 clk = 1'b0;           
         end
    end
endmodule