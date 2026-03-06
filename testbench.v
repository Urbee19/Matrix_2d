//`timescale 1ns/1ps
//module testbench;

//    reg clk, rst;
//    reg [1:0] op;
//    wire [15:0] data_out;

   
//    matrix2d dut (
//        .clk(clk),
//        .rst(!rst),
//        .op(op),
//        .data_out(data_out)
//    );

   
//    always #5 clk = ~clk;

//    initial begin
//        clk = 0;
//        rst = 1;
//        op  = 2'b00;

//        #20 rst = 0;

        
//        op = 2'b00;
//        #2000;

       
//        op = 2'b01;
//        #200;

        
//        op = 2'b10;
//        #400;

//        $finish;
//    end

//    initial begin
//        $monitor("Time=%0t | Op=%b | Output=%d",
//                  $time, op, data_out);
//    end

//endmodule

`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg [1:0] op;
    wire [15:0] data_out;

    matrix2d dut (
        .clk(clk),
        .rst(rst),
        .op(op),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        clk = 0;
        rst = 0;
        op  = 2'b00;

        #20  rst = 1;          // ADD
        #200 op = 2'b01;       // SUB
        #200 op = 2'b10;       // MUL
        #200 op = 2'b11;       // TRANSPOSE A then B

        #2000 $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | op=%b | data_out=%d",
                  $time, op, $signed(data_out));
    end

endmodule

