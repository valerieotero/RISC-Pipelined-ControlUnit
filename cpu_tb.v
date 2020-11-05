`include "PPU.v"

module PPU_tb;

    
    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg clk = 1;
    reg [31:0] Address; wire [31:0] DataOut;
    reg [31:0] PCO = 32'b0; //address instr Mem


    //Inputs 
    // reg clk; //enable


    //wire 
    //ALU_IF && IF_ID_pipeeline
    wire [31:0] DO; // = 32'b11100000100000100101000000000101;
    wire [31:0] DAO; // = 32'b11100000100000100101000000000101;
    wire [31:0] Next_PC, PC4, MEM_A_O, MEM_MUX3; //, DAO; 

    wire [23:0] ID_Bit23_0;
    wire [3:0] ID_Bit19_16, ID_Bit3_0;
    wire [3:0] ID_Bit31_28, cc_alu_1;
    wire [3:0] ID_Bit15_12, cc_main_alu_out;
    wire [11:0] ID_Bit11_0;
    wire [31:0] EX_Bit11_0, EX_MUX_2X1_OUT;
    wire choose_ta_r_nop;
    wire IF_ID_Load; // = 1; // load pipeline viene de hazard unit
               
    //register file
    wire [31:0] PA; // = 32'd6;
    wire [31:0] PB; // = 32'd7; 
    wire [31:0] PD; // = 32'd9; 
    wire [31:0] PW; // = 32'd17; // = 32'b0;

    wire [31:0] PCin; // = 32'd4;
    wire [3:0] WB_Bit15_12_out; // = 4'b0; // registro destino valor del WB
    wire [3:0] SD; //ID_Bit19_16, ID_Bit3_0, SD;
    wire RFLd; // = 1;
    wire PC_RF_ld; // = 1; //load pc viene de Hazard unit

    //multiplexers 4x2
    wire [31:0] A_O; // = 32'd15;
    wire [31:0] M_O; // = 32'd16;
    // wire [31:0] PB = 32'd7; 
    wire [31:0] mux_out_1, mux_out_2, mux_out_3, Data_RAM_Out, WB_A_O, WB_Data_RAM_Out; //PA, PB, PD,PW,
    wire [1:0] MUX1_signal;
    wire Size; 
    wire MEM_mem_size;// = 2'b00;
    wire [1:0] MUX2_signal;// = 2'b01;
    wire [1:0] MUX3_signal;// = 2'b10;

    //Target Address
    wire [31:0] SEx4_out, TA, PCI;
    wire [3:0] cc_alu_2;

    //Hazard Unit
    wire MUXControlUnit_signal; 
    wire EX_load_instr,  WB_load_instr,  MEM_load_instr; 
    wire S = 1; 
    wire MEM_RF_Enable, WB_mem_read_write;
    wire WB_RF_Enable;
    wire [3:0] EX_Bit15_12, cc_out;
    wire [3:0] MEM_Bit15_12;
    wire [3:0] WB_Bit15_12; 

    //ID_EX
    wire [31:0] mux_out_1_A, mux_out_2_B, mux_out_3_C, SSE_out;
    wire EX_Shift_imm, EX_RF_Enable, EX_mem_size, EX_mem_read_write, ID_mem_size, ID_mem_read_write, C;
    wire [3:0] EX_ALU_OP;
    wire [7:0] EX_addresing_modes, ID_addresing_modes;
    wire [6:0] ID_CU, C_U_out, NOP_S;// = 0010001;
                                        

    //main PPU(clk);
    

    initial
        begin
        file = $fopen("ramintr.txt","rb");
        Address = 32'b0; // 32'b0;
            while (!$feof(file)) begin //while not the end of file
            code = $fscanf(file, "%b", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
            // clk = ~clk;
        end

    $fclose(file);  
    end
    
    inst_ram256x8 ram1 (DataOut, Address);

    /*-------------------------------------- Clock --------------------------------------*/

    main PPU(.clk(clk));
    
    // always@(clk)
    initial begin
        
        $display("\n\n         PC               ------------------ID State-------------------                      ------------------EX State------------------                   ---------MEM State------                  -------WB State-------");
        $display("               ID_B_instr  | ID_shift_imm | ID_alu  | ID_load | ID_RF | ID_mem_r_w        EX_shift_imm | EX_alu  | EX_load | EX_RF | EX_mem_r_w          MEM_load  | MEM_RF | MEM_mem_r_w            WB_load | WB_RF | WB_mem_r_w \n");
        PCO = 32'b0; 
    end
    // begin      
    always begin
         
        Address = #1 32'b11100000100000100101000000000101; //1100000100000100101000000000101;
        clk = ~clk;          
                  
        $display("%d           %b     |       %b      |   %b  |     %b   |   %b   |  %b                          %b  |   %b  |    %b    |   %b   | %b                           %b |    %b   | %b                            %b |   %b   |  %b \n", PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, WB_load_instr, WB_RF_Enable, WB_mem_read_write);
        #5;
        PCO = PCO + 32'd4;
  
        Address =  32'b11011011000000000000000000000001;
            
        
    end 
    
    // // inst_ram256x8 ram1 (DataOut, Address);
    control_unit control_unit1(ID_B_instr, ID_mem_read_write, C_U_out, clk, DataOut);
    ID_EX_pipeline_register ID_EX_pipeline_register(mux_out_1_A, mux_out_2_B, mux_out_3_C, EX_Bit15_12, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,
                                        EX_Bit11_0, EX_addresing_modes, EX_mem_size, EX_mem_read_write,

                                        mux_out_1, mux_out_2, mux_out_3, ID_Bit15_12, C_U_out, ID_Bit11_0, ID_addresing_modes, ID_mem_size, ID_mem_read_write, clk);
    EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, clk, EX_mem_read_write, EX_mem_size,
                                MEM_A_O, MEM_MUX3, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);
    MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, clk, WB_A_O, WB_Data_RAM_Out, WB_Bit15_12, WB_load_instr, WB_RF_Enable);
            
endmodule
