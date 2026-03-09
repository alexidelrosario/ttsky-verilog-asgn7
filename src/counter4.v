`timescale 1ns / 1ps

module counter4(
    input clk_i,        // clock
    input up_i,         // increment
    input dw_i,         // decrement 
	input reset_i,
    input ld_i,         // load control
    input [3:0] din_i,  // 4bit vector din thats loaded on the clock edge if LD is high
    output [3:0] q_o,   // current value held by counter
    output utc_o,       // up terminal count == 1 when countUD4L = 1'b1111 = 15
    output dtc_o        // down terminal count == 1 when countUD4L = 4'b0000 = 0
    );
    
    wire [3:0] mux_out_w;       // mux output
    wire [3:0] add_sub_out_w;   // addSub8 output
    wire [3:0] q_w;
	reg [3:0] q_r; // register for FF
    
    // clock enable FF if one is active
    wire ce_w = (up_i & ~dw_i) | (dw_i & ~up_i) | ld_i;
    
    wire sub = ~up_i & dw_i;  // 1 if decrement/DW
    
    assign q_w = q_r;
	assign q_o = q_r;
    
    addSub8 inc_dec (
        .A(q_w),          // current counter val
        .B(4'b0001),        // add or sub 1
        .sub(sub),          // 1 if subtracting
        .S(add_sub_out_w)   // new value
    );

    assign mux_out_w[0] = (ld_i & din_i[0]) | (~ld_i & add_sub_out_w[0]);
    assign mux_out_w[1] = (ld_i & din_i[1]) | (~ld_i & add_sub_out_w[1]);
    assign mux_out_w[2] = (ld_i & din_i[2]) | (~ld_i & add_sub_out_w[2]);
    assign mux_out_w[3] = (ld_i & din_i[3]) | (~ld_i & add_sub_out_w[3]);

    always @(posedge clk_i) begin
        if (reset_i)
            q_r <= 4'b0000;
        else if (ce_w)
            q_r <= mux_out_w;
    end
   
   assign utc_o = q_o[0] & q_o[1] & q_o[2] & q_o[3];
   assign dtc_o = ~q_o[0] & ~q_o[1] & ~q_o[2] & ~q_o[3];
 
endmodule
