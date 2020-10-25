module Sign_Shift_Extender (input [2:0] shifter_op,input [1:0] by_imm_shift, input [31:0]A, input [11:0]B, output reg [31:0]shift_result, output reg C);
    reg [31:0] temp_reg;
    integer num_of_rot;
    integer i;
   
    reg tc;
    reg relleno;
    reg Cin;
    reg U;
  

    always@(*)

    begin
        // shifter_op = B[27:25];
        // by_imm_shift = B[6:5];
        // U = B[23];
        case(shifter_op)

            3'b000:
            begin //Shift_by_Imm
                temp_reg = A;
                num_of_rot = B[11:7];
                tc = C;
                
                case(by_imm_shift)
                    2'b00:
                    begin //LSL
                        for(i=0; i<num_of_rot; i= i+1)begin
                            tc = temp_reg[31];
                            temp_reg = {temp_reg[30:0], 1'b0};
                        end
                        C = tc;
                        shift_result = temp_reg;
                    end 

                    2'b01:
                    begin //LSR
                
                        for(i=0; i<num_of_rot; i= i+1)begin
                            tc = temp_reg[0];
                            temp_reg = {1'b0, temp_reg[31:1]};
                        end
                        C = tc;
                        shift_result = temp_reg;
                    end 
                    
                    2'b10:
                    begin //ASR
                    
                        relleno = A[31];
                        for(i=0; i<num_of_rot; i= i+1)begin
                            tc = temp_reg[0];
                            temp_reg = {relleno, temp_reg[31:1]};
                        end
                        C = tc;
                        shift_result = temp_reg;
                    end 

                    2'b11:
                    begin //ROR
                        
                     for(i=0; i<num_of_rot; i= i+1)begin
                        tc = temp_reg[0];
                        temp_reg = {temp_reg[0], temp_reg[31:1]};
                     end
                     C = tc;
                     shift_result = temp_reg;
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
            end 

            3'b010:
            begin //Immediate Offset
                // if(U == 1)
                shift_result = {20'b0, B[11:0]}; //effective address
                // else 
                //     shift_result = {20'b0, B[19:16]} - {20'b0, B[11:0]}; //effective address

            end 
            
            3'b011:
            begin //Register Offset 
                //  if(U == 1)
                shift_result = {28'b0, B[3:0]}; //effective address
                // else 
                //     shift_result = {20'b0, B[19:16]} - A; //effective address
            end       
        endcase


    end




endmodule
