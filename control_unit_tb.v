//=======================================================================ALU CODE ====================================================
/*Creator: Ashley Ortiz Colon
*/

module alu(input [31:0]A,B, input [3:0] OPS, input Cin, output [31:0]S, output N, Z, C, V);

    reg [32:0] OPS_result;

    integer tn = 0; 
    integer tz = 0; 
    integer tc = 0; 
    integer tv = 0; 
    integer ol = 0;

    assign N = tn; //Negative
    assign Z = tz; //Zero 
    assign C = tc; //Carry Out
    assign V = tv; //Overflow

    // integer mod_cond_codes;

    assign S = OPS_result[31:0];
    always@(OPS,A,B,Cin)
    

    begin

        // mod_cond_codes = B[20];

        case(OPS)
            //0
            4'b0000: //Logical AND
            OPS_result = A & B;

            //1
            4'b0001: //Logical Exclusive OR
            OPS_result = A ^ B;

            //2
            4'b0010: //Subtract
            begin
                OPS_result = A - B;  
                ol = 1;
            end
      

            //3
            4'b0011: //Reverse Subtract
            begin
                OPS_result = B - A;  
                ol = 2;
            end
                     
            //4
            4'b0100: //Add
            begin
                OPS_result = A + B;
                ol = 3;
            end
            //5
            4'b0101: //Add w. Carry
            OPS_result = A + B + Cin;

            //6
            4'b0110: //Subtract w. Carry
            begin
                OPS_result = A - B -(~{31'b0,Cin});
                ol = 1;
            end 
            //7
            4'b0111: //Reverse Subtract w. Carr
            begin 
                OPS_result = B - A -(~{31'b0,Cin}); 
                ol = 2;
            end
            
            //8
            4'b1000: //Test 
            OPS_result = A & B;
            //flag update 

            //9
            4'b1001: //Test Equivalence
            OPS_result = A ^ B;
            //flag update

            //10
            4'b1010: //Compare
            OPS_result = A - B;  

            //11
            4'b1011: //Compare Negated
            // begin
            OPS_result = A + B;
            // end


            //12
            4'b1100: //Logical Or
            OPS_result = A | B;

            //13
            4'b1101: //Move
            OPS_result = B;

            //14
            4'b1110: //Bit Clear
            OPS_result = A & (~B);

            //15
            4'b1111: //Move Not
            OPS_result = ~B;
        endcase

        //for when result is zero
        tz = (OPS_result == 32'b0) ? 1:0;
    
        
        //for when result is negative
        tn = (OPS_result[31] == 1'b1) ? 1:0;
        
        //for Carry out
        tc = OPS_result[32];

        //for when result provokes overflow
        if(ol == 1) begin // subtract
            if(A[31] != B[31]) begin
                if(OPS_result[31] == B[31])
                    tv = 1;
                else
                    tv = 0;
            end else
                tv = 0;
        end

        if(ol == 2) begin //revers sub
            if(B[31] != A[31]) begin
                if(OPS_result[31] == A[31])
                    tv = 1;
                else
                    tv = 0;
            end else
                tv = 0;
        end

        if(ol ==3)begin // addition
            if(A[31] == B[31])begin
                if(A[31] != OPS_result[31])
                    tv = 1;
                else 
                    tv = 0;
            end else
                tv = 0;

        end
  
    end

endmodule
//===============================================================END ALU CODE========================================================

//==============================================================SHIFT/SIGN EXTEND====================================================
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
//===================================================================END SIGN/SHIFT EXTEND===========================================