module control_unit(input [31:0] A, output ID_B_instr, ID_load_instr, ID_RF_instr, ID_shift_imm, output [3:0] ID_ALU_op)

    reg [2:0] instr;
    
    integer s_imm = 0; 
    integer rf_instr = 0; 
    integer l_instr = 0; 
    integer b_instr = 0; 
    integer alu_op = 0;

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
                    s_imm = A[20]; 
                    rf_instr = 1; 
                    l_instr = 0; 
                    b_instr = 0;
                    alu_op = A[24:21];
                end

            3'b001: //Data Procesing Immediate
                begin
                    s_imm = A[20]; 
                    rf_instr = 1; 
                    l_instr = 0; 
                    b_instr = 0;
                    alu_op = A[24:21];
                end

            3'b010: //Load/Store Immediate Offset
                begin
                    s_imm = 0; 
                    rf_instr = 1; 
                    l_instr = A[20]; 
                    b_instr = 0;
                end

            3'b011: //Load/Store Register Offset
                begin
                    s_imm = 0; 
                    rf_instr = 1; 
                    l_instr = A[20]; 
                    b_instr = 0;
                end

            3'b101: //branches
                begin
                    s_imm = 0; 
                    rf_instr = 0; 
                    l_instr = 0; 
                    b_instr = 1;
                end


        endcase
    end




endmodule
