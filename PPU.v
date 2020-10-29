//CONTROL UNIT
module control_unit(output ID_B_instr, ID_load_instr, ID_RF_instr, ID_shift_imm, ALUSrc, RegDst,  
                    MemReadWrite, PCSrc, RegWrite, MemToReg, Branch, Jump, output [3:0] ID_ALU_op, 
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
    sr_subregister intermediate_reg (.cc_out(cc_out), .cc_in(cc_in), .S(S), .CLK(CLK));

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
module sr_subregister(output reg [3:0] cc_out, input [3:0] cc_in, input S, input CLK);

    always @ (posedge CLK)
    begin
        if (S)
            cc_out <= cc_in;
    end

endmodule


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
module IF_ID_pipeline_register(output reg[23:0] Bit23_0, Next_PC, output reg S,
                               output reg[3:0] Bit19_16, Bit3_0, Bit31_28, output reg[11:0] Bit11_0,
                               output reg[3:0] Bit15_12, output reg[31:0] Bit31_0,
                               input nop, Hazard_Unit_Ld, clk, input [23:0] PC4, ram_instr);

    always@(posedge clk)
        begin
        
        end
endmodule


//ID/EX PIPELINE REGISTER
module ID_EX_pipeline_register(output reg [31:0] register_file_port_MUX1_out, register_file_port_MUX2_out, register_file_port_MUX3_out,
                               output reg [3:0] Bit15_12_out, ALU_opcodes_out,
                               output reg [11:0] Bit11_0_out,
                               output reg [7:0] addresing_modes_out,
                               output reg branch_instr_out, load_instr_out, RF_enable_out, shifter_imm_out,
                               mem_size_out, mem_read_write_out,

                               input [31:0] register_file_port_MUX1_in, register_file_port_MUX2_in, register_file_port_MUX3_in,
                               input [3:0] Bit15_12_in, ALU_opcodes_in, 
                               input [11:0] Bit11_0_in,
                               input [7:0] addresing_modes_in,
                               input branch_instr_in, load_instr_in, RF_enable_in, shifter_imm_in,
                               mem_size_in, mem_read_write_in, input clk);

always@(posedge clk)
    begin
        //Control Unit signals        
        shifter_imm_out = shifter_imm_in; 
        ALU_opcodes_out = ALU_opcodes_in;
        load_instr_out = load_instr_in;
        RF_enable_out = RF_enable_in;
        branch_instr_out = branch_instr_in;       
        mem_size_out = mem_size_in;
        mem_read_write_out = mem_read_write_in;

        //Register File operands
        register_file_port_MUX1_out = register_file_port_MUX1_in;
        register_file_port_MUX2_out = register_file_port_MUX2_in;      
        register_file_port_MUX3_out = register_file_port_MUX3_in;

        //Instruction bits
        Bit15_12_out = Bit15_12_in;
        Bit11_0_out = Bit11_0_in;
        addresing_modes_out = addresing_modes_in; //22-20
    end
endmodule


//EX/MEM PIPELINE REGISTER
module EX_MEM_pipeline_register(input clk);

    always@(posedge clk)
        begin
            
        end
endmodule


//MEM/WB PIPELINE REGISTER
module MEM_WB_pipeline_register(input clk);

    always@(posedge clk)
        begin
            
        end
endmodule


//INSTRUCTION MEMORY 
module inst_ram256x8(output reg[31:0] DataOut, input Enable, input [31:0]Address);
                  
   reg[7:0] Mem[0:255]; //256 localizaciones 
   
    always @ (Enable)
        if (Enable) //When Enable = 1            
            if(Address%4==0) //Instructions have to start at even locations that are multiples of 4.
            begin    
                DataOut = {Mem[Address+0], Mem[Address+1], Mem[Address+2], Mem[Address+3]};                
            end
            else
                DataOut= Mem[Address];   
endmodule                              
              

//DATA MEMORY
module data_ram256x8(output reg[31:0] DataOut, input Enable, ReadWrite, input[31:0] Address, input[31:0] DataIn, input [1:0] Size);

    reg[7:0] Mem[0:255]; //256 localizaciones 

    always @ (Enable, ReadWrite)
        if (Enable) //When Enable = 1        
        begin

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
            
        end
endmodule