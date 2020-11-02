`include "PPU.v"

module PPU_tb;

    // ppu UUT(clk);
    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg Enable;
    reg [31:0] Address; wire [31:0] DataOut;

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
        #25;
        // clk = 1'b0;
        //S = 1'b0;
    
        repeat (2)begin
            $display("\n\n STATUS REGISTER");

            $display("\nCC in = %b", stat.cc_in);
            $display("CC out = %b", stat.cc_out);
            $display("S = %d", stat.S);
            $display("Clk = %d\n\n", stat.clk);
            
            S = S + 1'b1;
            clk = 0;
        end
        // S = S + 1'b1;

    end

    Status_register stat(cc_in, S, cc_out, clk);

    
    
    /*-------------------------------------- CONDITION ASSERTED AND HANDLER --------------------------------------*/
    reg [31:0] instr;
    reg [3:0] instr_condition;
    wire choose_ta_r_nop;
    reg b_instr;

    initial begin
        instr = 32'b11011011000000000000000000000001;
        // N, Z, C, V
        cc_in = 4'b0011; // in register
        instr_condition = instr[31:28]; // [31:28] instr
        if(instr[27:25] == 3'b101)
            b_instr = 1;
        else
            b_instr = 0;
        
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


    /*-------------------------------------- 4*SEXTENDER  --------------------------------------*/
    wire [31:0] SEx4_o;
    reg [31:0] instr1;
    reg [23:0] instr2;


    initial begin
        // if(b_instr == 1 && instr[24] == 1)
            // SExtender se(instr, SEx4_out);
        instr1 = 32'b11011011000000000000000000000001;
        instr2 = instr1[23:0];

        #20;
        $display("\instruction = %b", instr2);
        $display("instruction extended = %b", SEx4_o);

    end

    SExtender set(instr2, SEx4_o);
    /* ---------------------------------- CONTORL UNIT ----------------------------------------------  */

    wire ID_B_instr;
    wire MemReadWrite;
    wire [6:0] C_U_out;
    //reg  clk;
    reg [31:0] ID_Bit31_0;

    initial begin
        #40;
        ID_Bit31_0 = 32'b11011011000000000000000000000001;

        $display("\nID_B = %b", control_unit.ID_B_instr);
        $display("MemRW = %b", control_unit.MemReadWrite);
        $display("ID_shift_imm = %b", control_unit.C_U_out[6]);
        $display("ID_alu= %b", control_unit.C_U_out[5:2]);
        $display("ID_load = %b", control_unit.C_U_out[1]);
        $display("ID_RF= %b", control_unit.C_U_out[0]);
        $display("Instruction= %b", ID_Bit31_0);
    end

    control_unit control_unit(ID_B_instr, MemReadWrite, C_U_out, clk, ID_Bit31_0);

endmodule