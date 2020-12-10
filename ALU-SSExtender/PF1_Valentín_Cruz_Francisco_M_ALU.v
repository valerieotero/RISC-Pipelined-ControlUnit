
module ALU(output [31:0] ALU_Out, output CarryOut, Z, N, V, input [31:0] A,B, input [3:0] ALU_OP,input CarryIn);
  reg [32:0] result;
  integer temp_c = 0;
  integer temp_n = 0;
  integer temp_z = 0;
  integer temp_v = 0;
  integer flag = 0;
  assign V = temp_v;
  assign Z = temp_z;
  assign N = temp_n;
  assign ALU_Out = result[31:0];
  assign CarryOut = temp_c;
  always@(ALU_OP,A,B,CarryIn)

  
  begin
	case(ALU_OP)
		4'b0000:
			result = A & B;
		4'b0001:
		    result = A ^ B;
		4'b0010: 
		begin
		    $display("A-B");
			result = A - B;
			flag = 2;
		end
		4'b0011:
		begin
		$display("B-A");
			result = B - A;
			flag = 3;
		end
		4'b0100:
		begin
			result = A + B;
			flag = 1;
		end
		4'b0101:
		begin
			result = A + B + CarryIn;
			flag = 1;
		end
		4'b0110:
		begin
			result = A - B + CarryIn - 32'b1;
			flag = 4;
		end
		4'b0111:
		begin
		$display("B-A + Cin -1");
		    result = B - A + CarryIn - 32'b1;
		    flag = 5;
		end
		4'b1000:
			result = A & B;
		4'b1001:
			result = A ^ B;	
		4'b1010:
		begin
			result = B - 32'b1;
			if(B > 31'b1 && result[31]==B[31])
			    temp_v = 0;
			else 
			    temp_v = 1;
		end	
		4'b1011:
		begin
			result = B + 32'b1;
			if(result[31]==B[31]) 
			    temp_v = 0;
			else 
			    temp_v = 1;
		end	
		4'b1100:
			result = A | B;
		4'b1101:
			result = B;
		4'b1110:
			result = A & !B;
		4'b1111:
			result = !B;
	endcase
	temp_n = result[31] & (result[32] == 1'b0);
	temp_c = result[32];
	temp_z = result == 32'b0;
	
	if(flag ==1) //suma
	    if(A[31] == B[31])
	       if(A[31] != result[31])
	            temp_v = 1;
	       else 
	            temp_v = 0;
	if(flag == 2) begin//resta
	    if(A < B && result[31] == 1)
	        temp_v = 0;
	    else if(A >= B && (result[31] == 0 || result[31] == A[31]))
	        temp_v = 0;
	    else
	        temp_v = 1;
	    end
	if(flag == 3) begin //reverse sub
	    if(B < A && result[31] == 1)
	       temp_v = 0;
	   	else if(B >= A && (result[31] == 0 || result[31] == B[31]))
	       temp_v = 0;
	    else
	       temp_v = 1;
	   end
	 if(flag == 4) begin
	    if((A + CarryIn) < (B + 1'b1) && result[31] == 1)
	       temp_v = 0;
	   	else if((A+CarryIn) >= (B + 1'b1) && (result[31] == 0 || result[31] == A[31]))
	       temp_v = 0;
	    else
	       temp_v = 1;
	   end
	 if(flag == 5) begin
	    if((B + CarryIn) < (A + 1'b1) && result[31] == 1)
	       temp_v = 0;
	   	else if((B+CarryIn) >= (A + 1'b1) && (result[31] == 0 || result[31] == B[31]))
	       temp_v = 0;
	    else
	       temp_v = 1;
	   end
	else
	    temp_v = 0;
    	flag = 0;
  end
endmodule