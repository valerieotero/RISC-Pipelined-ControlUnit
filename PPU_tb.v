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
wire [31:0] ID_Bit11_0;
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
wire [1:0] MUX_signal;

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
wire EX_Shift_imm, EX_RF_Enable, EX_mem_size, EX_mem_read_write, ID_mem_size, ID_mem_read_write, Carry, bl;
wire [3:0] EX_ALU_OP;
wire[7:0] EX_addresing_modes, ID_addresing_modes;
wire [8:0] ID_CU, C_U_out, NOP_S;// = 0010001;


/*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

    integer file, fw, code, i; reg [31:0] data;   
    reg [31:0] Address; wire [31:0] DataOut;

    inst_ram256x8 ram1 (DO, PCO);

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
            data_ram.Mem[Address] = data;
            Address = Address + 1;
        end

    $fclose(file);
    Address = #1 32'b00000000000000000000000000000000; //make sure adress starts back in 0 after precharge
    end  


    //para conseguir PC+4
    //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
    alu alu_1(PCO, 32'd4, 4'b0100, 1'b0, PC4, cc_alu_1);

    mux_2x1_Stages mux_2x1_stages_1(PC4, TA, choose_ta_r_nop, PCIN);
    // mux_2x1_Stages mux_2x1_stages_6(PCI, 32'b0, Reset, PCIN);
            
    // //IF/ID reg
    // //IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
    // //                           output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
    // //                           output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
    // //                           input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr, input [31:0] DataOut);
    IF_ID_pipeline_register IF_ID_pipeline_register(ID_Bit23_0, Next_PC,
                                ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, //ID_Bit11_0,
                                ID_Bit15_12, DO_CU,
                                choose_ta_r_nop, IF_ID_Load, clk,Reset, asserted, PC4, DO);
         
    /*module control_unit(output ID_B_instr, MemReadWrite, output [6:0] C_U_out, input clk, Reset, input [31:0] A); */
    //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

    control_unit control_unit1(ID_B_instr, bl, C_U_out,clk, Reset, asserted, DO_CU);

    // //mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
    mux_2x1_ID mux_2x1_ID(C_U_out, MUXControlUnit_signal, ID_CU);
    // //ID_Stage
    Status_register Status_register(cc_main_alu_out, S, cc_out, clk, Reset);
      
    // //SEx4
    // // SExtender(input reg [23:0] in, output signed [31:0] out1);
    SExtender se(ID_Bit23_0, SEx4_out);
 
    // //para conseguir TA
    //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
    alu alu_2(SEx4_out, Next_PC, 4'b0100, 1'b0, TA, cc_alu_2);
   
    // este es el general RF
    // // register_file(PA, PB, PD, PW, PCin, PCout, C, SA, SB, SD, RFLd //hazaerd unit, PCLd, CLK);
    //  output [31:0] PA, PB, PD, PCout;
    //  output [31:0] MO; //output of the 2x1 multiplexer
    // //Inputs
    // input [31:0] PW, PCin;
    // input [3:0] SA, SB, SD, C;
    // input RFLd, PCLd, CLK;
    
    //    register_file(PA, PB, PD, PW, PCin, PCout,      C,            SA,         SB,     SD, RFLd,   HZPCld,  CLK,  RST);
    register_file register_file_1(PA, PB, PD, PW, PCIN, PCO, WB_Bit15_12, ID_Bit19_16, ID_Bit3_0, WB_RF_Enable,  PC_RF_ld ,clk,  Reset); //falta RW = WB_Bit15_12_out

    // //mux_4x2_ID(input [31:0] A_O, PW, M_O, P, input [1:0] HF_U, output [31:0] MUX_Out);
    // //MUX1
    mux_4x2_ID mux_4x2_ID_1(A_O, PW, M_O, PA, MUX1_signal, mux_out_1); //change
    
    // //MUX2
    mux_4x2_ID mux_4x2_ID_2(A_O, PW, M_O, PB, MUX2_signal, mux_out_2);
     
    // //MUX3
    mux_4x2_ID mux_4x2_ID_3(A_O, PW, M_O, PD, MUX3_signal, mux_out_3);
  

    // //ID_EX_pipeline_register(output reg [31:0] register_file_port_MUX1_out, register_file_port_MUX2_out, register_file_port_MUX3_out,/
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

                                mux_out_1, mux_out_2, mux_out_3, ID_Bit15_12, ID_CU,
                                DO_CU, ID_addresing_modes, clk, Reset);    
  
// //MAIN ALU    
// //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] cc_alu_out); //N, Z, C, V
alu alu_main(mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O, cc_main_alu_out);
       
// //Sign_Shift_Extender (input [31:0]A, input [11:0]B, output reg [31:0]shift_result, output reg C);
Sign_Shift_Extender sign_shift_extender_1(mux_out_2_B, EX_Bit11_0, SSE_out, Carry);
  
// //mux between Shifter extender & ALU
mux_2x1_Stages  mux_2x1_stages_2(mux_out_2_B, SSE_out, EX_Shift_imm, EX_MUX_2X1_OUT);
   
// //Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
Cond_Is_Asserted Cond_Is_Asserted (cc_out, ID_Bit31_28, asserted);

// //Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
Condition_Handler Condition_Handler(asserted, ID_B_instr, choose_ta_r_nop);

/*module EX_MEM_pipeline_register(input [31:0] mux_out_3_C, A_O, input [3:0] EX_Bit15_12, cc_main_alu_out, input EX_load_instr, EX_RF_instr, EX_mem_read_write, EX_mem_size, input clk,
                        output reg [31:0] MEM_A_O, MEM_MUX3, output reg [3:0] MEM_Bit15_12, output reg MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);*/
EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, EX_mem_read_write, EX_mem_size, clk,
                        MEM_A_O, MEM_MUX3, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size, Reset);

// //module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input Size);
data_ram256x8 data_ram(Data_RAM_Out, MEM_mem_read_write, MEM_A_O, MEM_MUX3, MEM_mem_size); //,Reset);


// //multiplexer in MEM Stage
mux_2x1_Stages  mux_2x1_stages_3( MEM_A_O,Data_RAM_Out, MEM_load_instr, M_O);

// //module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input [1:0] MEM_load_rf, input clk
//                                 //output [31:0] wb_alu_out, wb_data_r_out,output [3:0] wb_bit15_12, output [1:0] wb_load_rf);
MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, clk,
                                WB_A_O, WB_Data_RAM_Out, WB_Bit15_12, WB_load_instr, WB_RF_Enable, Reset);
   
// //multiplexer in WB Stage
mux_2x1_Stages mux_2x1_stages_4(WB_A_O, WB_Data_RAM_Out, WB_load_instr, PW);
  
//Hazard-Forward Unit
/*
module hazard_unit(output reg [1:0] MUX1_signal, MUX2_signal, MUX3_signal, output reg MUXControlUnit_signal, 
                   output reg IF_ID_load, PC_RF_load,
                   input EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable, ID_shift_imm, clk,
                   input [3:0] EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, ID_Bit3_0, 
                   ID_Bit19_16);
*/
hazard_unit h_u(MUX1_signal, MUX2_signal, MUX3_signal, MUXControlUnit_signal,   //, MUX2_signal, MUX3_signal
            IF_ID_Load, PC_RF_ld,
            EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable, ID_CU[6],clk,
            EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, ID_Bit3_0, ID_Bit19_16);
           
//  PCO, ID_Bit3_0, ID_Bit19_16, ID_CU[6],EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12,  MUX1_signal,MUX2_signal, $time)

   
    
/*--------------------------------------  Toggle Clock  --------------------------------------*/
  
    initial #90 $finish;  //finish simulation on tick 90 (If commented, simulation will enter infinite loop)

    initial begin

        clk = 1'b0; //before tick starts, clk=0

        forever #1 clk = ~clk; 
        
    end  

/*--------------------------------------  Toggle Reset  --------------------------------------*/

    initial begin       

        Reset = 1'b1; //before tick starts, reset=0

        #1 Reset = 1'b0; //after two ticks, change value to 0                    
      
    end   

/*--------------------------------------  MONITOR SENALES DE CONTROL  --------------------------------------*/ 

//  initial begin
        
//      $display("\n\n                    --------------------ID State---------------------           ----------------EX State---------------       --------MEM State------        ---WB State---           -------Instruction-------        --Time--");
//      $display("           PC    B_instr | shift_imm |   alu  | load | R F | m_rw | m_s       shift_imm | alu  | load | R F | m_rw | m_s      load | R F | m_rw | m_s          load | R F          \n");
//      $monitor("  %d         %b   |     %b     |  %b  |  %b   |  %b  |   %b  |  %b               %b  | %b |   %b  |  %b  |   %b  |  %b         %b  |  %b  |   %b  |  %b             %b  |  %b           %b        %0d\n", PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  ID_mem_size, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, EX_mem_size, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size, WB_load_instr, WB_RF_Enable, DO_CU, $time);

//  end


/*--------------------------------------  MONITOR REGISTROS  --------------------------------------*/ 

initial begin
    // #70;
    /*------------------------------------------- IF_ID STAGE --------------------------------------------------------------------------*/
                
    //   
    // $monitor("PC: %d  | DR-Address: %d  | Destino: %d  | instrIF: %b  |  instrID: %b  |  ID_Bit23_0: %d  | Next_PC: %d  | RN: %d  |  RM:  %d    | INSTR_SHIFTEREXT: %d  | RD: %d  | NOP_COND_HANDLER: %b  |  PP_LOAD(hfu): %b  | asserted: %b  |  PC4: %d  | RESET: %d | TA:%d", PCO, MEM_A_O, WB_Bit15_12, DO, DO_CU, ID_Bit23_0, Next_PC, ID_Bit19_16, ID_Bit3_0, ID_Bit11_0, ID_Bit15_12, choose_ta_r_nop, IF_ID_Load, asserted, PC4,Reset, TA);


    /*------------------------------------------- CONTROL SIGNALS --------------------------------------------------------------------------*/


    // $monitor( "PC: %d  | ADDRS: %d | Instr_ID: %b  | Branch?: %d  |  Mem_Size: %d  | Read_W:  %d    |  Shift_imm: %d  | Alu_op: %b  | load_instr: %b  | RegFile_load:  %d  | time: %3d  | reset: %d  | asserted: %d | CU_MUX_OUT: %b | mux signal: %b", PCO, MEM_A_O, DO_CU, ID_B_instr, ID_CU[8], ID_CU[7], ID_CU[6], ID_CU[5:2],ID_CU[1],ID_CU[0] ,$time, Reset, asserted, C_U_out, MUXControlUnit_signal );
    // $monitor("PC:%d | Instr -IF: %b | time:%d ", PCO, DO, $time);
    // $monitor("PC:%d | Instr -IF: %b | Instr -ID: %b | time:%d ", PCO, DO, DO_CU, $time);

    /*------------------------------------------- ID_EX STAGE --------------------------------------------------------------------------*/

    //  $monitor("PC: %d  | DR-Address: %d  | instrID: %b  | instrEX: %b  | RD_ID: %d  | ID_Read_W:  %d  | ID_Mem_Size: %d  | ID_Shi_imm: %d  | ID_Alu_op: %b  | ID_lo_instr: %b  | ID_RegF_load:  %d  |ID_addres_modes: %d  | mux_o_1ID:  %3d | mux_o_2ID: %3d  | mux_o_3ID: %3d  | mux_o_1EX:%3d | mux_o_2EX: %3d | mux_o_3EX: %3d | RD_EX: %d | EX_Shi_imm:%d | EX_ALU_OP:%d | EX_lo_instr: %d | EX_RF_E: %d | EX_Bit11_0: %d | EX_addres_modes:%d | EX_mem_size: %d | EX_mem_read_w: %d ", PCO, MEM_A_O, DO_CU, EX_Bit11_0, ID_Bit15_12,ID_CU[7], ID_CU[8], ID_CU[6], ID_CU[5:2],ID_CU[1],ID_CU[0],ID_addresing_modes,mux_out_1,mux_out_2,mux_out_3,mux_out_1_A, mux_out_2_B, mux_out_3_C, EX_Bit15_12, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_Bit11_0, EX_addresing_modes, EX_mem_size, EX_mem_read_write) ;

    //  $monitor("PC: %d  | DR-Address: %d  | mux_o_1ID:  %3d | mux_o_2ID: %3d  | mux_o_3ID: %3d  | mux_o_1EX:%3d | mux_o_2EX: %3d | mux_o_3EX: %3d  | SIG MUX2:%b |MUXOUT:%3d  | MUXSSE SIG:%d | SSE:%3d | Alu out: %3d  ", PCO, MEM_A_O, mux_out_1,mux_out_2,mux_out_3,mux_out_1_A, mux_out_2_B, mux_out_3_C, MUX2_signal, EX_MUX_2X1_OUT,EX_Shift_imm, SSE_out, A_O);
    // $monitor(" PC: %d  | DR-Address: %d  | A_O:%d | PW:%d | M_O:%d | PB:%d | MUX2_signal:%d | mux_out_2:%d | mux2-EX: %d", PCO, MEM_A_O, A_O, PW, M_O, PB, MUX2_signal, mux_out_2,    mux_out_2_B);

    // $display("\n\n         PC    DR-Address    RFEnable       PW       Destino             DR-Out                            WB_DR-Out                                 instrID               IDLD  EXLD   MLD   Time     MUX1        MUX2     MUX3    MEM_LOAD WB_LOAD   EX_S_Imm    SSEXT          alu_a          alu_b      alo_op   alu_carry   alu_out");   
    // $monitor("%d  |  %d  |    %d    |  %d  |  %d  |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  |  %3d  |  %9d  |  %3d   |    %0d    |    %0d    |   %0d   |  %10d  |  %10d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, PW, WB_Bit15_12, Data_RAM_Out, WB_Data_RAM_Out, DO_CU, C_U_out[0], EX_RF_Enable, MEM_RF_Enable, $time, mux_out_1_A, mux_out_2_B, mux_out_3_C, MEM_load_instr, WB_load_instr, EX_Shift_imm, SSE_out, mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O);
 
    // $display("\n\n         PC    DR-Address  RFEnable MUX_WB    PW       Destino   R2              WB_Data_RAM_Out                        instrID                              instrEX                 IDLD  EXLD  MLD   Time      MUX3         MUX3S     MUX1/alu_a   MUX1S     MUX2_a      MUX2S  EX_Bit11_0_b     SSEXT      ID_S_Imm  EX_S_Imm    alu_b    alo_op   alu_carry   alu_out");   
    // $monitor("%d  | %10d |    %d    |  %d  | %10d |  %d  | %3d |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  |  %10d  |  %3d  |   %10d  |  %3d  |  %10d  | %3d  | %10d |  %10d  |  %3d  | %3d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, WB_load_instr, PW, WB_Bit15_12, register_file_1.R2.Q, WB_Data_RAM_Out, DO_CU, EX_Bit11_0, ID_CU[0], EX_RF_Enable, MEM_RF_Enable, $time, mux_out_3_C, MUX3_signal, mux_out_1_A, MUX1_signal, mux_out_2_B, MUX2_signal, EX_Bit11_0, SSE_out, ID_CU[6], EX_Shift_imm, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O);
    

/*------------------------------------------- FOR REGISTERS ONLY --------------------------------------------------------------------------*/
    //  $monitor("PC: %d  |  DR-Address: %d  |  R0: %d  | R1: %d  |  R2: %d  | R3: %d  | R5: %d  | R15: %d  | ALU Salida: %d  |  DATA RAM OUT: %d  | Size_Mem:%b | Size CU:%b |  Time: %2d ", PCO, MEM_A_O, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q,A_O, Data_RAM_Out, MEM_mem_size, ID_CU[8], $time);
        $monitor("PC: %d  |  DR-Address: %d  | R1: %d  |  R2: %d  | R3: %d  | R5: %d  | Time: %2d ", PCO, MEM_A_O, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, $time);


/*------------------------------------------- FOR REGISTERS AND LOAD SIGNALS--------------------------------------------------------------------------*/

    // $display("\n\n         PC    DR-Address  RFEnable MUX_WB    PW       Destino   R2              WB_Data_RAM_Out                        instrID                              instrEX                 IDLD  EXLD  MLD   Time      MUX3         MUX3S     MUX1/alu_a   MUX1S     MUX2_a      MUX2S  EX_Bit11_0_b     SSEXT      ID_S_Imm  EX_S_Imm    alu_b    alo_op   alu_carry   alu_out");   
    // $monitor("%d  | %10d |    %d    |  %d  | %10d |  %d  | %3d |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  |  %10d  |  %3d  |   %10d  |  %3d  |  %10d  | %3d  | %10d |  %10d  |  %3d  | %3d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, WB_load_instr, PW, WB_Bit15_12, register_file_1.R2.Q, WB_Data_RAM_Out, DO_CU, EX_Bit11_0, ID_CU[0], EX_RF_Enable, MEM_RF_Enable, $time, mux_out_3_C, MUX3_signal, mux_out_1_A, MUX1_signal, mux_out_2_B, MUX2_signal, EX_Bit11_0, SSE_out, ID_CU[6], EX_Shift_imm, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O);
    
  
/*------------------------------------------- FOR HAZARD UNIT --------------------------------------------------------------------------*/

    // $monitor("PC: %2d  |PA: %d  | PB: %d | PD: %d | A_O: %d | M_O: %d | PW: %d | MUX1: %d  | MUX2: %d | MUX3: %d | MUX1_S: %b | MUX2_S: %b | MUX3_S: %b | ID_B3_0: %d  | ID_B19_16: %d  | ID_Shift_imm: %d | EX_B15_12: %d  | MEM_B15_12: %d  | WB_B15_12: %d  | EX_RF_E: %d  | MEM_RF_E: %d  | WB_RF_E: %d | Time: %0d  ", PCO, PA, PB, PD, A_O, M_O, PW, mux_out_1, mux_out_2, mux_out_3, MUX1_signal,MUX2_signal,MUX3_signal, ID_Bit3_0, ID_Bit19_16, ID_CU[6],EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable, $time);
    // $monitor("PC: %2d  | ID_B3_0: %d  | ID_B19_16: %d  | ID_Shift_imm: %d | EX_B15_12: %d  | MEM_B15_12: %d  | WB_B15_12: %d  |  MUX1_S: %b | MUX2_S: %b | Time: %0d  ", PCO, ID_Bit3_0, ID_Bit19_16, ID_CU[6],EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12,  MUX1_signal,MUX2_signal, $time);

/*------------------------------------------- FOR ALU/SHIFT EXTENDER --------------------------------------------------------------------------*/
   
    //  $display("\n\n PC       ADDRS    PA   PB     PD      A_O           M_O         PW            MUX1        ALU_a          MUX2     SSE_A/MUX_A   SSEout    MUXSSEALU   MUX3    MUX1_S   MUX2_S  MUX3_S    Time"); //clk");  
    // $monitor("%2d  | %10d | %3d | %3d | %3d | %10d | %10d | %10d | %10d  | %10d | %10d | %10d | %10d | %6d | %6d | %6d | %6d | %6d |   %2d  ", PCO, MEM_A_O, PA, PB, PD, A_O, M_O, PW, mux_out_1, mux_out_1_A, mux_out_2, mux_out_2_B, SSE_out,EX_MUX_2X1_OUT, mux_out_3, MUX1_signal,MUX2_signal,MUX3_signal, $time);//, clk);

/*------------------------------------------- MUX IN MEM STAGE --------------------------------------------------------------------------*/
//    $display("\n\n   PC   PCIN  MEM_A_O   Data_RAM_Out   MEM_Load_instr      M_O      EX_Load_instr   A_O    Time");  
//     $monitor(" %3d  | %3d  |  %3d  | %12d  |  %12d | %10d | %12d | %3d  | %2d ", PCO, PCIN, MEM_A_O,Data_RAM_Out, MEM_load_instr, M_O, EX_load_instr,A_O,$time);
 
 /*------------------------------------------- FOR ALU/SHIFT EXTENDER 2 --------------------------------------------------------------------------*/
   
    //  $display("\n\n PC       ADDRS     PA    PB      A_O           M_O         PW            MUX1        ALU_a          MUX2     SSE_A/MUX_A   SSEout    MUXSSEALU    MUX1_S   MUX2_S   Time"); //clk");  
//    $monitor("PC: %d  | ADDRS: %d | Ist_EX: %b | PA: %d | PB: %d | A_O: %d | M_O: %d | PW: %d | MUX1: %d  | ALU_a: %d | MUX2: %d | SSE_A/MUX_A: %d | SSEout: %d | MUXSSEALU: %d |  MUXSSEALU_Sig: %b |  Shift_imm_ID: %b | MUX1_S: %b | MUX2_S: %b | Alu_op: %b |  Time: %0d  ", PCO, MEM_A_O, EX_Bit11_0, PA, PB, A_O, M_O, PW, mux_out_1, mux_out_1_A, mux_out_2, mux_out_2_B, SSE_out,EX_MUX_2X1_OUT,EX_Shift_imm, ID_CU[6], MUX1_signal,MUX2_signal, EX_ALU_OP, $time);//, clk);
//    $monitor("PC: %d  | ADDRS: %d | Ist_ID: %b | PA: %3d | PB: %3d | A_O: %d | M_O: %d | PW: %d | MUX1: %3d  | ALU_a: %3d | MUX2: %3d | SSE_A/MUX_A: %3d | SSEout: %3d | MUXSSEALU: %3d |  MUXSSEALU_Sig: %b |  Shift_imm_ID: %b | MUX1_S: %b | MUX2_S: %b | Alu_op: %b |  Time: %0d  ", PCO, MEM_A_O, DO_CU, PA, PB, A_O, M_O, PW, mux_out_1, mux_out_1_A, mux_out_2, mux_out_2_B, SSE_out,EX_MUX_2X1_OUT,EX_Shift_imm, ID_CU[6], MUX1_signal,MUX2_signal, EX_ALU_OP, $time);//, clk);
//    $monitor("PC: %d  | ADDRS: %d | Ist_IF: %b | PA: %3d | PB: %3d | A_O: %d | M_O: %d | PW: %d | MUX1: %3d  | ALU_a: %3d | MUX2: %3d | SSE_A/MUX_A: %3d | SSEout: %3d | MUXSSEALU: %3d |  MUXSSEALU_Sig: %b |  Shift_imm_ID: %b | MUX1_S: %b | MUX2_S: %b | Alu_op: %b |  Time: %0d  ", PCO, MEM_A_O, DO, PA, PB, A_O, M_O, PW, mux_out_1, mux_out_1_A, mux_out_2, mux_out_2_B, SSE_out,EX_MUX_2X1_OUT,EX_Shift_imm, ID_CU[6], MUX1_signal,MUX2_signal, EX_ALU_OP, $time);//, clk);
//    $monitor("PC: %d  | ADDRS: %d | Ist_IF: %b | Ist_ID: %b |  Ist_EX: %b |  ALU_a: %d | MUX_A: %d | MUX_B: %d | SSE: %d | MUXSSEALU_Sig: %b |  MUXSSE_ALU_b: %d |  A_O: %d |  Alu_op: %b |  Time: %0d  ", PCO, MEM_A_O, DO, DO_CU, EX_Bit11_0, mux_out_1_A, mux_out_2_B, EX_Bit11_0, SSE_out, EX_Shift_imm,  EX_MUX_2X1_OUT, A_O, EX_ALU_OP, $time);//, clk);


 /*------------------------------------------- CONDITION ASSERTED --------------------------------------------------------------------------*/
    // $monitor("PC: %d | Instr: %b | cc_out: %b | ID_Bit31_28:%b | asserted: %b", PCO, DO_CU, cc_out, ID_Bit31_28, asserted);

 /*------------------------------------------- REGISTER FILE --------------------------------------------------------------------------*/
    //  $monitor("PC: %d  |  DR-Address: %d  |  R0: %d  | R1: %d  |  R2: %d  | R3: %d  | R5: %d  | R15: %d  | RF_PA: %d | PA: %d  |  RF_PB: %d | PB: %d | Time: %2d ", PCO, MEM_A_O, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q, register_file_1.muxA.P, PA, register_file_1.muxB.P,PB, $time);

//RF Testing

//$monitor("CRF: %d | RFLd %d | R0 %d | R1 %d | R2 %d | R3 %d | R5 %d | PW @ RF %d | E %b | RST %b | PW  Reg %d | RFld %b | CLK: %b", register_file_1.C, register_file_1.RFLd, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.PW, register_file_1.E[0], register_file_1.RST, register_file_1.R2.PW, register_file_1.R0.RFLd, register_file_1.CLK);
//$monitor("PC: %d | CRF: %d | CPPU: %d | RFLd %d | R0 %d | R1 %d | R2 %d | R3 %d | R5 %d | R15 %d | PW @ RF %d | E %b", PCO, register_file_1.C, WB_Bit15_12, register_file_1.RFLd, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q, register_file_1.PW, register_file_1.E[15]);

    // $monitor("\n DataIn = %2d | Address: %2d | ReadWrite: %d | Size = %b | Data_RAM_Out: %d  at time: %0d", MEM_MUX3, MEM_A_O, MEM_mem_read_write, MEM_mem_size, Data_RAM_Out, $time);

/*---------------------------------------------------------------- DATA RAM --------------------------------------------------------------------------*/

   // $monitor("\n DataIn = %d | Address: %d | ReadWrite: %d | Size = %b | Data_RAM_Out: %d  at time: %0d", MEM_MUX3, MEM_A_O, MEM_mem_read_write, MEM_mem_size, Data_RAM_Out, $time);

end


/*
 integer x=0; 
 initial begin
    #82; //Profe said 82 was good time to print content
    $display("\n\n--------------------------------------  Data Ram Content After Simulation  --------------------------------------\n");  

    for (x=0; x<256; x = x +1) //256 because its the total amount of localizations. So prof can literally see all the content of the ram
    begin   
        $display("Data en Address %0d = %d at time: %0d", x, data_ram.Mem[x], $time);
    
    end
 end */


endmodule