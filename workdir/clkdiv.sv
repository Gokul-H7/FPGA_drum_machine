module clkdiv #(parameter BITLEN = 8) (input logic clk, input logic rst, input logic [BITLEN-1:0] lim,
              output logic hzX);
    logic [BITLEN-1:0] Q, next_Q;
    logic hz2;
    always_ff @ (posedge clk, posedge rst) begin
        if(rst == 1'b1)
            Q <= 0;
        else
            Q <= next_Q;
    end
    always_comb begin
        next_Q = Q + 1'b1;
        if(Q == lim)
          next_Q = 0;
    end
    always_ff @ (posedge clk, posedge rst) begin
        if(rst == 1'b1)
            hz2 = 1'b0;
        else
            hz2 = Q == lim;
    end
    always_ff @ (posedge hz2, posedge rst) begin
        if(rst == 1'b1)
            hzX = 1'b0;
        else
            hzX = ~hzX;
    end
endmodule