//Author: Víctor A. Nazario Morales
//Created on: September 20, 2020
//Description: Defines all the needed components (here modules) for the correct functionality of
//a register file according to PF1 specifications.

module register_file(PA, PB, PD, PW, PCin, PCout, C, SA, SB, SD, RFLd, PCLd, HZPCld, CLK, RST);
    //Outputs
    output [31:0] PA, PB, PD, PCout;
    output [31:0] MO; //output of the 2x1 multiplexer
    output [1:0] R15MO; //Output of mux used to select which input to charge PCin or PW
    //Inputs
    input [31:0] PW, PCin;
    input [3:0] SA, SB, SD, C;
    input RFLd, PCLd, CLK, RST, HZPCld;

    wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
    wire [15:0] E;

    //Binary Decoder
    binary_decoder bc (E, C, RFLd);

    //Multiplexers
    multiplexer muxA (PA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SA);
    multiplexer muxB (PB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SB);
    multiplexer muxD (PD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, SD);


    loadDecoder r15decoder(PCLd, E[15], R15MO);

    //Added this 2x1 multi to handle R15 input variations
    //Here PC is equivalent to PW in the diagram and PCin
    //is the equivalent to the PC (which gets increaed by 4)
    twoToOneMultiplexer r15mux (PW, PCin, PCLd, MO);


    //16 Registers
    register R0 (Q0, PW, E[0], CLK);
    register R1 (Q1, PW, E[1], CLK);
    register R2 (Q2, PW, E[2], CLK);
    register R3 (Q3, PW, E[3], CLK);
    register R4 (Q4, PW, E[4], CLK);
    register R5 (Q5, PW, E[5], CLK);
    register R6 (Q6, PW, E[6], CLK);
    register R7 (Q7, PW, E[7], CLK);
    register R8 (Q8, PW, E[8], CLK);
    register R9 (Q9, PW, E[9], CLK);
    register R10 (Q10, PW, E[10], CLK);
    register R11 (Q11, PW, E[11], CLK);
    register R12 (Q12, PW, E[12], CLK);
    register R13 (Q13, PW, E[13], CLK);
    register R14 (Q14, PW, E[14], CLK);
    PCregister R15 (Q15, MO, HZPCld, CLK, RST);
    assign PCout = Q15;

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

//This defines the multiplexer used to change inputs to r15 conditionally
module twoToOneMultiplexer(PW, PC, R15MO, MO);
    //Output
    output reg [31:0] MO;
    //Input
    input[31:0] PW, PC;
    input R15MO;

    //Whenever a change is produced in the signals, change the output
    //according with the stablished logic.
    always @(PW, PC, R15MO)
    begin
        if (R15MO)
            MO <= PC;
        else
            MO <= PW;
    end
endmodule

module loadDecoder(PCLd, RFLd, R15MO);
//When the binary decoder assigns a value of one to E[15] that means R15 has RFLd = 1,
// thus we write PW instead of PCin. So R15 is going to be 1 which in terms means PW will be loaded.
//Otherwise we set it to 0 and PCin is loaded into the register.
output reg[1:0] R15MO;
input PCLd, RFLd;

//What happens when both = 1?
//Does this means that the following is accomplished?

//El PC tendrá una señal de “load enable” que cuando esté activa permitirá que el valor externo se cargue en el PC cuando
//ocurra el “rising edge” del reloj del sistema, excepto cuando el puerto de entrada trate de escribir
//el mismo, lo cual tiene prioridad.
always @ (PCLd, RFLd)
    begin
        if(RFLd)
          R15MO <= 1'b1;
        else
          R15MO <= 1'b0;
    end
endmodule


module register(Q, PW, RFLd, CLK);
    //Output
    output reg [31:0] Q;
    //Inputs
    input [31:0] PW;
    input RFLd, CLK;

    always @ (posedge CLK)
    begin
        if (RFLd)
            Q <= PW;
    end

endmodule

module PCregister(Q, MOin, HZPCld, CLK, RST);
    //Output
    output reg [31:0] Q;
    //Inputs
    input [31:0] MOin;
    input HZPCld, CLK, RST;
    //wire CLK, RST;

    always @ (posedge CLK or posedge RST or HZPCld)
    begin
        if(HZPCld)
        begin
            if(RST)
                Q <= 32'b0;

            else
                Q <= MOin;
        end
    end
endmodule

//module tester;
//    //Variable for loop
//    integer index;
//    //Inputs
//    reg CLK, RFLd, PCLd, RST, HZPCLd;
//    reg [3:0] SA, SB, SD, SPCout, C;
//    reg [31:0] PW, PCin;
//
//    //Outputs
//    wire [31:0] PA, PB, PD, PCout;
//
//    initial RST = 1'b1;
//
//    initial HZPCLd = 1'b1;
//
//
//
//    //Clock Signal
//    always begin
//        #5;
//        PCin = PCin + 4;
//        CLK = ~CLK;
//    end
//
//    //PCLoad signal
////    always begin
////        #2;
////        PCLd = ~PCLd;
////    end
//
//
////    Will print values for each tick of the clock. All 32bit values displayed in decimal
////    without trailing zeroes, binary otherwise.
//     always @ (CLK)
//     begin
//         $display("PC:%3d | PW:%3d | SA:%b | SB:%b | SD:%b | PA:%3d | PB:%3d | PD:%3d | C:%b | PCLd:%b | PCout: %3d", PCin, PW, SA, SB, SD, PA, PB, PD, C, PCLd, PCout);
//         //$display("PC:%3d | PCout: %3d", PCin, PCout);
//     end
//
//    register_file test (.PA(PA), .PB(PB), .PD(PD), .PW(PW), .PCin(PCin), .PCout(PCout), .C(C), .SA(SA), .SB(SB), .SD(SD), .RFLd(RFLd), .PCLd(PCLd), .HZPCld(HZPCLd), .CLK(CLK), .RST(RST));
//    initial begin
//    //$monitor("PC:%3d | PCout: %3d | PCLd:%b | RFLd:%3d | HZPCLd :%b", PCin, PCout, PCLd, RFLd, HZPCLd);
//        //Initial values
//        PW = 32'b0;
//        C = 4'b0000;
//        SA = 4'b0000;
//        SB = 4'b0000;
//        SD = 4'b0000;
//        RFLd = 1'b0;
//        PCLd = 1'b0;
//        CLK = 1'b1;
//        PCin = 32'b0;
//        RST = 1'b0;
//
//        //Enable load in each register (Ld = 1)
//        #10;
//        RFLd = 1'b1;
//        PCLd = 1'b1;  //Tells if we write PC or PW
//
//        //Writing a unique word of each register using Port C(PC)//
//
//        //Register 0
//        #10;
//        C = 4'b0000;
//        PW = 32'd0;
//        SA = 4'b0000;
//        SB = 4'b0000;
//        SD = 4'b0000;
//
//
//        //Register 1
//        #10;
//        C = 4'b0001;
//        PW = 32'd3;
//        SA = 4'b0001;
//        SB = 4'b0001;
//        SD = 4'b0001;
//
//        //Register 2
//        #10;
//        C = 4'b0010;
//        PW = 32'd7;
//        SA = 4'b0010;
//        SB = 4'b0010;
//        SD = 4'b0010;
//
//        //Register 3
//        #10;
//        C = 4'b0011;
//        PW = 32'd90;
//        SA = 4'b0011;
//        SB = 4'b0011;
//        SD = 4'b0011;
//
//        //Register 4
//        #10;
//        C = 4'b0100;
//        PW = 32'd17;
//
//        //Register 5
//        #10;
//        C = 4'b0101;
//        PW = 32'd73;
//
//        //Register 6
//        #10;
//        C = 4'b0110;
//        PW = 32'd6;
//
//        //Register 7
//        #10;
//        C = 4'b0111;
//        PW = 32'd50;
//
//        //Register 8
//        #10;
//        C = 4'b1000;
//        PW = 32'd45;
//
//        //Register 9
//        #10;
//        C = 4'b1001;
//        PW = 32'd18;
//
//        //Register 10
//        #10;
//        C = 4'b1010;
//        PW = 32'd9;
//        //RST = 1'b1;    //Can be used to cause a RST
//        //HZPCLd = 1'b0; //Can be used to cause PC to not increment
//
//
//        //Register 11
//        #10;
//        C = 4'b1011;
//        PW = 32'd6;
//
//        //Register 12
//        #10;
//        C = 4'b1100;
//        PW = 32'd24;
//
//        //Register 13
//        #10;
//        C = 4'b1101;
//        PW = 32'd21;
//
//
//        //Register 14
//        #10;
//        C = 4'b1110;
//        PW = 32'd83;
//
//
//        //Register 15
//        #10;
//        C = 4'b1111;
//        PW = 32'd35;
//
//        //Won't charge PCin, it will charge PW instead given these two signals bellow.
//        PCLd = 1'b0;
//        RFLd = 1'b1;
//
//
//
//        //This changes the word in R10 and reads said word via Port A(PA).
//        #10;
//        C = 4'b1010;
//        PW = 32'd16;
//        #10
//        SA = 4'b1010;
//        //Showing output through PA, after changing the word in Register 10
//        //$monitor ("Output of Register ", SA, " (using PA) (After Change): PA: %0d",PA);
//        // $monitor("Output of Register 15: %0d", PD, " with PCout:%0d, PCLd was:%d", PCout, PCLd, " Output of Register ", SA, " (using PA) (After Change): PA: %0d" ,PA);
//    $finish;
//    end
//
//endmodule
