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
    
    always@(clk)

    
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