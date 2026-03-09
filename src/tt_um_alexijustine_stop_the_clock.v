`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 01:12:37 PM
// Design Name: 
// Module Name: top_level
// Project Name: stop the clock
// Target Devices: 
// Tool Versions: 
// Description: values count up, if player presses stop at the designated time, the player wins.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tt_um_alexijustine_stop_the_clock(
    input  wire [7:0] ui_in,    // Dedicated inputs        // ui[0] = stop
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    //     orig inputs: input clk_i, input reset_i, input stop_i, output [3:0] uo_out[3:0], output win_o

    
wire up_w;
reg stopped_w;

// latch for stop button
always @(posedge clk) begin
    if (~rst_n) stopped_w <= 1'b0;
    else stopped_w <= stopped_w | ui_in[0];
end

assign up_w = ~stopped_w;  // count up until stop is pressed.

counter4 start_count (
    .clk_i(clk),
    .up_i(up_w),
    .dw_i(1'b0),    // taken from cse100, down not needed
    .ld_i(1'b0),    
    .din_i(4'b0000),    // starts at 0
    .reset_i(~rst_n),
    .q_o(uo_out[3:0]),
    .utc_o(),        
    .dtc_o()      
);

// win if player stops at 10
assign uo_out[4] = stopped_w & (uo_out[3:0] == 4'd10);

// unused values
assign uo_out[7:5] = 3'b0; 
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

wire _unused = &{uo_out[7:5], uio_out, uio_oe, 1'b0};

endmodule
