module top (
  // I/O ports
  input  logic hz2m, hz100, reset,
  input  logic [20:0] pb,
  /* verilator lint_off UNOPTFLAT */
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

logic strobe, set_edit, set_play, set_raw, bpm_clk, sample_clk;
logic [1:0] mode;
logic [2:0] edit_seq, seq_sel;
logic [3:0] smpl, raw_play_smpl, play_smpl;
logic [4:0] keycode;
logic [7:0] edit_seq_out, play_seq_out, seq_out;
logic [3:0] edit_play_smpl [7:0];
logic [7:0] sample_data [3:0];

clkdiv #(20) clk2hz(.clk(hz2m), .rst(reset), .lim(20'd499999), .hzX(bpm_clk));
clkdiv #(8) clk16khz(.clk(hz2m), .rst(reset), .lim(8'd128), .hzX(sample_clk));

scankey sk1(.clk(hz2m), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
always_comb begin
  if(keycode == 5'b10011) begin
    set_edit = 1'b1;
    set_play = 1'b0;
    set_raw = 1'b0;
  end
  else if(keycode == 5'b10010) begin
    set_edit = 1'b0;
    set_play = 1'b1;
    set_raw = 1'b0;
  end
  else if(keycode == 5'b10000) begin
    set_edit = 1'b0;
    set_play = 1'b0;
    set_raw = 1'b1;
  end
  else begin
    set_edit = 1'b0;
    set_play = 1'b0;
    set_raw = 1'b0;
  end
end
controller c1(.clk(strobe), .rst(reset), .set_edit(set_edit), .set_play(set_play), .set_raw(set_raw), .mode(mode));
sequencer s1(.clk(strobe), .rst(reset), .srst(mode != 2'b00), .go_left(pb[11]), .go_right(pb[8]), .seq_out(edit_seq_out));
sequencer s2(.clk(bpm_clk), .rst(reset), .srst(mode != 2'b01), .go_left(1'b0), .go_right(1'b1), .seq_out(play_seq_out));
always_ff @ (posedge hz2m, posedge reset) begin
  if(reset == 1'b1)
    seq_out <= 8'b0;
  else if(mode == 2'b00)
    seq_out <= edit_seq_out;
  else if(mode == 2'b01)
    seq_out <= play_seq_out;
end
assign left[7] = seq_out[7];
assign left[5] = seq_out[6];
assign left[3] = seq_out[5];
assign left[1] = seq_out[4];
assign right[7] = seq_out[3];
assign right[5] = seq_out[2];
assign right[3] = seq_out[1];
assign right[1] = seq_out[0];
prienc8to3 prienc1(.in(seq_out), .out(seq_sel));
always_comb begin
  if(pb[3] == 1'b1) begin
    smpl = 4'b1000;
    raw_play_smpl = 4'b1000;
  end
  else if(pb[2] == 1'b1) begin
    smpl = 4'b0100;
    raw_play_smpl = 4'b0100;
  end
  else if(pb[1] == 1'b1) begin
    smpl = 4'b0010;
    raw_play_smpl = 4'b0010;
  end
  else if(pb[0] == 1'b1) begin
    smpl = 4'b0001;
    raw_play_smpl = 4'b0001;
  end
  else begin
    smpl = 4'b0000;
    raw_play_smpl = 4'b0000;
  end
end
always_ff @(posedge hz2m, posedge reset) begin
  if(reset == 1'b1)
    play_smpl <= 4'b0000;
  else if(mode == 2'b00)
    play_smpl <= 4'b0000;
  else if(mode == 2'b01)
    play_smpl <= ((enable_ctr <= 900000) ? edit_play_smpl[seq_sel] : 4'b0) | raw_play_smpl;
  else if(mode == 2'b10)
    play_smpl <= raw_play_smpl;
end
sequence_editor se1(.clk(strobe), .rst(reset), .mode(mode), .set_time_idx(seq_sel), .tgl_play_smpl(smpl), .seq_smpl_1(edit_play_smpl[0]), .seq_smpl_2(edit_play_smpl[1]), .seq_smpl_3(edit_play_smpl[2]), .seq_smpl_4(edit_play_smpl[3]), .seq_smpl_5(edit_play_smpl[4]), .seq_smpl_6(edit_play_smpl[5]), .seq_smpl_7(edit_play_smpl[6]), .seq_smpl_8(edit_play_smpl[7]));
assign {ss7[5], ss7[1], ss7[4], ss7[2]} = edit_play_smpl[7];
assign {ss6[5], ss6[1], ss6[4], ss6[2]} = edit_play_smpl[6];
assign {ss5[5], ss5[1], ss5[4], ss5[2]} = edit_play_smpl[5];
assign {ss4[5], ss4[1], ss4[4], ss4[2]} = edit_play_smpl[4];
assign {ss3[5], ss3[1], ss3[4], ss3[2]} = edit_play_smpl[3];
assign {ss2[5], ss2[1], ss2[4], ss2[2]} = edit_play_smpl[2];
assign {ss1[5], ss1[1], ss1[4], ss1[2]} = edit_play_smpl[1];
assign {ss0[5], ss0[1], ss0[4], ss0[2]} = edit_play_smpl[0];
always_comb begin
  case(mode)
    2'b00: begin // edit mode
      blue = 1'b1;
      green = 1'b0;
      red = 1'b0;
      //seq_out = edit_seq_out;
    end
    2'b01: begin // play mode
      green = 1'b1;
      blue = 1'b0;
      red = 1'b0;
      //seq_out = play_seq_out;
    end
    2'b10: begin // raw mode
      red = 1'b1;
      blue = 1'b0;
      green = 1'b0;
    end
    default begin
      red = 1'b0;
      blue = 1'b0;
      green = 1'b0;
    end
  endcase
end

sample #(.SAMPLE_FILE("../audio/kick.mem"), .SAMPLE_LEN(4000)) sample_kick(.clk(sample_clk), .rst(reset), .enable(play_smpl[3]), .out(sample_data[3]));
sample #(.SAMPLE_FILE("../audio/clap.mem"), .SAMPLE_LEN(4000)) sample_clap(.clk(sample_clk), .rst(reset), .enable(play_smpl[2]), .out(sample_data[2]));
sample #(.SAMPLE_FILE("../audio/hihat.mem"), .SAMPLE_LEN(4000)) sample_hihat(.clk(sample_clk), .rst(reset), .enable(play_smpl[1]), .out(sample_data[1]));
sample #(.SAMPLE_FILE("../audio/snare.mem"), .SAMPLE_LEN(4000)) sample_snare(.clk(sample_clk), .rst(reset), .enable(play_smpl[0]), .out(sample_data[0]));
logic [7:0] sample1, sample2, f, f2;
always_comb begin
  sample1 = sample_data[0] + sample_data[1];
  if(sample1[7] == 1'b0 && sample_data[1][7] == 1'b1 && sample_data[0][7] == 1'b1)
    sample1 = -128;
  else if(sample1[7] == 1'b1 && sample_data[1][7] == 1'b0 && sample_data[0][7] == 1'b0)
    sample1 = 127;

 sample2 = sample_data[2] + sample_data[3];
  if(sample2[7] == 1'b0 && sample_data[2][7] == 1'b1 && sample_data[3][7] == 1'b1)
    sample2 = -128;
  else if(sample2[7] == 1'b1 && sample_data[2][7] == 1'b0 && sample_data[3][7] == 1'b0)
    sample2 = 127;

  f = sample2 + sample1;
  if(f[7] == 1'b0 && sample2[7] == 1'b1 && sample1[7] == 1'b1)
    f = -128;
  else if(f[7] == 1'b1 && sample2[7] == 1'b0 && sample1[7] == 1'b0)
    f = 127;
  f2 = f ^ 8'd128;
end 

pwm #(64) pwm1(.clk(hz2m), .rst(reset), .enable(1'b1), .duty_cycle(f2[7:2]), .counter(), .pwm_out(right[0]));

logic prev_bpm_clk;
logic [31:0] enable_ctr;
always_ff @(posedge hz2m, posedge reset)
  if(reset) begin
    prev_bpm_clk <= 0;
    enable_ctr <= 0;
  end
  else if (mode == 2'b01) begin
    if(~prev_bpm_clk && bpm_clk) begin
      enable_ctr <= 0;
      prev_bpm_clk <= 1;
    end
    else if(prev_bpm_clk && ~bpm_clk) begin
      enable_ctr <= 499999;
      prev_bpm_clk <= 0;
    end
    else begin
      enable_ctr <= (enable_ctr == 999999) ? 0 : enable_ctr + 1;
    end
  end
  else begin
    prev_bpm_clk <= 0;
    enable_ctr <= 0;
  end

  

endmodule
