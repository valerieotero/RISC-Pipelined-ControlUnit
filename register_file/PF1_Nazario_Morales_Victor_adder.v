//Author: Victor Nazario Morales
//Created on: Septemeber 25, 2020
//Description: Simple half adder with no carry that increments a given input by decimal 4.

module adder(PC, sum);
input [31:0] PC;
output [31:0]sum;
assign sum = PC + 'b0100; //binary representation of decimal 4
endmodule


module tester;
reg [31:0] PC;
wire [31:0] sum;

adder add(.PC(PC), .sum(sum));

initial begin
    PC = 'b11000011010100000; //32 bit binary  representation of decimall 100000
 $display ("Decimal representation of PC: %0d  After using PC+4: %0d", PC, sum);

    PC = 'b10; ////32 bit binary  representation of decimall 2
 $display ("Decimal representation of PC: %0d  After using PC+4: %0d", PC, sum);


  end
endmodule

