`include "register_file/PF1_Nazario_Morales_Victor_rf.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_Sign_Shift_Extender.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_ALU.v"


//PPU
module main( input clk);

    //Precharge
    wire [31:0] PCO; // = 32'b0; //address instr Mem


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
                                                                               


    
        //IF Stage
        //para escoger entre TA & PC+4
        //module mux_2x1_Stages(input [31:0] A, B, input sig, output [31:0] MUX_Out); 0 ==A ; 1==B
        mux_2x1_Stages mux_2x1_stages_1(PC4, TA, choose_ta_r_nop, PCI);
       /* initial begin
                #2;
                $display(" ------- MUX 2x1 PCin (salida) -------- ");

                $display("PC4 - 0 %b ", PC4);
                $display("TA - 1 %b ", TA);
                $display("choose_ta_r_nop %b ", choose_ta_r_nop);
                $display("PCin %b ", PCI);
            end */
        // // module inst_ram256x8(output reg[31:0] DataOut, input [31:0]Address);
        inst_ram256x8 inst_ram(DO, PCO);
        // initial begin
        //     $display(" ------- INSTR MEM  -------- ");

        //     $display("PCout%b ", PCO);
        //     $display("DataOut%b     PCout%b ", DO, PCO);

        // end 

        //para conseguir PC+4
        //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
        alu alu_1(PCO, 32'd4, 4'b0100, 1'b0, PC4, cc_alu_1);
       /*  initial begin
                #2;
                $display(" ------- ALU PC+4 -------- ");

                $display("PCout _A %b ", PCO);
                $display("Entrada B %b ", 32'd4);
                $display("Suma A&B %b ", 4'b0100);
                $display("Carry In %b ", 1'b0);
                $display("PC + 4 %b ", PC4);
                $display("Condition Codes %b ", cc_alu_1);
            end */


        // //IF/ID reg
        // //IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
        // //                           output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
        // //                           output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
        // //                           input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr, input [31:0] DataOut);
        IF_ID_pipeline_register IF_ID_pipeline_register(ID_Bit23_0, Next_PC,
                                    ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, ID_Bit11_0,
                                    ID_Bit15_12, DO,
                                    choose_ta_r_nop, IF_ID_Load, clk, PC4, DO);
           /* initial begin
                #2;
                $display(" ------- IF_ID_PIPE REG -------- ");

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
                $display("DataOut %b", DO);

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
            
        register_file register_file_1(PA, PB, PD, PW, PCI, PCO, WB_Bit15_12_out, ID_Bit19_16, ID_Bit3_0, SD, RFLd, PC_RF_ld, clk); //falta RW = WB_Bit15_12_out

        //   initial begin
        //         #2;
        //         $display(" ------- REGISTER FILE -------- ");

        //         $display("PA %b ", PA);
        //         $display("PB %b ", PB);
        //         $display("PD %b ", PD);
        //         $display("PW %b ", PW);
        //         $display("PCin %b ", PCin);
        //         $display("PCout %b ", PCO);
        //         $display("RW %b ", WB_Bit15_12_out);
        //         $display("SA %b ", ID_Bit19_16);
        //         $display("SB %b ", ID_Bit3_0);
        //         $display("SD %b", SD);
        //         $display("RegFile LOAD %b ", RFLd);
        //         $display("PC LOAD %b ", PC_RF_ld);
        //         $display("clk %b", clk);

        //     end 
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
         /*   initial begin
                #2;
                $display(" ------- MUX 4x2 ID B -------- ");

                $display("PB %b ", PB);
                $display("A_O %b ", A_O);
                $display("M_O %b ", M_O);
                $display("PW %b ", PW);
                $display("MUX2_signal %b ", MUX2_signal);
                $display("mux_out_2 %b ", mux_out_2);
              
            end */
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

        // //control_unit(output ID_B_instr, ALUSrc, RegDst,  
        // //                MemReadWrite, PCSrc, RegWrite, MemToReg, Branch, Jump, output [6:0] C_U_out, 
        // //               input clk, input [31:0] A); 
        // //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

        control_unit control_unit(ID_B_instr, ID_mem_read_write, C_U_out, 
                        clk, DO);
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
        mux_2x1_ID mux_2x1_ID(C_U_out, NOP_S, MUXControlUnit_signal, ID_CU);
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
        // //mux between Shifter extender & ALU
        // // wire E_M_2x1_Id_Ot = EX_MUX_2x1_ID_Out[6];
        mux_2x1_Stages  mux_2x1_stages_2(mux_out_2_B, SSE_out, EX_Shift_imm, EX_MUX_2X1_OUT);
          /*      initial begin
                                #2;
                                $display(" ------- MUX BETWEEN SIGN SHIFT EXTENDER & ALU -------- ");

                                $display("mux_out_2_B %b ", mux_out_2_B);
                                $display("EX_Shift_imm %b ", EX_Shift_imm);
                                $display("SSE_out %b ", SSE_out);
                                $display("EX_MUX_2X1_OUT %b ", EX_MUX_2X1_OUT);
                                                          
                end */
        // //Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
        Cond_Is_Asserted Cond_Is_Asserted (cc_out, ID_Bit31_28, asserted);
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

        // //module EX_MEM_pipeline_register(input [31:0] MUX3, Alu_output, input [3:0] EX_Bit15_12, input [3:0] cc_alu_out, input [1:0] C_U_SIGNAL, input clk
        //                                 //output [31:0] MEM_Alu_Out, MEM_MUX3, output [3:0] MEM_Bit15_12, output [1:0] MEM_load_rf);
        EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, clk, EX_mem_read_write, EX_mem_size,
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
        data_ram256x8 data_ram(Data_RAM_Out, MEM_mem_read_write, MEM_A_O, MEM_MUX3, Size);
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
                    EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable,
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
endmodule


//CONTROL UNIT
module control_unit(output ID_B_instr, MemReadWrite, output [6:0] C_U_out, input clk, input [31:0] A); 

    reg [2:0] instr;
     //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

    integer s_imm = 0; 
    integer rf_instr = 0; 
    integer l_instr = 0; 
    integer b_instr = 0; 
    integer m_rw = 0;

    reg [3:0] alu_op = 4'b0000;
    integer b_bl = 0; // branch or branch & link
    integer r_sr_off = 0; // register or Scaled register offset
    integer u = 0;
    integer l = 0;
    integer condAsserted = 0; // 0 Cond no se da, 1 cond se da

    assign C_U_out[6] = s_imm;
    assign C_U_out[0] = rf_instr;
    assign C_U_out[1] = l_instr; 
    assign ID_B_instr = b_instr;
    assign C_U_out[5:2] = alu_op;
    assign MemReadWrite = m_rw;

    always@(*)
    // if(Cond_Is_Asserted == 1) ejecuta instr, else tira un NOP
    //
    //if(Cond_Is_Asserted (Status_register(cc_in, S, cc_out, clk), A[31:28], output asserted)) == 0)
    //NOP
    //else (el codigo de abajo)

    begin
        instr = A[27:25];
       // $display("instr %b", instr);
        // if(instr == 3'b101)
        //     b_instr = 1;
        // else 
       //     b_instr = 0;     
        case(instr)

            3'b000: //Data Procesing Shift_by_imm
            begin
                s_imm = 0; 
                rf_instr = 1; 
                l_instr = 0; 
                    // b_instr = 0;
                alu_op = A[24:21];
            end

            3'b001: //Data Procesing Immediate
            begin
                s_imm = 1; 
                rf_instr = 1; 
                l_instr = 0; 
                   // b_instr = 0;
                alu_op = A[24:21];
            end

            3'b010: //Load/Store Immediate Offset
            begin
                u = A[23];
                l = A[20];
                s_imm = 0; 
                l_instr = l; 
                    // b_instr = 0;

                if(l == 0)
                    rf_instr = 0;
                else
                    rf_instr = 1; 
                    

                if(u == 1)
                    alu_op = 4'b0100; //suma
                else
                    alu_op = 4'b0010; //resta              
            end

            3'b011: //Load/Store Register Offset
            begin
                u = A[23];
                l = A[20];

                if(u == 1)
                    alu_op = 4'b0100; //suma
                else
                    alu_op = 4'b0010; //resta
                    

                if(l == 0) begin
                    rf_instr = 0;
                    m_rw = 1;
                end else begin
                    rf_instr = 1; 
                    m_rw = 1;

                end
            
                if(A[11:4] == 8'b00000000)
                    r_sr_off = 0;
                else
                    r_sr_off = 1;
                    

                    
                if(r_sr_off == 0)begin //register_offset
                    s_imm = 0; 
                    l_instr = l; 
                        // b_instr = 0;

                
                end else begin //scaled_reg_offset
                    s_imm = 0; 
                    l_instr = l; 
                        // b_instr = 0;

                       
                            
                end
                  
            end

            3'b101: //branches
            begin
                b_bl = A[24];
                  
                // case(b_bl)
                    // 1'b0://branch
                if(b_bl == 0) begin
                    s_imm = 0; 
                    rf_instr = 0; 
                    l_instr = 0; 
                                // b_instr = 1;
                end else begin
                    // 1'b1://branch & link begin
                    s_imm = 0; 
                    rf_instr = 1; 
                    l_instr = 0; 
                                // b_instr = 1;
                    alu_op = 4'b0100; //suma
                end
                // endcase
                   
            end
            

        endcase
        //  $display("ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b", C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0]);     
    //    
    end
endmodule


//Status Register
module Status_register(input [3:0] cc_in, input S, output reg [3:0] cc_out, input clk);
    //Recordar que el registro se declara aquí y luego
    always @ (posedge clk)
    begin
        if (S)
        //     cc_out <= 5'b00000;
        // else 
            cc_out <= cc_in;
    
        // if(clk == 0)
            // cc_out = 4'b0;
        // else
        // if(S == 1)
        //     cc_out <= cc_in;
    end

    //    begin
    //     if(clk == 0)
    //         cc_out = 4'b0;
    //     else
    //         if(S == 1)
    //             cc_out = cc_in;
    //         else
    //             cc_out = 4'b0; //si no lo modifica va un register con el valor anterior
  //  end

endmodule


//Reigster for status register needs
//module sr_subregister(output reg [3:0] cc_out, input [3:0] cc_in, input S, input CLK);
//
//    always @ (posedge CLK)
//    begin
//        if (S)
//            cc_out <= cc_in;
//    end
//
//endmodule


//Condition verification
module Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
    //N - 3, Z - 2, C - 1, V - 0
    integer n = 0;
    integer z = 0;
    integer c = 0;
    integer v = 0;
    integer assrt = 0;

    assign asserted = assrt;

    always@(*)
    begin
        n = cc_in[3];
        z = cc_in[2];
        c = cc_in[1];
        v = cc_in[0];
        case(instr_condition)
            4'b0000: //(EQ) Equal
            begin
                if(z == 1)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //1
            4'b0001: //(NE) Not Equal
            begin
                if(z == 0)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //2
            4'b0010: //(CS/HS) Carry set/unsigned higher or same
           begin
                if(c == 1)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //3
            4'b0011: //(CC/LO) carry clear/ unsigned lower
           begin
                if(c == 0)
                    assrt = 1;
                else
                    assrt = 0;
            end
                     
            //4
            4'b0100: //(MI) Minus/negative
            begin
                if(n == 1)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //5
            4'b0101: //(PL) plus/positive or zero 
            begin
                if(n == 0)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //6
            4'b0110: //(VS) Overflow
            begin
                if(v == 1)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //7
            4'b0111: //(VC) No Overflow
            begin
                if(v == 0)
                    assrt = 1;
                else
                    assrt = 0;
            end
            
            //8
            4'b1000: //(HI) Unsigned Higher 
            begin
                if(c == 1 && z ==0)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //9
            4'b1001: //(LS) Unsigned Lower or same
            begin
                if(c == 0 || z == 1)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //10
            4'b1010: //(GE) Signed greater than or equal 
            begin
                if(v == n)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //11
            4'b1011: //(LT) Signed less than
            begin
                if(v != n)
                    assrt = 1;
                else
                    assrt = 0;
            end

            //12
            4'b1100: //(GT) Signed greater than
            begin
                if(z == 0 || n == v)
                    assrt = 1;
                else
                    assrt = 0;
            end 

            //13
            4'b1101: // (LE) Signed Less than or equal
             begin
                if(z == 1 || n != v)
                    assrt = 1;
                else
                    assrt = 0;
            end 

            //14
            4'b1110: //Always
            assrt = 1;

            //15
            4'b1111: 
            assrt = 0;

        endcase
    end

endmodule

//conition handler (output condition asserted, branch)
module Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
    always@(*)
    begin
        if(asserted == 1 && b_instr == 1)
            choose_ta_r_nop = 1;
        else
            choose_ta_r_nop = 0; 
    end

endmodule


//IF/ID PIPELINE REGISTER
module IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, output reg [31:0] ID_Next_PC,
                               output reg [3:0] ID_Bit19_16, ID_Bit3_0, output reg [3:0] ID_Bit31_28, output reg[11:0] ID_Bit11_0,
                               output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
                               input nop, Hazard_Unit_Ld, clk, input [31:0] PC4, DataOut);

    always@(*) //posedge clk)
    begin

        if(Hazard_Unit_Ld) begin
            ID_Bit31_0 = DataOut;
            ID_Next_PC = PC4;
            ID_Bit3_0 =  DataOut[3:0]; //{28'b0, DataOut[3:0]};
            ID_Bit31_28 = DataOut[31:28];
            ID_Bit19_16 =  DataOut[19:16]; //{28'b0, DataOut[19:16]};
            ID_Bit15_12 = DataOut[15:12];
            ID_Bit23_0 = DataOut[23:0];
            ID_Bit11_0 = DataOut[11:0];
            
        end else begin
            ID_Bit31_0 = 32'b0;
            ID_Next_PC = 32'b0;
            ID_Bit3_0 = 4'b0; //32'b0;
            ID_Bit31_28 = 4'b0;
            ID_Bit19_16 = 4'b0; //32'b0;
            ID_Bit15_12 = 4'b0;
            ID_Bit23_0 = 24'b0;
            ID_Bit11_0 = 12'b0;
        end

        // if(nop)begin
        //     ID_Bit31_0 <= 32'b0;
        //     ID_Next_PC <= 32'b0;
        //     ID_Bit3_0 <= 4'b0;
        //     ID_Bit31_28 <= 4'b0;
        //     ID_Bit19_16 <= 4'b0;
        //     ID_Bit15_12 <= 4'b0;
        //     ID_Bit23_0 <= 24'b0;
        //     ID_Bit11_0 <= 12'b0;
        // end


    // $display("\n\n\n/*-------------------------------------- IF_ID_pipeline_register OUT --------------------------------------*/\n");   

    //  $display("ID_Bit23_0 = %b | ID_Next_PC =%b | ID_Bit19_16=%b | ID_Bit3_0=%b\n",
    //                            ID_Bit23_0, ID_Next_PC,
    //                            ID_Bit19_16, ID_Bit3_0);

    // $display("ID_Bit31_28=%b | ID_Bit11_0=%b | ID_Bit15_12=%b | ID_Bit31_0=%b | nop=%b | Hazard_Unit_Ld=%b\n",
    //                            ID_Bit31_28, ID_Bit11_0,
    //                            ID_Bit15_12, ID_Bit31_0,
    //                            nop, Hazard_Unit_Ld);
                               
    //  $display("clk=%b | PC4=%b | DataOut=%b\n", clk, PC4, DataOut);    

    end
endmodule


//ID/EX PIPELINE REGISTER
module ID_EX_pipeline_register(output reg [31:0] mux_out_1_A, mux_out_2_B, mux_out_3_C,
                               output reg [3:0] EX_Bit15_12, output reg EX_Shift_imm, output reg [3:0]  EX_ALU_OP, output reg EX_load_instr, EX_RF_instr, 
                               output reg [31:0] EX_Bit11_0,
                               output reg [7:0] EX_addresing_modes,
                               output reg EX_mem_size, EX_mem_read_write,

                               input [31:0] mux_out_1, mux_out_2, mux_out_3,
                               input [3:0] ID_Bit15_12, input [6:0] ID_CU, 
                               input [11:0] ID_Bit11_0,
                               input [7:0] ID_addresing_modes,
                               input ID_mem_size, ID_mem_read_write, input clk);

    always@(*) //posedge clk)
    begin
        //Control Unit signals  
        EX_Shift_imm = ID_CU[6];
        EX_ALU_OP = ID_CU[5:2];
        EX_load_instr = ID_CU[1]; 
        EX_RF_instr = ID_CU[0];
        EX_mem_size = ID_mem_size;
        EX_mem_read_write = ID_mem_read_write;

        //Register File operands
        mux_out_1_A = mux_out_1;
        mux_out_2_B = mux_out_2;
        mux_out_3_C = mux_out_3;
     
        //Instruction bits
        EX_Bit15_12 = ID_Bit15_12;
        EX_Bit11_0 = {20'b0, ID_Bit11_0};
        EX_addresing_modes = ID_addresing_modes; //22-20
   
    // $display("ID_EX reg");
    // $display("ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b", ID_CU[6], ID_CU[5:2], ID_CU[1], ID_CU[0]);     
    // $display("EX_shift_imm = %b | EX_alu= %b | EX_load = %b | EX_RF= %b", EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_instr);     

    end
   
endmodule


//EX/MEM PIPELINE REGISTER
module EX_MEM_pipeline_register(input [31:0] mux_out_3_C, A_O, input [3:0] EX_Bit15_12, cc_main_alu_out, input EX_load_instr, EX_RF_Enable, EX_mem_read_write, EX_mem_size, input clk,
                                output reg [31:0] MEM_A_O, MEM_MUX3, output reg [3:0] MEM_Bit15_12, output reg MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);


    always@(*)//posedge clk)
    begin
        MEM_A_O = A_O;
        MEM_MUX3 = mux_out_3_C;
        MEM_Bit15_12 = EX_Bit15_12;
        MEM_load_instr = EX_load_instr;
        MEM_RF_Enable = EX_RF_Enable;
        MEM_mem_read_write = EX_mem_read_write;
        MEM_mem_size =  EX_mem_size;
    
    // $display("EX_MEM reg");
    // $display("EX_load = %b | EX_RF= %b", EX_load_instr, EX_RF_Enable);     
    // $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);     

    end
   
endmodule


//MEM/WB PIPELINE REGISTER
module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input MEM_load_instr, MEM_RF_Enable, clk,
                                    output reg [31:0] wb_alu_out, wb_data_r_out, output reg [3:0] wb_bit15_12, output reg WB_load_instr, WB_RF_Enable);

    always@(*) //posedge clk)
    begin
        wb_alu_out = alu_out;
        wb_data_r_out = data_r_out;
        wb_bit15_12 = bit15_12;
        WB_load_instr = MEM_load_instr;
        WB_RF_Enable = MEM_RF_Enable;
    // $display("MEM_WB reg");
     
    // $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);  
    // $display("WB_load = %b | WB_RF= %b", WB_load_instr, WB_RF_Enable);           
    end
    
endmodule


//INSTRUCTION MEMORY 
module inst_ram256x8(output reg[31:0] DataOut, input [31:0]Address);
                  
   reg[7:0] Mem[0:255]; //256 localizaciones 
   
    always @ (*) //(DataOut,Address)                
        if(Address%4==0) //Instructions have to start at even locations that are multiples of 4.
        begin    
            DataOut = {Mem[Address+0], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
            // $display("DO_instMem  %b\n", DataOut);                
        end
        else
            DataOut = Mem[Address]; 

endmodule                               
              

//DATA MEMORY
module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input Size);

    reg[7:0] Mem[0:255]; //256 localizaciones 

    always @ (DataOut, ReadWrite, Address, DataIn, Size)       

        casez(Size) //"casez" to ignore dont care values
        1'b1: //BYTE
        begin 
            if (ReadWrite) //When Write 
            begin
                Mem[Address] = DataIn; 
            end
            else //When Read
            begin
                DataOut= Mem[Address];
            end                
        end      

        1'b0: //WORD
        begin
            if (ReadWrite) //When Write 
            begin
                Mem[Address] = DataIn[31:24];
                Mem[Address + 1] = DataIn[23:16];
                Mem[Address + 2] = DataIn[15:8]; 
                Mem[Address + 3] = DataIn[7:0]; 
            end                 
            else //When Read
            begin
                    DataOut = {Mem[Address + 0], Mem[Address + 1], Mem[Address + 2], Mem[Address + 3]}; 
            end  
        end        
    endcase      
endmodule


/*Multiplexer for the 3 MUX in ID (este es uno general se puede simplemente 
cambiar las asignaturas segun lo que se necesite)
*/
module mux_4x2_ID(input [31:0] A_O, PW, M_O, X, input [1:0] HF_U, output [31:0] MUX_Out);
    reg [31:0] salida;

    assign MUX_Out = salida;

    always@(*)
    begin
        case(HF_U)
            2'b00: // A
            salida = X;

            2'b01://B
            salida = A_O; //EX_Rd

            2'b10://C
            salida = M_O; //MEM_Rd

            2'b11://D
            salida = PW; //WB_Rd
        endcase
    end

endmodule

//Multiplexer control Unit
module mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
    reg [6:0] salida;

    // assign NOP_S = 6'b0;
    assign MUX_Out = salida;

    always@(*)
    begin
       // NOP_S = 6'b0;

        case(HF_U)
            1'b0: // NOP
            salida = 6'b0;

            1'b1://Control Unit
            salida = C_U;
        endcase

    end

endmodule


/*Multiplexar for stages (este es uno general se puede simplemente 
cambiar las asignaturas segun lo que se necesite)
*/
module mux_2x1_Stages(input [31:0] A, B, input sig, output [31:0] MUX_Out);
    reg [31:0] salida;

    assign MUX_Out = salida;

    always@(*)
    begin
        
        case(sig)
            1'b0: 
            salida = A;

            1'b1:
            salida = B;
        endcase

    end

endmodule

module SExtender(input [23:0] in, output signed [31:0] out1);

    reg signed [31:0] twoscomp;
    reg signed [31:0] result;
    reg signed [31:0] shift_result; 
    reg signed [31:0] temp_reg;

    reg [31:0] in1;
    assign out1 = result; 

    integer i=0;

    always@(*)
    begin

        in1 = {8'b0, in[23:0]};
        twoscomp = ~(in1) + 1'b1;

        for(i=0; i<2; i= i+1)begin
                            // tc = temp_reg[31];
        temp_reg = {twoscomp[29:0], 2'b0};
        end
                        // C = tc;
        shift_result = temp_reg;

        result = shift_result * 4;
        // result = in1 <<< 2;


    end
endmodule

//HAZARD UNIT
module hazard_unit(output reg [1:0] MUX1_signal, MUX2_signal, MUX3_signal, output reg MUXControlUnit_signal, 
                   output reg IF_ID_load, PC_RF_load,
                   input EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable,
                   input [3:0] EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, ID_Bit3_0, 
                   ID_Bit19_16);
    always@(*)
    begin
        //DATA Hazard
        if(EX_load_instr && ((ID_Bit19_16 == EX_Bit15_12)||(ID_Bit3_0 == EX_Bit15_12)))begin
            // ID_EX_pipeline_register reg1(32'b0, 32'b0, 32'b0, 4'b0, 6'b0, 12'b0, 8'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in, ID_Bit15_12_in, ID_ALU_opcodes_in, ID_Bit11_0_in, ID_addresing_modes_in, ID_mem_size_in, ID_mem_read_write_in, clk);
            
            IF_ID_load = 1'b0;
            PC_RF_load = 1'b0;
            MUXControlUnit_signal = 1'b0;
        end

        if(EX_load_instr == 1) 
            MUXControlUnit_signal = 1; //NOP
        else
        MUXControlUnit_signal = 0; //Control Unit
            
        IF_ID_load = 1'b1;//0
        PC_RF_load = 1'b1;//0
        MUXControlUnit_signal = 1'b1;//0
        


        //DATA Forwarding
        // if(EX_RF_Enable && ((ID_Bit19_16 == EX_Bit15_12)||(ID_Bit3_0 == EX_Bit15_12))) begin
        //     //ID_Forwarding = EX_Bit15_12_in;
        //     MUX1_signal = 2'b01;
        //     MUX2_signal = 2'b01; 
        //     MUX3_signal = 2'b01;
        // end else if(MEM_RF_Enable && ((ID_Bit19_16 == MEM_Bit15_12)||(ID_Bit3_0 == MEM_Bit15_12))) begin
        //    // ID_Forwarding = MEM_Bit15_12_in;
        //     MUX1_signal = 2'b10;
        //     MUX2_signal = 2'b10;
        //     MUX3_signal = 2'b10;
        // end else if(WB_RF_Enable && ((ID_Bit19_16 == WB_Bit15_12)||(ID_Bit3_0 == WB_Bit15_12))) begin
        //     //ID_Forwarding = WB_Bit15_12_in;
        //     MUX1_signal = 2'b11;
        //     MUX2_signal = 2'b11; 
        //     MUX3_signal = 2'b11;
        // end else begin
            MUX1_signal = 2'b00;
            MUX2_signal = 2'b00; 
            MUX3_signal = 2'b00;
        // end


        
    end

endmodule