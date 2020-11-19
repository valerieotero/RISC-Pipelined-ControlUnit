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
wire EX_Shift_imm, EX_RF_Enable, EX_mem_size, EX_mem_read_write, ID_mem_size, ID_mem_read_write, Carry;
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
            data_ram.Mem[Address] = data;
            Address = Address + 1;
        end

    $fclose(file);
    Address = #1 32'b00000000000000000000000000000000; //make sure adress starts back in 0 after precharge
    end  


    //para conseguir PC+4
    //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] Alu_Out);
    alu alu_1(PCO, 32'd4, 4'b0100, 1'b0, PC4, cc_alu_1);

    mux_2x1_Stages mux_2x1_stages_1(PC4, TA, choose_ta_r_nop, PCI);
    mux_2x1_Stages mux_2x1_stages_6(PCI, 32'b0, Reset, PCIN);
            
    // //IF/ID reg
    // //IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
    // //                           output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
    // //                           output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
    // //                           input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr, input [31:0] DataOut);
    IF_ID_pipeline_register IF_ID_pipeline_register(ID_Bit23_0, Next_PC,
                                ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, ID_Bit11_0,
                                ID_Bit15_12, DO_CU,
                                choose_ta_r_nop, IF_ID_Load, clk,Reset, asserted, PC4, DO);
         
    // //ID_Stage
    Status_register Status_register(cc_main_alu_out, S, cc_out, clk);
      
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
    mux_4x2_ID mux_4x2_ID_1(A_O, PW, M_O, PA, MUX1_signal, mux_out_1);
    
    // //MUX2
    mux_4x2_ID mux_4x2_ID_2(A_O, PW, M_O, PB, MUX2_signal, mux_out_2);
     
    // //MUX3
    mux_4x2_ID mux_4x2_ID_3(A_O, PW, M_O, PD, MUX3_signal, mux_out_3);
  
    /*module control_unit(output ID_B_instr, MemReadWrite, output [6:0] C_U_out, input clk, Reset, input [31:0] A); */
    //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

    control_unit control_unit1(ID_B_instr, ID_mem_read_write, ID_mem_size, C_U_out,clk, Reset, asserted, DO_CU);

    // //mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
    mux_2x1_ID mux_2x1_ID(C_U_out, MUXControlUnit_signal, ID_CU);

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

                                mux_out_1, mux_out_2, mux_out_3, ID_Bit15_12, ID_CU,
                                DO_CU, ID_addresing_modes, ID_mem_size, ID_mem_read_write, clk);    
  
// //MAIN ALU    
// //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] cc_alu_out); //N, Z, C, V
alu alu_main(mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O, cc_main_alu_out);
       
// //Sign_Shift_Extender (input [31:0]A, input [11:0]B, output reg [31:0]shift_result, output reg C);
Sign_Shift_Extender sign_shift_extender_1(mux_out_2_B, EX_Bit11_0, SSE_out, Carry);
  
// //mux between Shifter extender & ALU
mux_2x1_Stages  mux_2x1_stages_2(mux_out_2_B, SSE_out, EX_Shift_imm, EX_MUX_2X1_OUT);
   
// //Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
Cond_Is_Asserted Cond_Is_Asserted (cc_out, ID_Bit31_28,clk, asserted);

// //Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
Condition_Handler Condition_Handler(asserted, ID_B_instr, choose_ta_r_nop);

/*module EX_MEM_pipeline_register(input [31:0] mux_out_3_C, A_O, input [3:0] EX_Bit15_12, cc_main_alu_out, input EX_load_instr, EX_RF_instr, EX_mem_read_write, EX_mem_size, input clk,
                        output reg [31:0] MEM_A_O, MEM_MUX3, output reg [3:0] MEM_Bit15_12, output reg MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);*/
EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, EX_mem_read_write, EX_mem_size, clk,
                        MEM_A_O, MEM_MUX3, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);

// //module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input Size);
data_ram256x8 data_ram(Data_RAM_Out, MEM_mem_read_write, MEM_A_O, MEM_MUX3, MEM_mem_size,Reset);


// //multiplexer in MEM Stage
mux_2x1_Stages  mux_2x1_stages_3(Data_RAM_Out, MEM_A_O, MEM_load_instr, M_O);

// //module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input [1:0] MEM_load_rf, input clk
//                                 //output [31:0] wb_alu_out, wb_data_r_out,output [3:0] wb_bit15_12, output [1:0] wb_load_rf);
MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, clk,
                                WB_A_O, WB_Data_RAM_Out, WB_Bit15_12, WB_load_instr, WB_RF_Enable);
   
// //multiplexer in WB Stage
mux_2x1_Stages mux_2x1_stages_4(WB_A_O, WB_Data_RAM_Out, WB_load_instr, PW);
  
//Hazard-Forward Unit
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

   
    
/*--------------------------------------  Toggle Clock  --------------------------------------*/
    //finish simulation on tick 30 (If commented, simulation will enter infinite loop, but if uncommented data ram content after simulation will not display)
    initial #30 $finish; 

    initial begin

        clk = 1'b0; //before tick starts, clk=0

        forever #1 clk = ~clk; end  //enough repeats to read all instructions 

/*--------------------------------------  Toggle Reset  --------------------------------------*/

    initial fork       

        Reset = 1'b1; //before tick starts, reset=0

        #1 Reset = 1'b0; //after two ticks, change value to 0                    
      
    join   

/*--------------------------------------  MONITOR SENALES DE CONTROL  --------------------------------------*/ 

//  initial begin
        
//      $display("\n\n                    --------------------ID State---------------------           ----------------EX State---------------       --------MEM State------        ---WB State---           -------Instruction-------        --Time--");
//      $display("           PC    B_instr | shift_imm |   alu  | load | R F | m_rw | m_s       shift_imm | alu  | load | R F | m_rw | m_s      load | R F | m_rw | m_s          load | R F          \n");
//      $monitor("  %d         %b   |     %b     |  %b  |  %b   |  %b  |   %b  |  %b               %b  | %b |   %b  |  %b  |   %b  |  %b         %b  |  %b  |   %b  |  %b             %b  |  %b           %b        %0d\n", PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  ID_mem_size, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, EX_mem_size, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size, WB_load_instr, WB_RF_Enable, DO_CU, $time);

//  end


/*--------------------------------------  MONITOR REGISTROS  --------------------------------------*/ 

initial begin      
    // $display("\n\n         PC    DR-Address    R0         R1          R2      R3     R5    R15     RFEnable       PW       Destino             DR-Out                                 instrIF                              instrID               IDLD  EXLD   MLD   Time      A_OM1         PAM1           M_OM1        PWM1e         MUX1         A_OM2       PBM2          M_OM2          PWM2            MUX2          A_OM3            PDM3       M_OM3          PWM3         MUX3    MEM LOAD    EX_S_Imm");   

    //    //     PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time 
    // $monitor("%d  |  %d  |  %0d  | %d  |  %3d  |  %3d  |  %3d  |  %3d  |    %d    |  %d  |  %d  |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  | %10d  |  %10d  |  %10d |  %10d  |  %3d  |  %d  |  %10d  | %10d  |  %10d  |  %9d  |  %d  |  %d  |  %10d  | %10d  |  %3d   |    %0d    |  %0d   ", PCO, MEM_A_O, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q, WB_RF_Enable, PW, WB_Bit15_12, Data_RAM_Out, DO, DO_CU, C_U_out[0], EX_RF_Enable, MEM_RF_Enable, $time,mux_4x2_ID_1.A_O, PA, mux_4x2_ID_1.M_O,mux_4x2_ID_1.PW, mux_out_1,mux_4x2_ID_2.A_O, PB, mux_4x2_ID_2.M_O,mux_4x2_ID_2.PW, mux_out_2,mux_4x2_ID_3.A_O, PD, mux_4x2_ID_3.M_O,mux_4x2_ID_3.PW, mux_out_3, MEM_load_instr, EX_Shift_imm);


//   $display("\n\n         PC    DR-Address    RFEnable       PW       Destino             DR-Out                                 instrID               IDLD  EXLD   MLD   Time      A_OM1         PAM1           M_OM1        PWM1e         MUX1         A_OM2       PBM2          M_OM2          PWM2            MUX2          A_OM3            PDM3       M_OM3          PWM3         MUX3    MEM LOAD EX_S_Imm    alu_a          alu_b      alo_op   alu_carry   alu_out");   

//        //     PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time 
//     $monitor("%d  |  %d  |    %d    |  %d  |  %d  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  | %10d  |  %10d  |  %10d |  %10d  |  %3d  |  %d  |  %10d  | %10d  |  %10d  |  %9d  |  %d  |  %d  |  %10d  | %10d  |  %3d   |    %0d    |   %0d   |  %10d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, PW, WB_Bit15_12, Data_RAM_Out, DO_CU, C_U_out[0], EX_RF_Enable, MEM_RF_Enable, $time,mux_4x2_ID_1.A_O, PA, mux_4x2_ID_1.M_O,mux_4x2_ID_1.PW, mux_out_1,mux_4x2_ID_2.A_O, PB, mux_4x2_ID_2.M_O,mux_4x2_ID_2.PW, mux_out_2,mux_4x2_ID_3.A_O, PD, mux_4x2_ID_3.M_O,mux_4x2_ID_3.PW, mux_out_3, MEM_load_instr, EX_Shift_imm, mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, C, A_O);


    // $display("\n\n         PC    DR-Address    RFEnable       PW       Destino             DR-Out                            WB_DR-Out                                 instrID               IDLD  EXLD   MLD   Time     MUX1        MUX2     MUX3    MEM_LOAD WB_LOAD   EX_S_Imm    SSEXT          alu_a          alu_b      alo_op   alu_carry   alu_out");   

    //    //     PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time 
    // $monitor("%d  |  %d  |    %d    |  %d  |  %d  |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  |  %3d  |  %9d  |  %3d   |    %0d    |    %0d    |   %0d   |  %10d  |  %10d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, PW, WB_Bit15_12, Data_RAM_Out, WB_Data_RAM_Out, DO_CU, C_U_out[0], EX_RF_Enable, MEM_RF_Enable, $time, mux_out_1_A, mux_out_2_B, mux_out_3_C, MEM_load_instr, WB_load_instr, EX_Shift_imm, SSE_out, mux_out_1_A, EX_MUX_2X1_OUT, EX_ALU_OP, C, A_O);

    // $display("\n\n         PC    DR-Address    RFEnable   MUX_WB    PW       Destino      R1            R2                    WB_Data_RAM_Out                       instrID                            instrEX                 IDLD  EXLD  MLD   Time      MUX3         MUX3S      MUX1/alu_a   MUX1S     MUX2_a      MUX2S  EX_Bit11_0_b     SSEXT      ID_S_Imm  EX_S_Imm    alu_b    alo_op   alu_carry   alu_out");   

    //    //     PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time 
    // $monitor("%d  |  %d  |    %d    |  %d  |  %d  |  %d  |  %d  |  %d  |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %2d  |  %10d  |  %3d  |   %10d  |  %3d  |  %10d  | %3d  | %10d |  %10d  |  %3d  | %3d  | %10d  |  %3d   |    %0d    |  %0d  ", PCO, MEM_A_O, WB_RF_Enable, WB_load_instr, PW, WB_Bit15_12, register_file_1.R1.Q,register_file_1.R2.Q, WB_Data_RAM_Out, DO_CU, EX_Bit11_0, ID_CU[0], EX_RF_Enable, MEM_RF_Enable, $time, mux_out_3_C, MUX3_signal, mux_out_1_A, MUX1_signal, mux_out_2_B, MUX2_signal, EX_Bit11_0, SSE_out, ID_CU[6], EX_Shift_imm, EX_MUX_2X1_OUT, EX_ALU_OP, Carry, A_O);
    $display("\n\n         PC    DR-Address    R0         R1          R2      R3     R5    R15    ");   

       //     PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time 
    $monitor("%d  |  %d  |  %0d  | %d  |  %3d  |  %3d  |  %3d  |  %3d   ", PCO, MEM_A_O, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q);


            //PC    DataRam  R0    R1     R2     R3     R5     R15     LDRF      PW   Destino DR-O  instrIF instrID IDLD   EXLD   MLD   time
    // $monitor("%d  |  %d  |  %0d  | %d  |  %d  |  %d  |  %d  |  %d  |    %d    |  %d  |  %d  |  %b  |  %b  |  %b  |  %d  |  %d  |  %d  |  %0d", PCO, MEM_A_O, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q, WB_RF_Enable, PW, WB_Bit15_12, Data_RAM_Out, DO, DO_CU, C_U_out[0], EX_RF_Enable, MEM_RF_Enable, $time);

//RF Testing

//$monitor("CRF: %d | RFLd %d | R0 %d | R1 %d | R2 %d | R3 %d | R5 %d | PW @ RF %d | E %b | RST %b | PW  Reg %d | RFld %b | CLK: %b", register_file_1.C, register_file_1.RFLd, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.PW, register_file_1.E[0], register_file_1.RST, register_file_1.R2.PW, register_file_1.R0.RFLd, register_file_1.CLK);
//$monitor("PC: %d | CRF: %d | CPPU: %d | RFLd %d | R0 %d | R1 %d | R2 %d | R3 %d | R5 %d | R15 %d | PW @ RF %d | E %b", PCO, register_file_1.C, WB_Bit15_12, register_file_1.RFLd, register_file_1.R0.Q, register_file_1.R1.Q, register_file_1.R2.Q, register_file_1.R3.Q, register_file_1.R5.Q, register_file_1.R15.Q, register_file_1.PW, register_file_1.E[15]);

end



 /*--------------------------------------  MONITOR MUX 1, 2 and 3  --------------------------------------*/ 

//initial begin
    
 //   $monitor("\nMux1: %d | Mux2: %d | Mux3: %d  at time: %0d\n",mux_out_1,mux_out_2,mux_out_3, $time);

//end


/*
 integer x=0; 
 initial begin
 #20;
 $display("\n\n--------------------------------------  Data Ram Content After Simulation  --------------------------------------\n");  

 for (x=0; x<256; x = x +4) //256 because its the total amount of localizations. So prof can literally see all the content of the ram
 begin   
     $display("Data en Address %0d = %b %b %b %b  at time: %0d", x, data_ram.Mem[x],data_ram.Mem[x+1],data_ram.Mem[x+2],data_ram.Mem[x+3], $time);
  
 end
 end */


endmodule