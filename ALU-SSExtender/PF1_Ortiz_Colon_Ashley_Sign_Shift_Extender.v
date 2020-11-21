module Sign_Shift_Extender (input [31:0]A, B, output reg [31:0]shift_result, output reg C);
    reg [31:0] temp_reg, temp_reg1, temp_reg2, rm, rm1;
    integer num_of_rot;
    integer i;
    reg [1:0] by_imm_shift;
    reg [2:0] shifter_op;
    reg [1:0] shift;

    
   
    reg tc;
    reg relleno;
    reg Cin;
    reg U;

   
  

    always@(*)

    begin
        shifter_op = B[27:25];
        by_imm_shift = B[6:5];
        temp_reg = A;
        case(shifter_op)

            3'b000:
            begin //Shift_by_Imm
                // temp_reg = A;
                num_of_rot = B[11:7];
                // tc = C;
                
                case(by_imm_shift)
                    2'b00:
                    begin //LSL
                        if(num_of_rot == 5'b0)begin
                            shift_result = temp_reg;
                            // C = Cflag
                        end else begin
                            // temp_reg = {20'b0, A[11:0]};
                            for(i=0; i<num_of_rot; i= i+1)begin
                                // tc = temp_reg[31];
                                temp_reg = {temp_reg[30:0], 1'b0};
                            end
                            
                            shift_result = temp_reg;
                            C = A[32 - num_of_rot];
                        end
                    end 

                    2'b01:
                    begin //LSR
                        if(num_of_rot == 5'b0)begin
                            shift_result = 32'b0;
                            C = A[31];
                        end else begin
                            for(i=0; i<num_of_rot; i= i+1)begin
                                // tc = temp_reg[0];
                                temp_reg = {1'b0, temp_reg[31:1]};
                            end
                            
                            shift_result = temp_reg;
                            C = A[num_of_rot - 1];
                        end
                    end 
                    
                    2'b10:
                    begin //ASR
                        if(num_of_rot == 5'b0)begin   
                            if(temp_reg[31] == 1'b0) begin
                                shift_result = 32'b0;
                                C = A[31];
                            end else begin
                                shift_result = 32'b11111111111111111111111111111111;
                                C = A[31];
                            end   
                        end else begin 
                            relleno = A[31];
                            for(i=0; i<num_of_rot; i= i+1)begin
                                // tc = temp_reg[0];
                                temp_reg = {relleno, temp_reg[31:1]};
                            end
                            shift_result = temp_reg;
                            C = A[num_of_rot - 1];
                        end
                    end 

                    2'b11:
                    begin //ROR
                        if(num_of_rot == 5'b0)begin
                            
                            shift_result = {1'b0, temp_reg[31:1]};
                            C = A[0];
                        end else begin
                            
                            for(i=0; i<num_of_rot; i= i+1)begin
                                // tc = temp_reg[0];
                                temp_reg = {temp_reg[0], temp_reg[31:1]};
                            end
                            shift_result = temp_reg;
                            C = A[num_of_rot - 1];
                        end
                    end
                endcase
            end 
            
            3'b001:
            begin //Imm_shift_op_32_Imm
                temp_reg = {24'b0, B[7:0]};
                num_of_rot = 2*(B[11:8]);

                for(i = 0; i<num_of_rot; i=i+1)begin
                    temp_reg = {temp_reg[0], temp_reg[31:1]};
                end
                    shift_result = temp_reg;

                if(B[11:8] != 4'b0)
                    C = A[31];

            end 

            3'b010:
            begin //Immediate Offset
                // if(U == 1)
                shift_result = {20'b0, B[11:0]}; //effective address
                // $display("shift result imm offset", shift_result);
                // else 
                //     shift_result = {20'b0, B[19:16]} - {20'b0, B[11:0]}; //effective address

            end 
            
            3'b011:
            begin 
                if(B[11:4] == 8'b0) begin //Register Offset 
                //  if(U == 1)
                    shift_result = {28'b0, B[3:0]}; //effective address
                // else 
                //     shift_result = {20'b0, B[19:16]} - A; //effective address
                end else begin //Scaled Register Offset
                    shift = B[6:5];
                    case(shift)
                        2'b00:
                        begin //LSL
                            for(i=0; i<num_of_rot; i= i+1)begin
                                temp_reg = {temp_reg[30:0], 1'b0};
                            end
                            shift_result = temp_reg;
                        end 

                        2'b01:
                        begin //LSR
                            if(num_of_rot == 0)
                                temp_reg = 32'b0;
                            else begin
                                for(i=0; i<num_of_rot; i= i+1)begin
                                    // tc = temp_reg[0];
                                    temp_reg = {1'b0, temp_reg[31:1]};
                                end
                            end
                            // C = tc;
                            shift_result = temp_reg;
                        end 
                        
                        2'b10:
                        begin //ASR
                            if(num_of_rot == 0)begin
                                if(A[31] == 1)
                                    temp_reg = 32'b11111111111111111111111111111111;
                                else 
                                    temp_reg = 32'b0;
                            end else begin   
                                relleno = A[31];
                                for(i=0; i<num_of_rot; i= i+1)begin
                                    // tc = temp_reg[0];
                                    temp_reg = {relleno, temp_reg[31:1]};
                                end
                            end 
                            // C = tc;
                            shift_result = temp_reg;
                        end 

                        2'b11:
                        begin //ROR
                            if(num_of_rot == 0)begin                                
                                // for(i=0; i<31; i= i+1)begin
                                //     tc = temp_reg[31];
                                    // temp_reg1 = {temp_reg[30:0], 1'b0};
                                // end
                                // tc = temp_reg1[31];
                                // rm = {28'b0, A[3:0]};
                                // for(i=0; i<1; i= i+1)begin
                                   // tc = rm[0];
                                temp_reg = {1'b0, A[31:1]};
                                // end
                                // rm1 = temp_reg2;

                                // temp_reg = tc || rm1;
                            end else begin
                                for(i=0; i<num_of_rot; i= i+1)begin
                                    // tc = temp_reg[0];
                                    temp_reg = {temp_reg[0], temp_reg[31:1]};
                                end
                            end
                            // C = tc;
                            shift_result = temp_reg;
                        end
                    endcase
                    
                end
            end 

            // 3'b101:
            // begin
            //     if(B[24] == 1)

            // end      
        endcase


    end




endmodule
