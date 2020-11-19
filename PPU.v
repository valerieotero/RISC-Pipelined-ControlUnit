`include "register_file/PF1_Nazario_Morales_Victor_rf.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_Sign_Shift_Extender.v"
`include "ALU-SSExtender/PF1_Ortiz_Colon_Ashley_ALU.v"


//CONTROL UNIT
module control_unit(output ID_B_instr, MemReadWrite, MemSize, output [6:0] C_U_out, input clk, Reset, asserted, input [31:0] A); 

    reg [2:0] instr;
     //**C_U_out = ID_shift_imm[6], ID_ALU_op[5:2], ID_load_instr [1], ID_RF_enable[0]

    reg s_imm = 0; 
    reg rf_instr = 0; 
    reg l_instr = 0; 
    reg b_instr = 0; 
    reg m_rw = 0;
    reg m_size = 0;

    reg [3:0] alu_op;
    reg b_bl; // branch or branch & link
    reg r_sr_off; // register or Scaled register offset
    reg u;
    // integer condAsserted;// = Cond_Is_Asserted (input [3:0] cc_in, A[31:28], asserted);; // 0 Cond no se da, 1 cond se da

    assign C_U_out[6] = s_imm;
    assign C_U_out[0] = rf_instr;
    assign C_U_out[1] = l_instr; 
    assign ID_B_instr = b_instr;
    assign C_U_out[5:2] = alu_op;
    assign MemReadWrite = m_rw;
    assign MemSize = m_size;

    always@(*)
   

    begin
        // $display("instruction %b", A);
        if(Reset == 1 || A == 32'b0) begin // || asserted == 0) begin
            s_imm = 0; 
            rf_instr = 0; 
            l_instr = 0; 
            b_instr = 0; 
            m_rw = 0;
            m_size = 0;
            alu_op = 4'b0000;
        end else begin 
            instr = A[27:25];
       
            case(instr)

                3'b000: //Data Procesing Shift_by_imm
                begin
                    s_imm = 0; 
                    rf_instr = 1; 
                    l_instr = 0; 
                    b_instr = 0;
                    alu_op = A[24:21];

                    
                end

                3'b001: //Data Procesing Immediate
                begin
                    s_imm = 1; 
                    rf_instr = 1; 
                    l_instr = 0; 
                    b_instr = 0;
                    alu_op = A[24:21];
                end

                3'b010: //Load/Store Immediate Offset
                begin
                    u = A[23];
                    s_imm = 1; 
                    l_instr = A[20]; 
                    b_instr = 0;
                    m_size = A[22];

                    if(l_instr == 0) begin
                        rf_instr = 0;
                        m_rw = 1;
                        
                    end else begin
                        rf_instr = 1; 
                        m_rw = 0;
                        
                    end 

                    if(u == 1)
                        alu_op = 4'b0100; //suma
                    else
                        alu_op = 4'b0010; //resta              
                end

                3'b011: //Load/Store Register Offset
                begin
                    u = A[23];
                    l_instr = A[20];
                    m_size = A[22];
                    s_imm = 0; 
                    b_instr = 0;

                    if(u == 1)
                        alu_op = 4'b0100; //suma
                    else
                        alu_op = 4'b0010; //resta
                        

                    if(l_instr == 0) begin
                        rf_instr = 0;
                        m_rw = 1;
                    end else begin
                        rf_instr = 1; 
                        m_rw = 0;

                    end
                
                    if(A[11:4] == 8'b00000000)
                        r_sr_off = 0;
                    else
                        r_sr_off = 1;
                        

            
                    
                end

                3'b101: //branches
                begin
                    b_instr = 1;

                    // //if(asserted == 1)begin
                    //     s_imm = 0; 
                    //     rf_instr = 0; 
                    //     l_instr = 0; 
                    //     alu_op = 4'b0010;
                    //     m_rw = 0;
                    //     m_size = 0;

                    // end else begin 
                    b_bl = A[24];
                        
                       //branch
                        if(b_bl == 0) begin
                            s_imm = 0; 
                            rf_instr = 0; 
                            l_instr = 0; 
                            alu_op = 4'b0010;
                            m_rw = 0;
                            m_size = 0;

                        end else begin
                        //branch & link begin
                            s_imm = 0; 
                            rf_instr = 1; 
                            l_instr = 0; 
                            alu_op = 4'b0100; //suma
                            m_rw = 0;
                            m_size = 0;

                        end
                    // end
                end
                

            endcase
            // $display("alu %b",alu_op);
            // $display("instr %b", instr);
        end//  $display("ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b", C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0]);     
    //    
    end
endmodule


//Status Register
module Status_register(input [3:0] cc_in, input S, output reg [3:0] cc_out, input clk); //verify
    //Recordar que el registro se declara aquí y luego
    always @ (posedge clk)
    begin
        if (S)
            cc_out <= 5'b00000;
        else 
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
module Cond_Is_Asserted (input [3:0] cc_in, input [3:0] instr_condition,input clk, output asserted);
    //N - 3, Z - 2, C - 1, V - 0
    integer n = 0;
    integer z = 0;
    integer c = 0;
    integer v = 0;
    reg assrt = 0;

    assign asserted = assrt;

    always@(posedge clk)
    begin
        n <= cc_in[3];
        z <= cc_in[2];
        c <= cc_in[1];
        v <= cc_in[0];
        case(instr_condition)
            4'b0000: //(EQ) Equal
            begin
                if(z == 1)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //1
            4'b0001: //(NE) Not Equal
            begin
                if(z == 0)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //2
            4'b0010: //(CS/HS) Carry set/unsigned higher or same
           begin
                if(c == 1)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //3
            4'b0011: //(CC/LO) carry clear/ unsigned lower
           begin
                if(c == 0)
                    assrt <= 1;
                else
                    assrt <= 0;
            end
                     
            //4
            4'b0100: //(MI) Minus/negative
            begin
                if(n == 1)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //5
            4'b0101: //(PL) plus/positive or zero 
            begin
                if(n == 0)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //6
            4'b0110: //(VS) Overflow
            begin
                if(v == 1)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //7
            4'b0111: //(VC) No Overflow
            begin
                if(v == 0)
                    assrt <= 1;
                else
                    assrt <= 0;
            end
            
            //8
            4'b1000: //(HI) Unsigned Higher 
            begin
                if(c == 1 && z ==0)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //9
            4'b1001: //(LS) Unsigned Lower or same
            begin
                if(c == 0 || z == 1)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //10
            4'b1010: //(GE) Signed greater than or equal 
            begin
                if(v == n)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //11
            4'b1011: //(LT) Signed less than
            begin
                if(v != n)
                    assrt <= 1;
                else
                    assrt <= 0;
            end

            //12
            4'b1100: //(GT) Signed greater than
            begin
                if(z == 0 || n == v)
                    assrt <= 1;
                else
                    assrt <= 0;
            end 

            //13
            4'b1101: // (LE) Signed Less than or equal
             begin
                if(z == 1 || n != v)
                    assrt <= 1;
                else
                    assrt <= 0;
            end 

            //14
            4'b1110: //Always
            assrt <= 1;

            //15
            4'b1111: 
            assrt <= 0;

        endcase
        // $display("condition arsserted %b", assrt);
    end

endmodule

//conition handler (output condition asserted, branch)
module Condition_Handler(input asserted, b_instr, output reg choose_ta_r_nop);
    always@(*)
    begin
        if(asserted == 1 && b_instr == 1)
            choose_ta_r_nop = 0;//this is 1 for pHase 3 purposes it is 0
        else
            choose_ta_r_nop = 0; 
    end

endmodule


//IF/ID PIPELINE REGISTER
module IF_ID_pipeline_register(output reg[23:0] ID_Bit23_0, output reg [31:0] ID_Next_PC,
                               output reg [3:0] ID_Bit19_16, ID_Bit3_0, output reg [3:0] ID_Bit31_28, output reg[31:0] ID_Bit11_0,
                               output reg[3:0] ID_Bit15_12, output reg[31:0] ID_Bit31_0,
                               input choose_ta_r_nop, Hazard_Unit_Ld, clk, Reset,asserted, input [31:0] PC4, DataOut);

    always@(clk)
    begin

        if(Reset==1) begin
            ID_Bit31_0 <= 32'b0;
            ID_Next_PC <= 32'b0;
            ID_Bit3_0 <= 4'b0;
            ID_Bit31_28 <= 4'b0;
            ID_Bit19_16 <= 4'b0;
            ID_Bit15_12 <= 4'b0;
            ID_Bit23_0 <= 24'b0;
            // ID_Bit11_0 <= 12'b0;

        end else begin

           if(Hazard_Unit_Ld == 0 || asserted == 1|| choose_ta_r_nop == 0) begin
                ID_Bit31_0 <= DataOut;
                ID_Next_PC <= PC4;
                ID_Bit3_0 <=  DataOut[3:0]; //{28'b0, DataOut[3:0]};
                ID_Bit31_28 <= DataOut[31:28];
                ID_Bit19_16 <=  DataOut[19:16]; //{28'b0, DataOut[19:16]};
                ID_Bit15_12 <= DataOut[15:12];
                ID_Bit23_0 <= DataOut[23:0];
                // ID_Bit11_0 <= DataOut[11:0];
                
            end else begin
                ID_Bit31_0 = 32'b0;
                ID_Next_PC <= 32'b0;
                ID_Bit3_0 <= 4'b0; //32'b0;
                ID_Bit31_28 <= 4'b0;
                ID_Bit19_16 <= 4'b0; //32'b0;
                ID_Bit15_12 <= 4'b0;
                ID_Bit23_0 <= 24'b0;
                // ID_Bit11_0 <= 12'b0;
            end
        end
       
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
                               input [31:0] ID_Bit31_0,
                               input [7:0] ID_addresing_modes,
                               input ID_mem_size, ID_mem_read_write, input clk);

    always@(clk)
    begin
        //Control Unit signals  
        EX_Shift_imm <= ID_CU[6];
        EX_ALU_OP <= ID_CU[5:2];
        EX_load_instr <= ID_CU[1]; 
        EX_RF_instr <= ID_CU[0];
        EX_mem_size <= ID_mem_size;
        EX_mem_read_write <= ID_mem_read_write;

        //Register File operands
        mux_out_1_A <= mux_out_1;
        mux_out_2_B <= mux_out_2;
        mux_out_3_C <= mux_out_3;
     
        //Instruction bits
        EX_Bit15_12 <= ID_Bit15_12;
        EX_Bit11_0 <= ID_Bit31_0; // {20'b0, ID_Bit11_0};
        EX_addresing_modes <= ID_addresing_modes; //22-20
   
    //  $display("ID_EX reg");
    //  $display("ID_shift_imm = %b | ID_alu= %b | ID_load = %b | ID_RF= %b", ID_CU[6], ID_CU[5:2], ID_CU[1], ID_CU[0]);     
    //  $display("EX_shift_imm = %b | EX_alu= %b | EX_load = %b | EX_RF= %b", EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_instr);     

    end
   
endmodule


//EX/MEM PIPELINE REGISTER
module EX_MEM_pipeline_register(input [31:0] mux_out_3_C, A_O, input [3:0] EX_Bit15_12, cc_main_alu_out, input EX_load_instr, EX_RF_instr, EX_mem_read_write, EX_mem_size, input clk,
                                output reg [31:0] MEM_A_O, MEM_MUX3, output reg [3:0] MEM_Bit15_12, output reg MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);


    always@(clk)
    begin
        MEM_A_O <= A_O;
        MEM_MUX3 <= mux_out_3_C;
        MEM_Bit15_12 <= EX_Bit15_12;
        MEM_load_instr <= EX_load_instr;
        MEM_RF_Enable <= EX_RF_instr;
        MEM_mem_read_write <= EX_mem_read_write;
        MEM_mem_size <=  EX_mem_size;
    
    //  $display("EX_MEM reg");
    //  $display("EX_load = %b | EX_RF= %b", EX_load_instr, EX_RF_instr);     
    //  $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);     

    end
   
endmodule


//MEM/WB PIPELINE REGISTER
module MEM_WB_pipeline_register(input [31:0] alu_out, data_r_out, input [3:0] bit15_12, input MEM_load_instr, MEM_RF_Enable, clk,
                                    output reg [31:0] wb_alu_out, wb_data_r_out, output reg [3:0] wb_bit15_12, output reg WB_load_instr, WB_RF_Enable);

    always@(clk)
    begin
        wb_alu_out <= alu_out;
        wb_data_r_out <= data_r_out;
        wb_bit15_12 <= bit15_12;
        WB_load_instr <= MEM_load_instr;
        WB_RF_Enable <= MEM_RF_Enable;
    // $display("MEM_WB reg");
     
    // $display("MEM_load = %b | MEM_RF= %b", MEM_load_instr, MEM_RF_Enable);  
    // $display("WB_load = %b | WB_RF= %b", WB_load_instr, WB_RF_Enable);           
    end
    
endmodule


//INSTRUCTION MEMORY 
module inst_ram256x8(output reg[31:0] DataOut, input [31:0]Address, input Reset);
                  
   reg[7:0] Mem[0:255]; //256 localizaciones 
   
    always @ (DataOut,Address,Reset)  
    begin

        if (Reset) 
        begin        
            DataOut = 32'b00000000000000000000000000000000; 
            // $display("Inside Reset\n");   
        end
             
        else//Not Reset
        begin
        // $display("From inside Instr Mem, Address= %d\n", Address);

            if(Address%4==0) //Instructions have to start at even locations that are multiples of 4.                        
                 DataOut = {Mem[Address+0], Mem[Address+1], Mem[Address+2], Mem[Address+3]};                
                
            else                    
                DataOut= Mem[Address]; 
                     
        end 
        
        // $display("From inside Instr Mem, DataOut= %b\n", DataOut);    
         
    end 
endmodule                                
              

//DATA MEMORY
module data_ram256x8(output reg[31:0] DataOut, input ReadWrite, input[31:0] Address, input[31:0] DataIn, input Size, Reset);

    reg[7:0] Mem[0:255]; //256 localizaciones 

    always @ (DataOut, ReadWrite, Address, DataIn, Size,Reset)       

        if (Reset) 
            begin        
                DataOut = 32'b00000000000000000000000000000000;                   
            end

        else
          begin              
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
     end      
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
module mux_2x1_ID(input [6:0] C_U, input HF_U, output [6:0] MUX_Out);
    reg [6:0] salida;

    assign MUX_Out = salida;

    always@(*)
    begin
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
            temp_reg = {twoscomp[29:0], 2'b0};
        end
        shift_result = temp_reg;

        result = shift_result * 4;
        // result = in1 <<< 2;


    end
endmodule

//HAZARD UNIT
module hazard_unit(output reg [1:0] MUX1_signal, MUX2_signal, MUX3_signal, output reg MUXControlUnit_signal, 
                   output reg IF_ID_load, PC_RF_load,
                   input EX_load_instr, EX_RF_Enable, MEM_RF_Enable, WB_RF_Enable, clk,
                   input [3:0] EX_Bit15_12, MEM_Bit15_12, WB_Bit15_12, ID_Bit3_0, 
                   ID_Bit19_16);
    always@(*)
    begin
        //DATA Hazard-By Load Instr
        if(EX_load_instr==1 && ((ID_Bit19_16 == EX_Bit15_12)||(ID_Bit3_0 == EX_Bit15_12)))begin
         
            IF_ID_load = 1'b0; //Disable pipeline Load
            PC_RF_load = 1'b0; //Disable PC load
            MUXControlUnit_signal = 1'b1; //NOP; its suppose to be 0
        end else begin
            IF_ID_load = 1'b1; //Disable pipeline Load
            PC_RF_load = 1'b1; //Disable PC load
            MUXControlUnit_signal = 1'b1; //NOP
        end

       
        //DATA Forwarding
        if(EX_RF_Enable && ((ID_Bit19_16 == EX_Bit15_12)||(ID_Bit3_0 == EX_Bit15_12))) begin
            //Valor del Main ALU
            MUX1_signal = 2'b01;
            MUX2_signal = 2'b01; 
            MUX3_signal = 2'b01;
        end else if(MEM_RF_Enable && ((ID_Bit19_16 == MEM_Bit15_12)||(ID_Bit3_0 == MEM_Bit15_12))) begin
           // valor multiplexer MEM Stage
            MUX1_signal = 2'b10;
            MUX2_signal = 2'b10;
            MUX3_signal = 2'b10;
        end else if(WB_RF_Enable && ((ID_Bit19_16 == WB_Bit15_12)||(ID_Bit3_0 == WB_Bit15_12))) begin
            //valor PW (multiplexer WB)
            MUX1_signal = 2'b11;
            MUX2_signal = 2'b11; 
            MUX3_signal = 2'b11;
        end else begin //valor del Register File 
            MUX1_signal = 2'b00;
            MUX2_signal = 2'b00; 
            MUX3_signal = 2'b00;
        end


        // $display("pc_ld ", PC_RF_load);
    end

endmodule