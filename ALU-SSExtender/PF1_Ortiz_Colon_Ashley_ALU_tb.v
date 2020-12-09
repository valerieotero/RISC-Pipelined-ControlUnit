`include "PF1_Ortiz_Colon_Ashley_ALU.v"


module alu_tb;

    reg signed [31:0] A, B; // inputs
    reg [3:0] OPS, OP; // operands & ID (test purpose)
    reg Cin; //Carry in
    wire signed [31:0] S; // operand result (out)
    wire N, Z, C, V; // condition codes


    alu UUT(A, B, OPS, Cin, S, N, Z, C, V);
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        Cin = 0;
    
        $display("\n\nOP Code               A in Binary                 A in Decimal               B in Binary               B in Decimal             Result in Binary               Result in Decimal   Z   N   C   V ");
        //suma overflow
        OPS = 4'd4; // operation code
        A = 32'b01111111111111111111111111111111;
        B = 32'b00000000000000000000100000000000;
        #10;
        $display(" %b        %b %d          %b %d          %b    %d           %b   %b   %b   %b", OPS, A, A, B, B, S, S, Z, N, C, V);


        //resta overflow
        OPS = 4'd2; 
        A = 32'b10000000000000000000000000000001;
        B = 32'b01000000000011100000100000000000;
        #10;
        $display(" %b        %b %d          %b %d          %b    %d           %b   %b   %b   %b", OPS, A, A, B, B, S, S, Z, N, C, V);
    

        OPS = 4'd0; 
        A = 32'd4;
        B = 32'd2;
        repeat(16) begin 
            #40; //wait time 
            $display(" %b        %b %d          %b %d          %b    %d           %b   %b   %b   %b", OPS, A, A, B, B, S, S, Z, N, C, V);
            OPS = OPS + 4'd1;
        end
        
        
    end

endmodule