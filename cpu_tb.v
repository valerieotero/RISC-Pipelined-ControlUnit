`include "PPU.v"

module PPU_tb;

    
    /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;
    reg clk = 1;
    reg [31:0] Address; wire [31:0] DataOut;
    wire [31:0] PCO = 32'b0; //address instr Mem


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
    wire MEM_RF_Enable;
    wire WB_RF_Enable;
    wire [3:0] EX_Bit15_12, cc_out;
    wire [3:0] MEM_Bit15_12;
    wire [3:0] WB_Bit15_12; 

    //ID_EX
    wire [31:0] mux_out_1_A, mux_out_2_B, mux_out_3_C, SSE_out;
    wire EX_Shift_imm, EX_RF_Enable, EX_mem_size, EX_mem_read_write, ID_mem_size, ID_mem_read_write, C;
    wire [3:0] EX_ALU_OP;
    wire[7:0] EX_addresing_modes, ID_addresing_modes;
    wire [6:0] ID_CU, C_U_out, NOP_S;// = 0010001;
                                        

    //main PPU(clk);
    inst_ram256x8 ram1 (DataOut, Address);

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

    /*-------------------------------------- Clock --------------------------------------*/

    main PPU(.clk(clk));
    
    always@(clk)
    begin         
        clk = ~clk;          
            $display("\n\n          PC                 ------------------ID State-------------------                   ------------------EX State------------------                ---------MEM State------          -------WB State-------");
            
            
            begin 
            Address = #1 32'b00000000000000000000000000000000; //make sure adress is in 0 after precharge
            $display("                          ID_B_instr  | ID_shift_imm | ID_alu  | ID_load | ID_RF              EX_shift_imm | EX_alu  | EX_load | EX_RF                    MEM_load  | MEM_RF                 WB_load  | WB_RF \n");
    
            repeat(3) begin
            $display(" %d                     %b     |       %b      |   %b  |     %b   |    %b                          %b |   %b  |    %b    |  %b                               %b |  %b                            %b |  %b \n", PCO, ID_B_instr, ID_CU[6], ID_CU[5:2], ID_CU[1], ID_CU[0],  EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable, MEM_load_instr, MEM_RF_Enable, WB_load_instr, WB_RF_Enable);

            end 
            end

            
        
    end 

     control_unit control_unit1(ID_B_instr, ID_mem_read_write, C_U_out, clk, DO);
            
endmodule
