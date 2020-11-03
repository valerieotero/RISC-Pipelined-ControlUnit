`include "PPU.v"

module PPU_tb;

    
    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg clk = 1;
    reg [31:0] Address; wire [31:0] DataOut;

    //main PPU(clk);
    inst_ram256x8 ram1 (DataOut, Address);

    initial
        begin
        file = $fopen("ramintr.txt","rb");
        Address = 32'b0;
            while (!$feof(file)) begin //while not the end of file
            code = $fscanf(file, "%b", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
        end

    $fclose(file);  
    end

    /*-------------------------------------- Clock --------------------------------------*/

    main PPU(.clk(clk));
    
        initial       
            begin 
            Address = #1 32'b00000000000000000000000000000000; //make sure adress is in 0 after precharge
            clk = 0;
            end

            always
              #1
              clk = ~clk;
        endmodule
