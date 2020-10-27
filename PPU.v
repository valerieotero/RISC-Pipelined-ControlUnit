//CONTROL UNIT
module control_unit(input [31:0] A, output ID_B_instr, ID_load_instr, ID_RF_instr, ID_shift_imm, output [3:0] ID_ALU_op);

    reg [2:0] instr;
    
    integer s_imm = 0; 
    integer rf_instr = 0; 
    integer l_instr = 0; 
    integer b_instr = 0; 
    reg [3:0] alu_op = 4'b0000;
    integer b_bl = 0; // branch or branch & link
    integer r_sr_off = 0; // register or Scaled register offset
    integer u = 0;

    assign ID_shift_imm = s_imm;
    assign ID_RF_instr = rf_instr;
    assign ID_load_instr = l_instr; 
    assign ID_B_instr = b_instr;
    assign ID_ALU_op = alu_op;

    always@(*)

    begin
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
                    s_imm = 0; 
                    rf_instr = 1; 
                    l_instr = A[20]; 
                    b_instr = 0;

                    if(u == 1)
                        alu_op = 4'b0100; //suma
                    else
                        alu_op = 4'b0010; //resta
                            
                end

            3'b011: //Load/Store Register Offset
                begin
                    u = A[23];
    
                    if(A[11:4] == 8'b00000000)
                        r_sr_off = 0;
                    else
                        r_sr_off = 1;
                    

                    
                    if(r_sr_off == 0)begin
                        s_imm = 0; 
                        rf_instr = 1; 
                        l_instr = A[20]; 
                        b_instr = 0;

                        if(u == 1)
                            alu_op = 4'b0100; //suma
                        else
                            alu_op = 4'b0010; //resta

                    end else begin
                        s_imm = 0; 
                        rf_instr = 1; 
                        l_instr = A[20]; 
                        b_instr = 0;

                        if(u == 1)
                            alu_op = 4'b0100; //suma
                        else
                            alu_op = 4'b0010; //resta
                            
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
                                b_instr = 1;
                            end
                        1'b1://branch & link
                            begin
                                s_imm = 0; 
                                rf_instr = 1; 
                                l_instr = 0; 
                                b_instr = 1;
                            end
                    endcase
                   
                end


        endcase
    end
endmodule


//IF/ID PIPELINE REGISTER
module IF_ID_pipeline_register();
endmodule


//ID/EX PIPELINE REGISTER
module ID_EX_pipeline_register();
endmodule


//EX/MEM PIPELINE REGISTER
module EX_MEM_pipeline_register();
endmodule


//MEM/WB PIPELINE REGISTER
module MEM_WB_pipeline_register();
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