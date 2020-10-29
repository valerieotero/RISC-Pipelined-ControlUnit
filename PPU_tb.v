`include "PPU.v"
module PPU_tb;

    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg Enable;
    reg [31:0] Address; wire [31:0] DataOut;

    inst_ram256x8 ram1 (DataOut, Enable, Address );

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

    initial begin
        fw = $fopen("ramintr_content.txt", "w");
        Enable = 1'b0; 
        Address = #1 32'b00000000000000000000000000000000; //make sure adress is in 0 after precharge
        repeat (9) begin
        #5 Enable = 1'b1;
        #5 Enable = 1'b0;
        Address = Address + 4;
    end
    $finish;
    end
    always @ (posedge Enable)
        begin
        #1;   
        $fdisplay(fw,"Data en %d = %b %d", Address, DataOut, $time);
    end


    /*-------------------------------------- STATUS REGISTER --------------------------------------*/
    reg clk = 1;
    reg [3:0] cc_in;
    wire [3:0] cc_out;
    reg S = 0;
    
    initial begin
        cc_in = 4'b1111;
        #20;
        
        $display("\n\n STATUS REGISTER");

        $display("\nCC in = %b", stat.cc_in);
        $display("CC out = %b", stat.cc_out);
        $display("S = %d", stat.S);
        $display("Clk = %d\n\n", stat.clk);

    end

    Status_register stat(cc_in, S, cc_out, clk);

    
    
    /*-------------------------------------- CONDITION ASSERTED AND HANDLER --------------------------------------*/
    reg [3:0] instr_condition;
    wire choose_ta_r_nop;
    reg b_instr;

    initial begin
        // N, Z, C, V
        cc_in = 4'b0011; // in register
        instr_condition = 4'b1011; // [31:28] instr
        b_instr = 1;

        #20;
        $display("\n\n CONDITION ASSERT & HANDLER");

        $display("\nCC in = %b", assert.cc_in);
        $display("instruction condition = %b", assert.instr_condition);
        $display("condition asserted? = %d", assert.asserted);
        $display("Branch? = %d", ch.b_instr);
        $display("Condition Handler = %d\n", ch.choose_ta_r_nop);


    end

    Cond_Is_Asserted assert(cc_in, instr_condition, asserted);
    Condition_Handler ch(asserted, b_instr, choose_ta_r_nop);




endmodule