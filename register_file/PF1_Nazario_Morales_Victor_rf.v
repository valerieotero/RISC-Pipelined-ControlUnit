//Author: Víctor A. Nazario Morales
//Created on: September 20, 2020
//Description: Defines all the needed components (here modules) for the correct functionality of
//a register file according to PF1 specifications.

module register_file(PA, PB, PD, PC, C, SA, SB, SD, RFLd, CLK);
    //Outputs
    output [31:0] PA, PB, PD;
    //Inputs
    input [31:0] PC;
    input [3:0] SA, SB, SD, C;
    input RFLd, CLK;
    
    wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
    wire [15:0] E;

    //Binary Decoder
    binary_decoder bc (E, C, RFLd);
    
    //Multiplexers
    multiplexer muxA (PA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SA);
    multiplexer muxB (PB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SB);
    multiplexer muxD (PD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SD);

    
    //16 Registers
    register R0 (Q0, PC, E[0], CLK);
    register R1 (Q1, PC, E[1], CLK);
    register R2 (Q2, PC, E[2], CLK);
    register R3 (Q3, PC, E[3], CLK);
    register R4 (Q4, PC, E[4], CLK);
    register R5 (Q5, PC, E[5], CLK);
    register R6 (Q6, PC, E[6], CLK);
    register R7 (Q7, PC, E[7], CLK);
    register R8 (Q8, PC, E[8], CLK);
    register R9 (Q9, PC, E[9], CLK);
    register R10 (Q10, PC, E[10], CLK);
    register R11 (Q11, PC, E[11], CLK);
    register R12 (Q12, PC, E[12], CLK);
    register R13 (Q13, PC, E[13], CLK);
    register R14 (Q14, PC, E[14], CLK);
    register R15 (Q15, PC, E[15], CLK);  //register 15 will have two data sources on future revisions.

endmodule

module binary_decoder(E, C, Ld);
    //Output
    output reg [15:0] E;
    //Inputs
    input [3:0] C;
    input Ld;
    
    always @(C, Ld)

        if(Ld) 
            case(C)
                4'b0000: E <= 16'b0000000000000001;
                4'b0001: E <= 16'b0000000000000010;
                4'b0010: E <= 16'b0000000000000100;
                4'b0011: E <= 16'b0000000000001000;
                4'b0100: E <= 16'b0000000000010000;
                4'b0101: E <= 16'b0000000000100000;
                4'b0110: E <= 16'b0000000001000000;
                4'b0111: E <= 16'b0000000010000000;
                4'b1000: E <= 16'b0000000100000000;
                4'b1001: E <= 16'b0000001000000000;
                4'b1010: E <= 16'b0000010000000000;
                4'b1011: E <= 16'b0000100000000000;
                4'b1100: E <= 16'b0001000000000000;
                4'b1101: E <= 16'b0010000000000000;
                4'b1110: E <= 16'b0100000000000000;
                4'b1111: E <= 16'b1000000000000000;
            endcase
        else  E <= 16'b0000000000000000;
        
endmodule

module multiplexer(P, I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, S);
    //Output
    output reg [31:0] P;
    //Inputs
    input [31:0] I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15;
    input [3:0] S;

    always @(S, I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15)
    
    case (S)
        4'b0000: P <= I0;
        4'b0001: P <= I1;
        4'b0010: P <= I2;
        4'b0011: P <= I3;
        4'b0100: P <= I4;
        4'b0101: P <= I5;
        4'b0110: P <= I6;
        4'b0111: P <= I7;
        4'b1000: P <= I8;
        4'b1001: P <= I9;
        4'b1010: P <= I10;
        4'b1011: P <= I11;
        4'b1100: P <= I12;
        4'b1101: P <= I13;
        4'b1110: P <= I14;
        4'b1111: P <= I15;
        
    endcase
endmodule

module register(Q, PC, RFLd, CLK);
    //Output
    output reg [31:0] Q;
    //Inputs
    input [31:0] PC;
    input RFLd, CLK;

    always @ (posedge CLK)
    begin
        if (RFLd) 
            Q <= PC;  
    end
    
endmodule

module tester;
    //Variable for loop
    integer index;
    //Inputs
    reg CLK, RFLd;
    reg [3:0] SA, SB, SD, C;
    reg [31:0] PC, PC4;

    //Outputs
    wire [31:0] PA, PB, PD;
    
    //Clock Signal
    always begin
        #5;
        CLK = ~CLK;
    end

    //Will print values for each tick of the clock. All 32bit values displayed in decimal
    //without trailing zeroes, binary otherwise.
    always @ (CLK)
    begin
        $display("PC:%0d | SA:%b | SB:%b | SD:%b | PA:%0d | PB:%0d | PD:%0d | C:%b | PC:%0d", PC, SA, SB, SD, PA, PB, PD, C, PC);
    end

    register_file test (.PA(PA), .PB(PB), .PD(PD), .PC(PC), .C(C), .SA(SA), .SB(SB), .SD(SD), .RFLd(RFLd), .CLK(CLK));
    initial begin
        //Initial values
        PC = 32'b0;
        C = 4'b0000;
        SA = 4'b0000;
        SB = 4'b0000;
        SD = 4'b0000;
        RFLd = 1'b0;
        CLK = 1'b0;
        
        //Enable load in each register (Ld = 1)
        #10;         
        RFLd = 1'b1;
        
        //Writing a unique word of each register using Port C(PC)//
        
        //Register 0
        #10;
        C = 4'b0000;
        PC = 32'd0;
        SA = 4'b0000;
        SB = 4'b0000;
        SD = 4'b0000;

        
        //Register 1
        #10;
        C = 4'b0001;
        PC = 32'd3;
        SA = 4'b0001;
        SB = 4'b0001;
        SD = 4'b0001;
        
        //Register 2
        #10;
        C = 4'b0010;
        PC = 32'd7;
        SA = 4'b0010;
        SB = 4'b0010;
        SD = 4'b0010;
        
        //Register 3
        #10;
        C = 4'b0011;
        PC = 32'd90;
        SA = 4'b0011;
        SB = 4'b0011;
        SD = 4'b0011;
        
        //Register 4
        #10;
        C = 4'b0100;
        PC = 32'd17;
        
        //Register 5
        #10;
        C = 4'b0101;
        PC = 32'd73;
        
        //Register 6
        #10;
        C = 4'b0110;
        PC = 32'd6;
        
        //Register 7
        #10;
        C = 4'b0111;
        PC = 32'd50;
        
        //Register 8
        #10;
        C = 4'b1000;
        PC = 32'd45;
        
        //Register 9
        #10;
        C = 4'b1001;
        PC = 32'd18;
        
        //Register 10
        #10;
        C = 4'b1010;
        PC = 32'd9;
        
        //Register 11
        #10;
        C = 4'b1011;
        PC = 32'd6;
        
        //Register 12
        #10;
        C = 4'b1100;
        PC = 32'd24;
        
        //Register 13
        #10;
        C = 4'b1101;
        PC = 32'd21;
        
        //Register 14
        #10;    
        C = 4'b1110;
        PC = 32'd83;
        
        //Register 15
        #10;
        C = 4'b1111;
        PC = 32'd35;
        PC4 = PC + 'b0100;

        
        //This changes the word in R10 and reads said word via Port A(PA).
        #10;
        C = 4'b1010;
        PC = 32'd16;
        #10
        SA = 4'b1010;
        //Showing output through PA, after changing the word in Register 10
        $monitor ("Output of Register ", SA, " (using PA) (After Change): PA: %0d",PA);
    $finish;
    end
    
endmodule