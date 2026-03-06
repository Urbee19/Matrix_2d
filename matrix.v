//module matrix2d (
//    input  wire        clk,
//    input  wire        rst,
//    input  wire [1:0]  op,
//    output reg  [15:0] data_out
//);

//    reg [7:0] A [0:3][0:3];
//    reg [7:0] B [0:3][0:3];

//    reg [1:0] i, j;          
//    reg [17:0] mul_sum;      

//    initial begin
//        A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;
//        A[1][0]=5;  A[1][1]=6;  A[1][2]=7;  A[1][3]=8;
//        A[2][0]=9;  A[2][1]=10; A[2][2]=11; A[2][3]=12;
//        A[3][0]=13; A[3][1]=14; A[3][2]=15; A[3][3]=16;

//        B[0][0]=1;  B[0][1]=0;  B[0][2]=0;  B[0][3]=1;
//        B[1][0]=0;  B[1][1]=1;  B[1][2]=1;  B[1][3]=0;
//        B[2][0]=1;  B[2][1]=1;  B[2][2]=0;  B[2][3]=0;
//        B[3][0]=0;  B[3][1]=0;  B[3][2]=1;  B[3][3]=1;
//    end

//    always @(posedge clk) begin
//        if (!rst) begin
//            i <= 0;
//            j <= 0;
//            data_out <= 0;
//            mul_sum <= 0;
//        end else begin

//            // MATRIX MULTIPLICATION
//            mul_sum <=
//                A[i][0]*B[0][j] +
//                A[i][1]*B[1][j] +
//                A[i][2]*B[2][j] +
//                A[i][3]*B[3][j];

//            case (op)
//                2'b00: data_out <= A[i][j] + B[i][j];  // ADD
//                2'b01: data_out <= A[i][j] - B[i][j];  // SUB
//                2'b10: data_out <= mul_sum;            // MUL
//                default: data_out <= 0;
//            endcase

//            // index update
//            if (j == 3) begin
//                j <= 0;
//                i <= (i == 3) ? 0 : i + 1;
//            end else begin
//                j <= j + 1;
//            end
//        end
//    end

////adding ILA
//ila_0 ILA(clk,data_out);
//endmodule
////iverilog -o matrix_sim testbench.v matrix2d.v
////vvp matrix_sim


module matrix2d (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  op,
    output reg  [15:0] data_out
);

    reg [7:0] A [0:3][0:3];
    reg [7:0] B [0:3][0:3];

    reg [1:0] i, j;
    reg [17:0] mul_sum;

    reg [1:0] state;
    reg [1:0] last_op;

    reg trans;

    parameter IDLE = 2'b00;
    parameter CALC = 2'b01;
    parameter DONE = 2'b10;

    initial begin
        A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;
        A[1][0]=5;  A[1][1]=6;  A[1][2]=7;  A[1][3]=8;
        A[2][0]=9;  A[2][1]=10; A[2][2]=11; A[2][3]=12;
        A[3][0]=13; A[3][1]=14; A[3][2]=15; A[3][3]=16;

      B[0][0]=1; B[0][1]=0; B[0][2]=0; B[0][3]=1; B[1][0]=0; B[1][1]=1; B[1][2]=1; B[1][3]=0; B[2][0]=1; B[2][1]=1; B[2][2]=0; B[2][3]=0; B[3][0]=0; B[3][1]=0; B[3][2]=1; B[3][3]=1;
//B[0][0]=23; B[0][1]=6; B[0][2]=8; B[0][3]=11;
//B[1][0]=78; B[1][1]=54; B[1][2]=14; B[1][3]=80;
//B[2][0]=1; B[2][1]=165; B[2][2]=87; B[2][3]=99;
//B[3][0]=27; B[3][1]=67; B[3][2]=250; B[3][3]=28;
    end

    always @(posedge clk) begin
        if (!rst) begin
            i <= 0;
            j <= 0;
            data_out <= 0;
            mul_sum <= 0;
            state <= IDLE;
            last_op <= 2'b11;
            trans <= 0;
        end else begin
            case (state)

                IDLE: begin
                    i <= 0;
                    j <= 0;
                    trans <= 0;
                    last_op <= op;
                    state <= CALC;
                end

                CALC: begin
                    mul_sum <= A[i][0]*B[0][j] +
                               A[i][1]*B[1][j] +
                               A[i][2]*B[2][j] +
                               A[i][3]*B[3][j];

                    case (op)
                        2'b00: data_out <= A[i][j] + B[i][j];     // ADD
                        2'b01: data_out <= A[i][j] - B[i][j];     // SUB
                        2'b10: data_out <= mul_sum;               // MUL

                        2'b11: begin                               // TRANSPOSE
                            if (trans == 0)
                                data_out <= A[j][i];              // Transpose A
                            else
                                data_out <= B[j][i];              // Transpose B
                        end

                        default: data_out <= 0;
                    endcase

                    if (i == 3 && j == 3) begin
                        if (op == 2'b11 && trans == 0) begin
                           
                            i <= 0;
                            j <= 0;
                            trans <= 1;
                        end else
                            state <= DONE;
                    end else if (j == 3) begin
                        j <= 0;
                        i <= i + 1;
                    end else
                        j <= j + 1;
                end

                DONE: begin
                    if (op != last_op) begin
                        i <= 0;
                        j <= 0;
                        trans <= 0;
                        last_op <= op;
                        state <= CALC;
                    end
                end

            endcase
        end
    end

endmodule
