`include "PPU.v"

module ppu_tb;

/* Main Signals */
reg clk, Reset;

wire [31:0] PCO; // = 32'b0; //address instr Mem

wire ID_B_instr, MEM_mem_read_write, MEM_load_instr,WB_load_instr, asserted;  

//wire 
//ALU_IF && IF_ID_pipeeline
wire [31:0] DO; // = 32'b11100000100000100101000000000101;
wire [31:0] DO_CU; // = 32'b11100000100000100101000000000101;
wire [31:0] Next_PC, PC4, MEM_A_O, MEM_MUX3; //, DAO; 

wire [23:0] ID_Bit23_0;
wire [3:0] ID_Bit19_16, ID_Bit3_0;
wire [3:0] ID_Bit31_28, cc_alu_1;
wire [3:0] ID_Bit15_12, cc_main_alu_out;
wire [11:0] ID_Bit11_0;
wire [31:0] EX_Bit11_0, EX_MUX_2X1_OUT,  PCIN;
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
wire EX_load_instr; 
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


/*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;   
    reg [31:0] Address; wire [31:0] DataOut;

    inst_ram256x8 ram1 (DO, PCO, Reset);

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
    Address = #1 32'b00000000000000000000000000000000; //make sure adress starts back in 0 after precharge
    end
    
      
/*-------------------------------------- PRECHARGE DATA RAM --------------------------------------*/

    initial begin
        file = $fopen("ramintr.txt","rb");
        Address = 32'b00000000000000000000000000000000;
            while (!$feof(file)) begin //while not the end of file
            code = $fscanf(file, "%b", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
        end

    $fclose(file);
    Address = #1 32'b00000000000000000000000000000000; //make sure adress starts back in 0 after precharge
    end  


//initial begin 
    //  $display("\n\n/*--------------------------------------  IF Stage  --------------------------------------*/\n \n");       
//end
    // inst_ram256x8 ram1 (DO, PCO, Reset);

    //IF Stage
    //para escoger entre TA & PC+4
    //module mux_2x1_Stages(input [31:0] A, B, input sig, output [31:0] MUX_Out); 0 ==A ; 1==B
    

    

    /*  always @ (clk) begin
            $display(" ------- INSTR MEM  --------                           clk: %0d  Reset:%0d", $time, Reset);

            $display("\nPCout: %b  ", PCO);
            $display("DataOut: %b     Address: %b  \n\n ", DO, PCO);

    end */
    

    //para conseguir PC+4
    //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
    alu alu_1(PCO, 32'd4, 4'b0100, 1'b0, PC4, cc_alu_1);

    /*  always @ (clk) begin
        //#2;
        $display(" ------- ALU PC+4 --------                           clk: %0d", $time);

        $display("PCout _A: %b  ", PCO);
        $display("Entrada B: %b ", 32'd4);
        $display("Suma A&B: %b  ", 4'b0100);
        $display("Carry In: %b  ", 1'b0);
        $display("PC + 4: %b    ", PC4);
        $display("Condition Codes: %b  \n\n ", cc_alu_1);
    end */

    mux_2x1_Stages mux_2x1_stages_1(PC4, TA, choose_ta_r_nop, PCI);

    mux_2x1_Stages mux_2x1_PCin(PCI, 32'b0, Reset, PCIN);
    /*   always @ (clk) begin
                // #2; //in tick 2 because clk = 1 on this tick 

                    $display(" ------- MUX 2x1 PCin (salida) --------              clk: %0d", $time);

                    $display("PC4 - 0: %b  ", PC4);
                    $display("TA - 1: %b   ", TA);
                    $display("choose_ta_r_nop: %b  ", choose_ta_r_nop);
                    $display("PCin: %b  \n\n", PCI);
                    $display("Reset: %b ", Reset);

                    $display("PCI RF: %b  \n\n", PCIN);
                end */
            
    // //IF/ID reg
    // //IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
    // //                           output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
    // //                           output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
    // //                           input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr, input [31:0] DataOut);
    IF_ID_pipeline_register IF_ID_pipeline_register(ID_Bit23_0, Next_PC,
                                ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, ID_Bit11_0,
                                ID_Bit15_12, DO_CU,
                                choose_ta_r_nop, IF_ID_Load, clk,Reset, asserted, PC4, DO);
        /*   always@(clk) begin
            
            $display(" ------- IF_ID_PIPE REG --------               clk: %0d", $time);

            $display("ID_Bit23_0 %b ", ID_Bit23_0);
            $display("Next_PC %b ", Next_PC);
            $display("ID_Bit19_16 %b ", ID_Bit19_16);
            $display("ID_Bit3_0 %b ", ID_Bit3_0);
            $display("ID_Bit31_28 %b ", ID_Bit31_28);
            $display("ID_Bit15_12 %b ", ID_Bit15_12);
            $display("choose_ta_r_nop %b ", choose_ta_r_nop);
            $display("IF_ID_Load %b ", IF_ID_Load);
            $display("clk %b ", clk);
            $display("PC4 %b ", PC4);
            $display("DataOut %b", DO_CU);

        end */

    
    
    // //ID_Stage
    Status_register Status_register(cc_main_alu_out, S, cc_out, clk);
    /*   initial begin
            #2;
            $display(" ------- STATUS REGISTER -------- ");

            $display("cc_main_alu_out %b ", cc_main_alu_out);
            $display("S %b ", S);
            $display("cc_out %b ",  cc_out);
            $display("clk %b ", clk);
        
    end */
    
    // //SEx4
    // // SExtender(input reg [23:0] in, output signed [31:0] out1);
    SExtender se(ID_Bit23_0, SEx4_out);
    /*  initial begin
        #2;
        $display(" ------- 4x(SE) -------- ");

        $display("IN_23bits %b ", ID_Bit23_0);
        $display("SEx4_out %b ", SEx4_out);
            
    end */
    // //para conseguir TA
    //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
    alu alu_2(SEx4_out, Next_PC, 4'b0100, 1'b0, TA, cc_alu_2);
    /*   initial begin
            #2;
            $display(" ------- ALU TARGET ADDRESS -------- ");

            $display("SEx4_out %b ", SEx4_out);
            $display("Next_PC %b ", Next_PC);
            $display("Suma %b ",  4'b0100);
            $display("CARRY IN %b ", 1'b0);
            $display("Target Address %b ", TA);
            $display("Condition Codes %b ", cc_alu_2);
    end */

    mux_2x1_Stages mux_2x1_stages_5(PC4, TA, choose_ta_r_nop, PCin);
    // initial begin
    //         #2;
    //         $display(" ------- MUX 2x1 PCin (salida) -------- ");

    //         $display("PC4 - 0 %b ", PC4);
    //         $display("TA - 1 %b ", TA);
    //         $display("choose_ta_r_nop %b ", choose_ta_r_nop);
    //         $display("PCin %b ", PCin);
    //     end
    // // este es el general RF
    // // register_file(PA, PB, PD, PW, PCin, PCout, C, SA, SB, SD, RFLd //hazaerd unit, PCLd, CLK);
    //  output [31:0] PA, PB, PD, PCout;
    //  output [31:0] MO; //output of the 2x1 multiplexer
    // //Inputs
    // input [31:0] PW, PCin;
    // input [3:0] SA, SB, SD, C;
    // input RFLd, PCLd, CLK;
    
                //    register_file(PA, PB, PD, PW, PCin, PCout,      C,            SA,         SB,     SD, RFLd,   HZPCld,  CLK,  RST);
    register_file register_file_1(PA, PB, PD, PW, PCIN, PCO, WB_Bit15_12_out, ID_Bit19_16, ID_Bit3_0, SD, RFLd,  PC_RF_ld ,clk,  Reset); //falta RW = WB_Bit15_12_out

    //   initial begin
    //         #10;
    // //         $display(" ------- REGISTER FILE -------- ");

            // $display("PA %b ", PA);
            // $display("PB %b ", PB);
            // $display("PD %b ", PD);
    // //         $display("PW %b ", PW);
    // //         $display("PCin %b ", PCin);
    // //         $display("PCout %b ", PCO);
    // // //         $display("RW %b ", WB_Bit15_12_out);
    //         $display("SA %b ", ID_Bit19_16);
    //         $display("SB %b ", ID_Bit3_0);
    //         $display("SD %b", SD);
    //         // $display("RegFile LOAD %b ", RFLd);
    //         $display("PC LOAD %b ", PC_RF_ld);
    // //         $display("clk %b", clk);

        // end 
    // //mux_4x2_ID(input [31:0] A_O, PW, M_O, P, input [1:0] HF_U, output [31:0] MUX_Out);
    // //MUX1
    mux_4x2_ID mux_4x2_ID_1(A_O, PW, M_O, PA, MUX1_signal, mux_out_1);
    
        /*  initial begin
        #2;
            $display(" ------- MUX 4x2 ID A -------- ");

            $display("PA %b ", PA);
            $display("A_O %b ", A_O);
            $display("M_O %b ", M_O);
            $display("PW %b ", PW);
            $display("MUX1_signal %b ", MUX1_signal);
            $display("mux_out_1 %b ", mux_out_1);
            
        end */
    // //MUX2
    mux_4x2_ID mux_4x2_ID_2(A_O, PW, M_O, PB, MUX2_signal, mux_out_2);
        // initial begin
        //     #2;
        //     $display(" ------- MUX 4x2 ID B -------- ");

        //     $display("PB %b ", PB);
        //     $display("A_O %b ", A_O);
        //     $display("M_O %b ", M_O);
        //     $display("PW %b ", PW);
        //     $display("MUX2_signal %b ", MUX2_signal);
        //     $display("mux_out_2 %b ", mux_out_2);
            
        // end
    // //MUX3
    mux_4x2_ID mux_4x2_ID_3(A_O, PW, M_O, PD, MUX3_signal, mux_out_3);
    /*  initial begin
            #2;
            $display(" ------- MUX 4x2 ID C -------- ");

            $display("PD %b ", PD);
            $display("A_O %b ", A_O);
            $display("M_O %b ", M_O);
            $display("PW %b ", PW);
            $display("MUX3_signal %b ", MUX3_signal);
            $display("mux_out_3 %b ", mux_out_3);
            
    end */

    /*module control_unit(output ID_B_instr, MemReadWrite, output [6:0] C_U_out, input clk, Reset, input [31:0] A); */
    //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

    control_unit control_unit1(ID_B_instr, ID_mem_read_write, ID_mem_size, C_U_out,clk, Reset, asserted, DO_CU);
    /*  initial begin
            #2;
            $display(" ------- CONTROL UNIT -------- ");

            $display("ID_B_instr %b ", ID_B_instr);
            $display("ID_mem_read_write %b ", ID_mem_read_write);
            $display("C_U_out %b ", C_U_out);
            $display("clk %b ", clk);
            $display("DAO %b ", DAO);
            
    end */

    // //mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
    mux_2x1_ID mux_2x1_ID(C_U_out, MUXControlUnit_signal, ID_CU);
    /* initial begin
            #2;
            $display(" ------- Multiplexer CONTROL UNIT -------- ");

            $display("NOP_S %b ", NOP_S);
            $display("C_U_out %b ", C_U_out);
            $display("MUXControlUnit_signal %b ", MUXControlUnit_signal);
            $display("ID_CU %b ", ID_CU);
            
    end */


    // //ID_EX_pipeline_register(output reg [31:0] register_file_port_MUX1_out, register_file_port_MUX2_out, register_file_port_MUX3_out,
    // //                            output reg [3:0] EX_Bit15_12_out, output reg [6:0] EX_CU,
    // //                            output reg [11:0] EX_Bit11_0_out,
    // //                            output reg [7:0] EX_addresing_modes_out,
    // //                            output reg EX_branch_instr_out,
    // //                            EX_mem_size_out, EX_mem_read_write_out,
    // //
    // //                            input [31:0] register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in,
    // //                            input [3:0] ID_Bit15_12_in, input [6:0] ID_CU, 
    // //                            input [11:0] ID_Bit11_0_in,
    // //                            input [7:0] ID_addresing_modes_in,
    // //                            input ID_branch_instr_in, 
    // //                            ID_mem_size_in, ID_mem_read_write_in, input clk);    

ID_EX_pipeline_register ID_EX_pipeline_register(mux_out_1_A, mux_out_2_B, mux_out_3_C,
                                EX_Bit15_12, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,
                                EX_Bit11_0, EX_addresing_modes, EX_mem_size, EX_mem_read_write,

                                mux_out_1, mux_out_2, mux_out_3, ID_Bit15_12, C_U_out,
                                ID_Bit11_0, ID_addresing_modes, ID_mem_size, ID_mem_read_write, clk);    
        /*  initial begin
                        #2;
                        $display(" ------- ID_EX_PIPE REG -------- ");

                        $display("mux_out_1_A %b ", mux_out_1_A);
                        $display("mux_out_2_B %b ", mux_out_2_B);
                        $display("mux_out_3_C %b ", mux_out_3_C);
                        $display("EX_Bit15_12 %b ", EX_Bit15_12);
                        $display("EX_Bit11_0 %b ", EX_Bit11_0);
                        $display("EX_Shift_imm %b ", EX_Shift_imm);
                        $display("EX_ALU_OP %b ", EX_ALU_OP);
                        $display("EX_load_instr %b ", EX_load_instr);
                        $display("EX_RF_Enable %b ", EX_RF_Enable);
                        $display("EX_addresing_modes %b ", EX_addresing_modes);
                        $display("EX_mem_size %b", EX_mem_size);
                        $display("EX_mem_read_write %b ", EX_mem_read_write);
                        
                        $display("mux_out_1 %b ", mux_out_1);
                        $display("mux_out_2 %b ", mux_out_2);
                        $display("mux_out_3 %b ", mux_out_3);
                        $display("ID_Bit15_12 %b ", ID_Bit15_12);
                        $display("ID_Bit11_0 %b ", ID_Bit11_0);
                        $display("ID_CU %b ", ID_CU);
                        $display("ID_addresing_modes %b ", ID_addresing_modes);
                        $display("ID_mem_size %b", ID_mem_size);
                        $display("ID_mem_read_write %b ", ID_mem_read_write);
                        $display("CLK %b ", clk);



        end */
        // initial begin
        //         $display("mux_out_1_A %b ", mux_out_1_A);
        //         $display("mux_out_2_B %b ", mux_out_2_B);
        //         $display("mux_out_3_C %b ", mux_out_3_C);
        // end


// //MAIN ALU    
// //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] cc_alu_out); //N, Z, C, V
// // wire [3:0] E_M_2x1_I_O = EX_MUX_2x1_ID_Out[5:2];
alu alu_main(mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, C, A_O, cc_main_alu_out);
        /*  initial begin
                        #2;
                        $display(" ------- MAIN ALU -------- ");

                        $display("mux_out_1_A %b ", mux_out_1_A);
                        $display("EX_MUX_2X1_OUT %b ", EX_MUX_2X1_OUT);
                        $display("EX_ALU_OP %b ", EX_ALU_OP);
                        $display("C %b ", C);
                        $display("A_O %b ", A_O);
                        $display("cc_main_alu_out %b ", cc_main_alu_out);
                        
        end */
// //Sign_Shift_Extender (input [31:0]A, input [11:0]B, output reg [31:0]shift_result, output reg C);
Sign_Shift_Extender sign_shift_extender_1(mux_out_2_B, EX_Bit11_0, SSE_out, C);
    /*    initial begin
                        #2;
                        $display(" ------- SIGN SHIFT EXTENDER -------- ");

                        $display("mux_out_2_B %b ", mux_out_2_B);
                        $display("EX_Bit11_0 %b ", EX_Bit11_0);
                        $display("SSE_out %b ", SSE_out);
                        $display("C %b ", C);
                                                    
        end */
        // initial begin
        //      $display(" SSE mux_out_2_B %b ", mux_out_2_B);
        // end
// //mux between Shifter extender & ALU
// // wire E_M_2x1_Id_Ot = EX_MUX_2x1_ID_Out[6];
mux_2x1_Stages  mux_2x1_stages_2(mux_out_2_B, SSE_out, EX_Shift_imm, EX_MUX_2X1_OUT);
    /*      initial begin
                        #2;
                        $display(" ------- MUX BETWEEN SIGN SHIFT EXTENDER & ALU -------- ");

                        
                        $display("EX_Shift_imm %b ", EX_Shift_imm);
                        $display("SSE_out %b ", SSE_out);
                        $display("EX_MUX_2X1_OUT %b ", EX_MUX_2X1_OUT);
                                                    
        end */ 
        // initial begin
        //     $display(" MUX mux_out_2_B %b ", mux_out_2_B);
        // end
// //Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
Cond_Is_Asserted Cond_Is_Asserted (cc_out, ID_Bit31_28,clk, asserted);
/*    initial begin
                        #2;
                        $display(" ------- COND ASSERTED-------- ");

                        $display("cc_out %b ", cc_out);
                        $display("ID_Bit31_28 %b ", ID_Bit31_28);
                        $display("asserted %b ", asserted);
                                                    
        end  */

// //Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
Condition_Handler Condition_Handler(asserted, ID_B_instr, choose_ta_r_nop);
/*  initial begin
                        #2;
                        $display(" ------- COND HANDLER-------- ");

                        
                        $display("asserted %b ", asserted);
                        $display("ID_B_instr %b ", ID_B_instr);
                        $display("choose_ta_r_nop %b ", choose_ta_r_nop);
                                                    
        end  */

/*module EX_MEM_pipeline_register(input [31:0] mux_out_3_C, A_O, input [3:0] EX_Bit15_12, cc_main_alu_out, input EX_load_instr, EX_RF_instr, EX_mem_read_write, EX_mem_size, input clk,
                        output reg [31:0] MEM_A_O, MEM_MUX3, output reg [3:0] MEM_Bit15_12, output reg MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);*/
EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, EX_mem_read_write, EX_mem_size, clk,
                        MEM_A_O, MEM_MUX3, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);
/*    initial begin
        #2;
        $display(" ------- EX_MEM_PIPE REG -------- ");

        $display("mux_out_3_C %b ", mux_out_3_C);
        $display("A_O %b ", A_O);
        $display("EX_Bit15_12 %b ", EX_Bit15_12);
        $display("cc_main_alu_out %b ", cc_main_alu_out);
        $display("EX_load_instr %b ", EX_load_instr);
        $display("EX_RF_Enable %b ", EX_RF_Enable);
        $display("EX_mem_read_write %b ", EX_mem_read_write);
        $display("EX_mem_size %b ", EX_mem_size);
        $display("MEM_A_O %b ", MEM_A_O);
        $display("MEM_MUX3 %b ", MEM_MUX3);
        $display("clk %b ", clk);
        $display("MEM_Bit15_12 %b ", MEM_Bit15_12);
        $display("MEM_load_instr %b", MEM_load_instr);
        $display("MEM_RF_Enable %b", MEM_RF_Enable);
        $display("MEM_mem_read_write %b", MEM_mem_read_write);
        $display("MEM_mem_size %b", MEM_mem_size);


    end */

// //module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input Size);
data_ram256x8 data_ram(Data_RAM_Out, MEM_mem_read_write, MEM_A_O, MEM_MUX3, MEM_mem_size);
/*    initial begin
        #2;
        $display(" ------- DATA RAM -------- ");

        $display("Data_RAM_Out %b ", Data_RAM_Out);
        $display("MEM_mem_read_write %b ", MEM_mem_read_write);
        $display("MEM_A_O %b ", MEM_A_O);
        $display("MEM_MUX3 %b ", MEM_MUX3);
        $display("Size %b ", Size);
    
    end */

// //multiplexer in MEM Stage
mux_2x1_Stages  mux_2x1_stages_3(Data_RAM_Out, MEM_A_O, MEM_load, M_O);
/*  initial begin
        #2;
        $display(" ------- MUX en MEM STAGE -------- ");

        $display("Data_RAM_Out %b ", Data_RAM_Out);
        $display("MEM_A_O %b ", MEM_A_O);
        $display("MEM_load %b ", MEM_load);
        $display("M_O %b ", M_O);
    
    end */

// //module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input [1:0] MEM_load_rf, input clk
//                                 //output [31:0] wb_alu_out, wb_data_r_out,output [3:0] wb_bit15_12, output [1:0] wb_load_rf);
MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, clk,
                                WB_A_O, WB_Data_RAM_Out, WB_Bit15_12, WB_load_instr, WB_RF_Enable);
    /* initial begin
        #2;
        $display(" ------- MEM_WB_PIPE REG -------- ");

        
        $display("MEM_A_O %b ", MEM_A_O);
        $display("Data_RAM_Out %b ", Data_RAM_Out);
        $display("clk %b ", clk);
        $display("MEM_Bit15_12 %b ", MEM_Bit15_12);
        $display("MEM_load_instr %b", MEM_load_instr);
        $display("MEM_RF_Enable %b", MEM_RF_Enable);
        
        $display("WB_A_O %b ", WB_A_O);
        $display("WB_Data_RAM_Out %b ", WB_Data_RAM_Out);
        $display("WB_Bit15_12 %b ", WB_Bit15_12);
        $display("WB_load_instr %b ", WB_load_instr);
        $display("WB_RF_Enable %b ", WB_RF_Enable);
        
    end */
// //multiplexer in WB Stage
// // reg MEM_l_rf =  MEM_load_rf_out[1];
mux_2x1_Stages mux_2x1_stages_4(WB_Data_RAM_Out, WB_A_O, WB_load_instr, PW);
    /*initial begin
    #2;
    $display(" ------- MUX WB STAGE -------- ");

    $display("WB_A_O %b ", WB_A_O);
    $display("WB_Data_RAM_Out %b ", WB_Data_RAM_Out);
    $display("PW %b ", PW);
    $display("WB_load_instr %b ", WB_load_instr);
end */

// //Hazard-Forward Unit
// /*
// module hazard_unit(output reg [1:0] MUX1_signal, MUX2_signal, MUX3_signal, MUXControlUnit_signal, 
//            output reg IF_ID_load, PC_RF_load,
//         //    output reg [3:0] ID_Forwarding;
//            input EX_load_instr_in, EX_RF_Enable_in, MEM_RF_Enable_in, WB_RF_Enable_in,
//            input [3:0] EX_Bit15_12_in, MEM_Bit15_12_in, WB_Bit15_12_in, ID_Bit3_0_in, 
//            ID_19_16_in);
// */
hazard_unit h_u(MUX1_signal, MUX2_signal, MUX3_signal, MUXControlUnit_signal, 
            IF_ID_load, PC_RF_ld,
            EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable, clk,
            EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, ID_Bit3_0, ID_Bit19_16);

    /*initial begin
                        #2;
                        $display(" ------- HAZARD UNIT -------- ");

                        $display("MUX1_signal %b ", MUX1_signal);
                        $display("MUX2_signal %b ", MUX2_signal);
                        $display("MUX3_signal %b ", MUX3_signal);
                        $display("MUXControlUnit_signal %b ", MUXControlUnit_signal);
                        $display("IF_ID_load %b ", IF_ID_load);
                        $display("PC_RF_ld %b ", PC_RF_ld);
                        
                        $display("EX_load_instr %b ", EX_load_instr);
                        $display("EX_RF_Enable %b ", EX_RF_Enable);
                        $display("MEM_RF_Enable %b ", MEM_RF_Enable);
                        $display("WB_RF_Enable %b", WB_RF_Enable);
                        $display("EX_Bit15_12 %b ", EX_Bit15_12);
                        
                        $display("MEM_Bit15_12 %b ", MEM_Bit15_12);
                        $display("WB_Bit15_12 %b ", WB_Bit15_12);
                        $display("ID_Bit3_0 %b ", ID_Bit3_0);
                        $display("ID_Bit19_16 %b ", ID_Bit19_16);
                               
    end */
    // initial begin 
    //     $display("\n\n          PC                 ------------------ID State-------------------                   ------------------EX State------------------                ---------MEM State------          -------WB State-------");

    //     repeat (3)begin
    //         #10;
    //         $display(" %d            ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b           EX_shift_imm = %b | EX_alu= %b | EX_load = %b | EX_RF= %b          MEM_load = %b | MEM_RF= %b        WB_load = %b | WB_RF= %b \n", PCO, ID_CU[6], ID_CU[5:2], ID_CU[1], ID_CU[0],  EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable, MEM_load_instr, MEM_RF_Enable, WB_load_instr, WB_RF_Enable);
    //         // $display("DO: %d", DO);
    //         // #10;
        
    //         // $display("ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b", ID_CU[6], ID_CU[5:2], ID_CU[1], ID_CU[0]);     
    //         // $display("EX_shift_imm = %b | EX_alu= %b | EX_load = %b | EX_RF= %b", EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable);  
    //         // #10;
    //         // $display("------------------EX_MEM reg------------------");
    //         // $display("EX_load = %b | EX_RF= %b", EX_load_instr, EX_RF_Enable);     
    //         // $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);   

    //         // #10;
    //         // $display("---------------------MEM_WB reg----------------");

    //         // $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);  
    //         // $display("WB_load = %b | WB_RF= %b", WB_load_instr, WB_RF_Enable);    
    //     end
    // end


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

/*--------------------------------------  Monitor  --------------------------------------*/ 

initial begin
        
    $display("\n\n                    --------------------ID State---------------------           ----------------EX State---------------       --------MEM State------        ---WB State---           -------Instruction-------        --Time--");
    $display("           PC    B_instr | shift_imm |   alu  | load | R F | m_rw | m_s       shift_imm | alu  | load | R F | m_rw | m_s      load | R F | m_rw | m_s          load | R F          \n");
    $monitor("  %d         %b   |     %b     |  %b  |  %b   |  %b  |   %b  |  %b               %b  | %b |   %b  |  %b  |   %b  |  %b         %b  |  %b  |   %b  |  %b             %b  |  %b           %b        %0d\n", PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  ID_mem_size, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, EX_mem_size, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size, WB_load_instr, WB_RF_Enable, DO_CU, $time);

end
  
endmodule