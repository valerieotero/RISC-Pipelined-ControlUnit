/*Creator: Ashley Ortiz Colon
*/

module alu(input [31:0] A, B, input [3:0] OPS, input Cin, output [31:0] S, output [3:0] Alu_Out); // N, Z, C, V);

    reg [32:0] OPS_result;

    integer tn = 0; 
    integer tz = 0; 
    integer tc = 0; 
    integer tv = 0; 
    integer ol = 0;

    assign Alu_Out[3] = tn; //Negative
    assign Alu_Out[2] = tz; //Zero 
    assign Alu_Out[1] = tc; //Carry Out
    assign Alu_Out[0] = tv; //Overflow

    // integer mod_cond_codes;

    assign S = OPS_result[31:0];
   
    always@(*)//OPS,A,B,Cin)
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