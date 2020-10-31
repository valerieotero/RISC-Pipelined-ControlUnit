`include "register_file/PF1_Nazario_Morales_Victor_rf.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_Sign_Shift_Extender.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_ALU.v"


//PPU
module main(input clk);
        //IF Stage
        //para escoger entre TA & PC+4
        mux_2x1_Stages mux_2x1_stages_1(PC4, TA, choose_ta_r_nop, PCin);
        inst_ram256x8 inst_ram(DataOut, Enable, PCout);
        //para conseguir PC+4
        alu alu_1(PCout,32'd4, 4'b0100, cc_out[1], PC4, vv);


        //IF/ID reg
        //IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
        //                           output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
        //                           output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
        //                           input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr, input [31:0] DataOut);
        IF_ID_pipeline_register IF_ID_pipeline_register(ID_Bit23_0, Next_PC, S,
                                    ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, ID_Bit11_0,
                                    ID_Bit15_12, ID_Bit31_0,
                                    choose_ta_r_nop, Hazard_Unit_Ld, clk, PC4, ram_instr, DataOut);

        
        
        //ID_Stage
        Status_register Status_register(cc_main_alu_out, S, cc_out, clk);
        
        //SEx4

        //para conseguir TA
        //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output N, Z, C, V);
        alu alu_2(SEx4_out,ID_Next_PC, 4'b0100, cc_out[1], TA, N, Z, C, V);

        // este es el general RF
        // register_file(PA, PB, PD, PW, PCin, PCout, C, SA, SB, SD, RFLd, PCLd, CLK);
        
        register_file register_file_1(PA, PB, PD, PW, PCin, PCout, WB_Bit15_12_out, ID_Bit19_16, ID_Bit3_0, SD, RFLd, PCLd, CLK); //falta RW = WB_Bit15_12_out

        //mux_4x2_ID(input [31:0] A_O, PW, M_O, P, input [1:0] HF_U, output MUX_Out);
        //MUX1
        mux_4x2_ID mux_4x2_ID_1(A_O, PW, M_O, PA, A, register_file_port_MUX1_in);
        //MUX2
        mux_4x2_ID mux_4x2_ID_2(A_O, PW, M_O, PB, B, register_file_port_MUX2_in);
        //MUX3
        mux_4x2_ID mux_4x2_ID_3(A_O, PW, M_O, PD, C, register_file_port_MUX3_in);

        //control_unit(output ID_B_instr, ALUSrc, RegDst,  
        //                MemReadWrite, PCSrc, RegWrite, MemToReg, Branch, Jump, output [6:0] C_U_out, 
        //               input clk, input [31:0] A); 
        //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

        control_unit control_unit(ID_B_instr, ALUSrc, RegDst, MemReadWrite, PCSrc, RegWrite, MemToReg, Branch, Jump, C_U_out, 
                        clk, ID_Bit31_0);

        //mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
        mux_2x1_ID mux_2x1_ID(C_U_out, NOP_S, HF_U, ID_MUX_2x1_ID_Out);



        //ID_EX_pipeline_register(output reg [31:0] register_file_port_MUX1_out, register_file_port_MUX2_out, register_file_port_MUX3_out,
        //                            output reg [3:0] EX_Bit15_12_out, EX_ALU_opcodes_out,
        //                            output reg [11:0] EX_Bit11_0_out,
        //                            output reg [7:0] EX_addresing_modes_out,
        //                            output reg EX_branch_instr_out, EX_load_instr_out, EX_RF_enable_out, EX_shifter_imm_out,
        //                            EX_mem_size_out, EX_mem_read_write_out,
        //
        //                            input [31:0] register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in,
        //                            input [3:0] ID_Bit15_12_in, ID_ALU_opcodes_in, 
        //                            input [11:0] ID_Bit11_0_in,
        //                            input [7:0] ID_addresing_modes_in,
        //                            input ID_branch_instr_in, ID_load_instr_in, ID_RF_enable_in, ID_shifter_imm_in,
        //                            ID_mem_size_in, ID_mem_read_write_in, input clk);    

        ID_EX_pipeline_register ID_EX_pipeline_register(EX_register_file_port_MUX1_out, EX_register_file_port_MUX2_out, EX_register_file_port_MUX3_out,
                                        EX_Bit15_12_out, 
                                        EX_Bit11_0_out,
                                        EX_addresing_modes_out,
                                        EX_MUX_2x1_ID_Out,
                                        EX_mem_size_out, EX_mem_read_write_out,

                                        register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in,
                                        ID_Bit15_12_in,
                                        ID_Bit11_0_in,
                                        ID_addresing_modes_in,
                                        ID_MUX_2x1_ID_Out,
                                        ID_mem_size_in, ID_mem_read_write_in, clk);    




        //MAIN ALU    
        //alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output [3:0] cc_alu_out); //N, Z, C, V);
        alu alu_3(EX_register_file_port_MUX1_out, EX_MUX_2X1_OUT, EX_MUX_2x1_ID_Out[5:2], cc_out[1], A_O, cc_main_alu_out);

        //Sign_Shift_Extender (input [2:0] shifter_op,input [1:0] by_imm_shift, input [31:0]A, input [11:0]B, output reg [31:0]shift_result, output reg C);
        Sign_Shift_Extender sign_shift_extender_1(shifter_op, by_imm_shift, EX_register_file_port_MUX2_out, ID_Bit31_0, SSE_out, C);

        //mux between Shifter extender & ALU
        mux_2x1_Stages  mux_2x1_stages_2(EX_register_file_port_MUX2_out, SSE_out, EX_MUX_2x1_ID_Out[6], EX_MUX_2X1_OUT);

        //Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition, output asserted);
        Cond_Is_Asserted Cond_Is_Asserted (cc_out, ID_Bit31_28, asserted);

        //Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
        Condition_Handler Condition_Handler(asserted, ID_B_instr, choose_ta_r_nop);

        //module EX_MEM_pipeline_register(input [31:0] MUX3, Alu_output, input [3:0] EX_Bit15_12, input [3:0] cc_alu_out, input [1:0] C_U_SIGNAL, input clk
                                        //output [31:0] MEM_Alu_Out, MEM_MUX3, output [3:0] MEM_Bit15_12, output [1:0] MEM_load_rf);
        EX_MEM_pipeline_register EX_MEM_pipeline_register(EX_register_file_port_MUX3_out, A_O, EX_Bit15_12_out, cc_main_alu_out, EX_MUX_2x1_ID_Out[1:0], clk,
                                MEM_A_O, MEM_register_file_port_MUX3_out, MEM_Bit15_12_out, MEM_load_rf_out);

        //module data_ram256x8(output reg[31:0] DataOut, input Enable, ReadWrite, input[31:0] Address, input[31:0] DataIn, input [1:0] Size);
        data_ram256x8 data_ram(Data_RAM_Out, Enable, ReadWrite, MEM_A_O, MEM_register_file_port_MUX3_out, Size);

        //multiplexer in MEM Stage
        mux_2x1_Stages  mux_2x1_stages_3(Data_RAM_Out, MEM_A_O, MEM_load_rf_out[1], M_O);

        //module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input [1:0] MEM_load_rf, input clk
                                        //output [31:0] wb_alu_out, wb_data_r_out,output [3:0] wb_bit15_12, output [1:0] wb_load_rf);
        MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12_out, MEM_load_rf_out, clk,
                                        WB_A_O, WB_Data_RAM_Out, WB_Bit15_12_out, WB_load_rf_out);

        //multiplexer in WB Stage
        reg MEM_l_rf =  MEM_load_rf_out[1];
        mux_2x1_Stages mux_2x1_stages_4(WB_Data_RAM_Out, WB_A_O, MEM_l_rf, PW);


        //Hazard-Forward Unit
endmodule


//CONTROL UNIT
module control_unit(output ID_B_instr, ALUSrc, RegDst, MemReadWrite, PCSrc, RegWrite, MemToReg, Branch, Jump, output [6:0] C_U_out, 
                    input clk, input [31:0] A); 

    reg [2:0] instr;
    
    integer s_imm = 0; 
    integer rf_instr = 0; 
    integer l_instr = 0; 
    integer b_instr = 0; 
    reg [3:0] alu_op = 4'b0000;
    integer b_bl = 0; // branch or branch & link
    integer r_sr_off = 0; // register or Scaled register offset
    integer u = 0;
    integer l = 0;
    integer condAsserted = 0; // 0 Cond no se da, 1 cond se da

    assign ID_shift_imm = s_imm;
    assign ID_RF_instr = rf_instr;
    assign ID_load_instr = l_instr; 
    assign ID_B_instr = b_instr;
    assign ID_ALU_op = alu_op;

    always@(*)


    // if(Cond_Is_Asserted == 1) ejecuta instr, else tira un NOP
    //
    //if(Cond_Is_Asserted (Status_register(cc_in, S, cc_out, clk), A[31:28], output asserted)) == 0)
    //NOP
    //else (el codigo de abajo)

    begin
        instr = A[27:25];

        if(instr == 3'b101)
            b_instr = 1;
        else 
            b_instr = 0;
        


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
                    

                    if(l == 0)
                        rf_instr = 0;
                    else
                        rf_instr = 1; 
                    

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
                  
                    case(b_bl)
                        1'b0://branch
                            begin
                                s_imm = 0; 
                                rf_instr = 0; 
                                l_instr = 0; 
                                // b_instr = 1;
                            end
                        1'b1://branch & link
                            begin
                                s_imm = 0; 
                                rf_instr = 1; 
                                l_instr = 0; 
                                // b_instr = 1;
                                alu_op = 4'b0100; //suma
                            end
                    endcase
                   
                end


        endcase
    end
endmodule


//Status Register
module Status_register(input [3:0] cc_in, input S, output reg [3:0] cc_out, input clk);
    //Recordar que el registro se declara aquí y luego
    always @ (posedge clk)
       begin
           if (S)
               cc_out <= cc_in;
       end

    always @ (clk)
    begin
        if(clk == 0)
            cc_out = 4'b0;
        else
            if(S == 1)
                cc_out = cc_in;
            else
                cc_out = 4'b0; //si no lo modifica va un register con el valor anterior
    end

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
module IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, ID_Next_PC, output reg S,
                               output reg[3:0] ID_Bit19_16, ID_Bit3_0, ID_Bit31_28, output reg[11:0] ID_Bit11_0,
                               output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
                               input nop, Hazard_Unit_Ld, clk, Lde, input [23:0] PC4, ram_instr, input [31:0] DataOut);

    always@(posedge clk)
    begin
        
    end
endmodule


//ID/EX PIPELINE REGISTER
module ID_EX_pipeline_register(output reg [31:0] register_file_port_MUX1_out, register_file_port_MUX2_out, register_file_port_MUX3_out,
                               output reg [3:0] EX_Bit15_12_out, EX_ALU_opcodes_out,
                               output reg [11:0] EX_Bit11_0_out,
                               output reg [7:0] EX_addresing_modes_out,
                               output reg EX_branch_instr_out, EX_load_instr_out, EX_RF_enable_out, EX_shifter_imm_out,
                               EX_mem_size_out, EX_mem_read_write_out,

                               input [31:0] register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in,
                               input [3:0] ID_Bit15_12_in, ID_ALU_opcodes_in, 
                               input [11:0] ID_Bit11_0_in,
                               input [7:0] ID_addresing_modes_in,
                               input ID_branch_instr_in, ID_load_instr_in, ID_RF_enable_in, ID_shifter_imm_in,
                               ID_mem_size_in, ID_mem_read_write_in, input clk);

    always@(posedge clk)
    begin
        //Control Unit signals        
        EX_shifter_imm_out <= ID_shifter_imm_in;
        EX_ALU_opcodes_out <= ID_ALU_opcodes_in;
        EX_load_instr_out <= ID_load_instr_in;
        EX_RF_enable_out <= ID_RF_enable_in;
        EX_branch_instr_out <= ID_branch_instr_in;
        EX_mem_size_out <= ID_mem_size_in;
        EX_mem_read_write_out <= ID_mem_read_write_in;

        //Register File operands
        register_file_port_MUX1_out <= register_file_port_MUX1_in;
        register_file_port_MUX2_out <= register_file_port_MUX2_in;
        register_file_port_MUX3_out <= register_file_port_MUX3_in;

        //Instruction bits
        EX_Bit15_12_out <= ID_Bit15_12_in;
        EX_Bit11_0_out <= ID_Bit11_0_in;
        EX_addresing_modes_out <= ID_addresing_modes_in; //22-20
    end
endmodule


//EX/MEM PIPELINE REGISTER
module EX_MEM_pipeline_register(input [31:0] EX_register_file_port_MUX3_out, A_O, input [3:0] EX_Bit15_12_out, cc_main_alu_out, input [1:0] EX_MUX_2x1_ID_Out[1:0], input clk,
                                output [31:0] MEM_A_O, MEM_register_file_port_MUX3_out, output [3:0] MEM_Bit15_12_out, output [1:0] MEM_load_rf_out);

    always@(posedge clk)
    begin
        MEM_A_O <= A_O;
        MEM_register_file_port_MUX3_out<=EX_register_file_port_MUX3_out;
        MEM_Bit15_12_out <= EX_Bit15_12_out;
        MEM_load_rf_out<=EX_MUX_2x1_ID_Out;

    end
endmodule


//MEM/WB PIPELINE REGISTER
module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input [1:0] MEM_load_rf, input clk,
                                    output reg [31:0] wb_alu_out, wb_data_r_out, output reg [3:0] wb_bit15_12, output reg [1:0] wb_load_rf);

    always@(posedge clk)
        begin
            wb_alu_out<=alu_out;
            wb_data_r_out<=data_r_out;
            wb_bit15_12<=bit15_12;
            wb_load_rf<=MEM_load_rf;
            
        end
endmodule


//INSTRUCTION MEMORY 
module inst_ram256x8(output reg[31:0] DataOut, input [31:0]Address);
                  
   reg[7:0] Mem[0:255]; //256 localizaciones 
   
    always @ (DataOut,Address)                
        if(Address%4==0) //Instructions have to start at even locations that are multiples of 4.
        begin    
            DataOut = {Mem[Address+0], Mem[Address+1], Mem[Address+2], Mem[Address+3]};                
        end
        else
            DataOut= Mem[Address];   
endmodule                               
              

//DATA MEMORY
module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input [1:0] Size);

    reg[7:0] Mem[0:255]; //256 localizaciones 

    always @ (DataOut, ReadWrite, Address, DataIn, Size)       

        casez(Size) //"casez" to ignore dont care values
        2'b00: //BYTE
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

            2'b01: //HALF-WORD
        begin
            if (ReadWrite) //When Write 
            begin
                Mem[Address] = DataIn[15:8]; 
                Mem[Address + 1] = DataIn[7:0]; 
            end
            else //When Read
            begin
                    DataOut = {Mem[Address+0], Mem[Address+1]}; 
            end  
        end

        2'b10: //WORD
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
module mux_4x2_ID(input [31:0] A_O, PW, M_O, P, input [1:0] HF_U, output MUX_Out);
    reg [31:0] salida;

    assign MUX_out = salida;

    always@(*)
    begin
        
        case(HF_U)
            2'b00: // A
            salida = P;

            2'b01://B
            salida = A_O;

            2'b10://C
            salida = M_O;

            2'b11://D
            salida = PW;
        endcase
    end

endmodule

//Multiplexer control Unit
module mux_2x1_ID(input [6:0] C_U, NOP_S, input HF_U, output [6:0] MUX_Out);
    reg [6:0] salida;

    assign NOP_S = 6'b0;
    assign MUX_out = salida;

    always@(*)
    begin
       // NOP_S = 6'b0;

        case(HF_U)
            1'b0: // NOP
            salida = NOP_S;

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

    assign MUX_out = salida;

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

module SExtender(input reg [23:0] in, output signed [31:0] out1);

    reg signed [31:0] twoscomp;
    reg signed [31:0] result;
    reg signed [31:0] shift_result; 
    reg signed [31:0] temp_reg;


    assign out1 = result; 

    always@(*)
    begin

        in = {8'b0,in};
        twoscomp = ~(in) + 1'b1;

        for(integer i=0; i<2; i= i+1)begin
                            // tc = temp_reg[31];
            temp_reg = {twoscomp[30:0], 1'b0};
        end
                        // C = tc;
        shift_result = temp_reg;

        result = shift_result * 4;

    end
endmodule
/*
//HAZARD UNIT
module hazard_unit(output reg [32:0] MUX1_signal, MUX2_signal, MUX3_signal, 
                   output reg MUXControlUnit_signal, IF_load, Regiser_File_load,
                   input EX_load_instr_in, EX_RF_Enable_in, MEM_RF_Enable_in, WB_RF_Enable_in
                   input [32:0] EX_Bit15_12_in, MEM_Bit15_12_in, WB_Bit15_12_in, IF_Bit3_0_in, 
                   IF_19_16_in);
    always@(*)
    begin

    end

endmodule 
*/