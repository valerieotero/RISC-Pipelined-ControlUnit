module sr_subregister(output reg [3:0] cc_out, input [3:0] cc_in, input S, input CLK);

    always @ (posedge CLK)
    begin
        if (S)
            cc_out <= cc_in;
    end

endmodule

module tester;

wire [3:0] cc_out;
reg [3:0] cc_in;
reg S;
reg CLK;

sr_subregister intermediate_reg (.cc_out(cc_out), .cc_in(cc_in), .S(S), .CLK(CLK));

    always begin
        #2;
        CLK <= ~CLK;
    end

    always begin
        #2;
        S <= ~S;
    end

    initial begin
      CLK = 1'b0;
      S = 1'b0;
      #10;
      cc_in = 4'b0001;
      $monitor ("Here's CC: %b, %b, %b", cc_out, S, CLK);
      $finish;
    end
endmodule