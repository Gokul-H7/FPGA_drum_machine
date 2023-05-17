module pwm #(parameter int CTRVAL = 256, parameter int CTRLEN = $clog2(CTRVAL)) 
            (input logic clk, input logic rst, input logic enable, input logic [CTRLEN-1:0] duty_cycle,
             output logic [CTRLEN-1:0] counter, output logic pwm_out);
    always_ff @ (posedge clk, posedge rst)begin
        if(rst == 1'b1)
            counter <= 0;
        else if(enable == 1'b1)
            counter <= counter + 1'b1;
    end
    always_comb begin
        if(counter <= duty_cycle)
            pwm_out = 1'b1;
        else if(duty_cycle == CTRLEN'(CTRVAL-1))
            pwm_out = 1'b1;
        else if(duty_cycle == 0)
            pwm_out = 1'b0;
        else
            pwm_out = 1'b0;
    end
endmodule