`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2025 10:52:05
// Design Name: 
// Module Name: FIR_Filter_16tap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 16-tap FIR filter using ECG-optimized low-pass coefficients.
//              Each tap's product is generated using a hyd_mul16_4chain multiplier.
//              The 16 products are summed using a parallel-serial combination tree:
//              - Stage 1: Four serial chains, each adding 4 products.
//              - Stage 2: The four chain results are combined in two groups.
//              - Stage 3: The two group results are added to produce the final sum.
//              The final sum is registered on the rising clock edge and forced to zero 
//              when reset or enable is low.
// 
// Dependencies: 
//  - DFF module (active-high synchronous reset and enable)
//  - hyd_mul16_4chain multiplier modules
//  - hyd_adr32 adder module (which uses ling_adder16_en and 
//    sparse_kogge_stone_adder_16_en internally)
// 
// Revision:
// Revision 0.05 - Updated delay elements to use enable logic.
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Filter_16tap #(parameter N = 16)(
    input clk, reset, enable,
    input [N-1:0] data_in,
    output reg [31:0] data_out  // Final result is 32 bits.
);

  //-------------------------------------------------------------------------
  // Coefficient definitions for an ECG low-pass optimized filter.
  // These symmetric coefficients provide a linear-phase response.
  //-------------------------------------------------------------------------
  wire [15:0] b0  = 16'h0003; 
  wire [15:0] b1  = 16'h0007; 
  wire [15:0] b2  = 16'h000C; 
  wire [15:0] b3  = 16'h0012;
  wire [15:0] b4  = 16'h0019;
  wire [15:0] b5  = 16'h0020;
  wire [15:0] b6  = 16'h0026;
  wire [15:0] b7  = 16'h002A;
  wire [15:0] b8  = 16'h002A;
  wire [15:0] b9  = 16'h0026;
  wire [15:0] b10 = 16'h0020;
  wire [15:0] b11 = 16'h0019;
  wire [15:0] b12 = 16'h0012;
  wire [15:0] b13 = 16'h000C;
  wire [15:0] b14 = 16'h0007;
  wire [15:0] b15 = 16'h0003;

  //-------------------------------------------------------------------------
  // Delay Elements: Instantiate DFFs for taps x[n-1] to x[n-15].
  // These store the previous input samples using the updated DFF with enable.
  //-------------------------------------------------------------------------
  wire [N-1:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15;

    DFF DFF0  (.clk(clk), .reset(reset), .enable(enable), .data_in(data_in), .data_delayed(x1));   // x[n-1]
    DFF DFF1  (.clk(clk), .reset(reset), .enable(enable), .data_in(x1),     .data_delayed(x2));   // x[n-2]
    DFF DFF2  (.clk(clk), .reset(reset), .enable(enable), .data_in(x2),     .data_delayed(x3));   // x[n-3]
    DFF DFF3  (.clk(clk), .reset(reset), .enable(enable), .data_in(x3),     .data_delayed(x4));   // x[n-4]
    DFF DFF4  (.clk(clk), .reset(reset), .enable(enable), .data_in(x4),     .data_delayed(x5));   // x[n-5]
    DFF DFF5  (.clk(clk), .reset(reset), .enable(enable), .data_in(x5),     .data_delayed(x6));   // x[n-6]
    DFF DFF6  (.clk(clk), .reset(reset), .enable(enable), .data_in(x6),     .data_delayed(x7));   // x[n-7]
    DFF DFF7  (.clk(clk), .reset(reset), .enable(enable), .data_in(x7),     .data_delayed(x8));   // x[n-8]
    DFF DFF8  (.clk(clk), .reset(reset), .enable(enable), .data_in(x8),     .data_delayed(x9));   // x[n-9]
    DFF DFF9  (.clk(clk), .reset(reset), .enable(enable), .data_in(x9),     .data_delayed(x10));  // x[n-10]
    DFF DFF10 (.clk(clk), .reset(reset), .enable(enable), .data_in(x10),    .data_delayed(x11));  // x[n-11]
    DFF DFF11 (.clk(clk), .reset(reset), .enable(enable), .data_in(x11),    .data_delayed(x12));  // x[n-12]
    DFF DFF12 (.clk(clk), .reset(reset), .enable(enable), .data_in(x12),    .data_delayed(x13));  // x[n-13]
    DFF DFF13 (.clk(clk), .reset(reset), .enable(enable), .data_in(x13),    .data_delayed(x14));  // x[n-14]
    DFF DFF14 (.clk(clk), .reset(reset), .enable(enable), .data_in(x14),    .data_delayed(x15));  // x[n-15]
    

  //-------------------------------------------------------------------------
  // Multiplication Stage: Each hyd_mul16_4chain multiplier produces a 32-bit product.
  // Mul0 corresponds to the product for the current sample, Mul1 for x1, etc.
  //-------------------------------------------------------------------------
  wire [31:0] Mul0, Mul1, Mul2, Mul3, Mul4, Mul5, Mul6,
              Mul7, Mul8, Mul9, Mul10, Mul11, Mul12, Mul13, Mul14, Mul15;

  hyd_mul16_4chain m0(
    .A(data_in),
    .B(b0),
    .en(enable),
    .Product(Mul0)
  );
  hyd_mul16_4chain m1(
    .A(x1),
    .B(b1),
    .en(enable),
    .Product(Mul1)
  );
  hyd_mul16_4chain m2(
    .A(x2),
    .B(b2),
    .en(enable),
    .Product(Mul2)
  );
  hyd_mul16_4chain m3(
    .A(x3),
    .B(b3),
    .en(enable),
    .Product(Mul3)
  );
  hyd_mul16_4chain m4(
    .A(x4),
    .B(b4),
    .en(enable),
    .Product(Mul4)
  );
  hyd_mul16_4chain m5(
    .A(x5),
    .B(b5),
    .en(enable),
    .Product(Mul5)
  );
  hyd_mul16_4chain m6(
    .A(x6),
    .B(b6),
    .en(enable),
    .Product(Mul6)
  );
  hyd_mul16_4chain m7(
    .A(x7),
    .B(b7),
    .en(enable),
    .Product(Mul7)
  );
  hyd_mul16_4chain m8(
    .A(x8),
    .B(b8),
    .en(enable),
    .Product(Mul8)
  );
  hyd_mul16_4chain m9(
    .A(x9),
    .B(b9),
    .en(enable),
    .Product(Mul9)
  );
  hyd_mul16_4chain m10(
    .A(x10),
    .B(b10),
    .en(enable),
    .Product(Mul10)
  );
  hyd_mul16_4chain m11(
    .A(x11),
    .B(b11),
    .en(enable),
    .Product(Mul11)
  );
  hyd_mul16_4chain m12(
    .A(x12),
    .B(b12),
    .en(enable),
    .Product(Mul12)
  );
  hyd_mul16_4chain m13(
    .A(x13),
    .B(b13),
    .en(enable),
    .Product(Mul13)
  );
  hyd_mul16_4chain m14(
    .A(x14),
    .B(b14),
    .en(enable),
    .Product(Mul14)
  );
  hyd_mul16_4chain m15(
    .A(x15),
    .B(b15),
    .en(enable),
    .Product(Mul15)
  );

  //======================================================================
  // Stage 1: 4 Chains of Partial Product Addition (Serial Addition)
  // Each chain adds 4 products serially.
  //======================================================================
  
  // Chain 1: Add Mul0, Mul1, Mul2, Mul3
  wire [31:0] chain1_0, chain1_1, chain1_final;
  wire [2:0]  chain1_cout;
  
  hyd_adr32 chain1_adder0 (
      .A(Mul0),
      .B(Mul1),
      .Cin(1'b0),
      .enable(enable),
      .Sum(chain1_0),
      .Cout(chain1_cout[0])
  );
  hyd_adr32 chain1_adder1 (
      .A(chain1_0),
      .B(Mul2),
      .Cin(chain1_cout[0]),
      .enable(enable),
      .Sum(chain1_1),
      .Cout(chain1_cout[1])
  );
  hyd_adr32 chain1_adder2 (
      .A(chain1_1),
      .B(Mul3),
      .Cin(chain1_cout[1]),
      .enable(enable),
      .Sum(chain1_final),
      .Cout(chain1_cout[2])
  );
  
  // Chain 2: Add Mul4, Mul5, Mul6, Mul7
  wire [31:0] chain2_0, chain2_1, chain2_final;
  wire [2:0]  chain2_cout;
  
  hyd_adr32 chain2_adder0 (
      .A(Mul4),
      .B(Mul5),
      .Cin(1'b0),
      .enable(enable),
      .Sum(chain2_0),
      .Cout(chain2_cout[0])
  );
  hyd_adr32 chain2_adder1 (
      .A(chain2_0),
      .B(Mul6),
      .Cin(chain2_cout[0]),
      .enable(enable),
      .Sum(chain2_1),
      .Cout(chain2_cout[1])
  );
  hyd_adr32 chain2_adder2 (
      .A(chain2_1),
      .B(Mul7),
      .Cin(chain2_cout[1]),
      .enable(enable),
      .Sum(chain2_final),
      .Cout(chain2_cout[2])
  );
  
  // Chain 3: Add Mul8, Mul9, Mul10, Mul11
  wire [31:0] chain3_0, chain3_1, chain3_final;
  wire [2:0]  chain3_cout;
  
  hyd_adr32 chain3_adder0 (
      .A(Mul8),
      .B(Mul9),
      .Cin(1'b0),
      .enable(enable),
      .Sum(chain3_0),
      .Cout(chain3_cout[0])
  );
  hyd_adr32 chain3_adder1 (
      .A(chain3_0),
      .B(Mul10),
      .Cin(chain3_cout[0]),
      .enable(enable),
      .Sum(chain3_1),
      .Cout(chain3_cout[1])
  );
  hyd_adr32 chain3_adder2 (
      .A(chain3_1),
      .B(Mul11),
      .Cin(chain3_cout[1]),
      .enable(enable),
      .Sum(chain3_final),
      .Cout(chain3_cout[2])
  );
  
  // Chain 4: Add Mul12, Mul13, Mul14, Mul15
  wire [31:0] chain4_0, chain4_1, chain4_final;
  wire [2:0]  chain4_cout;
  
  hyd_adr32 chain4_adder0 (
      .A(Mul12),
      .B(Mul13),
      .Cin(1'b0),
      .enable(enable),
      .Sum(chain4_0),
      .Cout(chain4_cout[0])
  );
  hyd_adr32 chain4_adder1 (
      .A(chain4_0),
      .B(Mul14),
      .Cin(chain4_cout[0]),
      .enable(enable),
      .Sum(chain4_1),
      .Cout(chain4_cout[1])
  );
  hyd_adr32 chain4_adder2 (
      .A(chain4_1),
      .B(Mul15),
      .Cin(chain4_cout[1]),
      .enable(enable),
      .Sum(chain4_final),
      .Cout(chain4_cout[2])
  );
  
  //======================================================================
  // Stage 2: Combine the 4 chain results in 2 groups.
  // Group 1: Chain 1 final + Chain 2 final.
  // Group 2: Chain 3 final + Chain 4 final.
  //======================================================================
  wire [31:0] group1, group2;
  
  hyd_adr32 group_adder0 (
      .A(chain1_final),
      .B(chain2_final),
      .Cin(1'b0),
      .enable(enable),
      .Sum(group1),
      .Cout()  // Carry-out not used
  );
  
  hyd_adr32 group_adder1 (
      .A(chain3_final),
      .B(chain4_final),
      .Cin(1'b0),
      .enable(enable),
      .Sum(group2),
      .Cout()  // Carry-out not used
  );
  
  //======================================================================
  // Stage 3: Final Adder: Combine group results.
  //======================================================================
  wire [31:0] final_sum;
  hyd_adr32 final_adder (
      .A(group1),
      .B(group2),
      .Cin(1'b0),
      .enable(enable),
      .Sum(final_sum),
      .Cout()  // Not used
  );
  
  //-------------------------------------------------------------------------
  // Final Output Stage:
  // The final sum is registered on the rising edge.
  // If reset or enable is low, output is forced to zero.
  //-------------------------------------------------------------------------
  always @(posedge clk) begin
      if (reset || !enable)
          data_out <= 32'd0;
      else
          data_out <= final_sum;
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//delay unit


module DFF #(parameter N = 16)(    
    input clk, reset, enable,
    input [N-1:0] data_in,
    output [N-1:0] data_delayed
);
    reg [N-1:0] Q_reg;
    
    // Active-high synchronous reset and enable logic
    always @(posedge clk) begin
        if (reset || !enable)
            Q_reg <= {N{1'b0}}; // Reset or disable forces output to zero
        else
            Q_reg <= data_in;
    end
    
    // Output logic
    assign data_delayed = Q_reg;
endmodule



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//multiplier unit



module hyd_mul16_4chain(
    input  [15:0] A,      // 16-bit multiplicand
    input  [15:0] B,      // 16-bit multiplier
    input         en,     // Enable signal
    output [31:0] Product // 32-bit product output
);
    //======================================================================
    // Stage 0: Partial Product Generation (with shifting)
    // Each partial product is generated as:
    //    PPi = {16'b0, (A & {16{B[i]}})} << i
    reg [31:0] PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7;
    reg [31:0] PP8, PP9, PP10, PP11, PP12, PP13, PP14, PP15;
    
    always @(*) begin
        if (en) begin
            PP0  = {16'b0, (A & {16{B[0]}})}  << 0;
            PP1  = {16'b0, (A & {16{B[1]}})}  << 1;
            PP2  = {16'b0, (A & {16{B[2]}})}  << 2;
            PP3  = {16'b0, (A & {16{B[3]}})}  << 3;
            PP4  = {16'b0, (A & {16{B[4]}})}  << 4;
            PP5  = {16'b0, (A & {16{B[5]}})}  << 5;
            PP6  = {16'b0, (A & {16{B[6]}})}  << 6;
            PP7  = {16'b0, (A & {16{B[7]}})}  << 7;
            PP8  = {16'b0, (A & {16{B[8]}})}  << 8;
            PP9  = {16'b0, (A & {16{B[9]}})}  << 9;
            PP10 = {16'b0, (A & {16{B[10]}})} << 10;
            PP11 = {16'b0, (A & {16{B[11]}})} << 11;
            PP12 = {16'b0, (A & {16{B[12]}})} << 12;
            PP13 = {16'b0, (A & {16{B[13]}})} << 13;
            PP14 = {16'b0, (A & {16{B[14]}})} << 14;
            PP15 = {16'b0, (A & {16{B[15]}})} << 15;
        end else begin
            PP0  = 32'b0; PP1  = 32'b0; PP2  = 32'b0; PP3  = 32'b0;
            PP4  = 32'b0; PP5  = 32'b0; PP6  = 32'b0; PP7  = 32'b0;
            PP8  = 32'b0; PP9  = 32'b0; PP10 = 32'b0; PP11 = 32'b0;
            PP12 = 32'b0; PP13 = 32'b0; PP14 = 32'b0; PP15 = 32'b0;
        end
    end
    
    //======================================================================
    // Stage 1: 4 Chains of Partial Product Addition
    // Each chain adds 4 partial products serially.
    //======================================================================
    
    // ----- Chain 1: PP0, PP1, PP2, PP3 -----
    wire [31:0] chain1_0, chain1_1, chain1_final;
    wire [2:0]  chain1_cout;
    
    hyd_adr32 chain1_adder0 (
        .A(PP0),
        .B(PP1),
        .Cin(1'b0),
        .enable(en),
        .Sum(chain1_0),
        .Cout(chain1_cout[0])
    );
    hyd_adr32 chain1_adder1 (
        .A(chain1_0),
        .B(PP2),
        .Cin(chain1_cout[0]),
        .enable(en),
        .Sum(chain1_1),
        .Cout(chain1_cout[1])
    );
    hyd_adr32 chain1_adder2 (
        .A(chain1_1),
        .B(PP3),
        .Cin(chain1_cout[1]),
        .enable(en),
        .Sum(chain1_final),
        .Cout(chain1_cout[2])
    );
    
    // ----- Chain 2: PP4, PP5, PP6, PP7 -----
    wire [31:0] chain2_0, chain2_1, chain2_final;
    wire [2:0]  chain2_cout;
    
    hyd_adr32 chain2_adder0 (
        .A(PP4),
        .B(PP5),
        .Cin(1'b0),
        .enable(en),
        .Sum(chain2_0),
        .Cout(chain2_cout[0])
    );
    hyd_adr32 chain2_adder1 (
        .A(chain2_0),
        .B(PP6),
        .Cin(chain2_cout[0]),
        .enable(en),
        .Sum(chain2_1),
        .Cout(chain2_cout[1])
    );
    hyd_adr32 chain2_adder2 (
        .A(chain2_1),
        .B(PP7),
        .Cin(chain2_cout[1]),
        .enable(en),
        .Sum(chain2_final),
        .Cout(chain2_cout[2])
    );
    
    // ----- Chain 3: PP8, PP9, PP10, PP11 -----
    wire [31:0] chain3_0, chain3_1, chain3_final;
    wire [2:0]  chain3_cout;
    
    hyd_adr32 chain3_adder0 (
        .A(PP8),
        .B(PP9),
        .Cin(1'b0),
        .enable(en),
        .Sum(chain3_0),
        .Cout(chain3_cout[0])
    );
    hyd_adr32 chain3_adder1 (
        .A(chain3_0),
        .B(PP10),
        .Cin(chain3_cout[0]),
        .enable(en),
        .Sum(chain3_1),
        .Cout(chain3_cout[1])
    );
    hyd_adr32 chain3_adder2 (
        .A(chain3_1),
        .B(PP11),
        .Cin(chain3_cout[1]),
        .enable(en),
        .Sum(chain3_final),
        .Cout(chain3_cout[2])
    );
    
    // ----- Chain 4: PP12, PP13, PP14, PP15 -----
    wire [31:0] chain4_0, chain4_1, chain4_final;
    wire [2:0]  chain4_cout;
    
    hyd_adr32 chain4_adder0 (
        .A(PP12),
        .B(PP13),
        .Cin(1'b0),
        .enable(en),
        .Sum(chain4_0),
        .Cout(chain4_cout[0])
    );
    hyd_adr32 chain4_adder1 (
        .A(chain4_0),
        .B(PP14),
        .Cin(chain4_cout[0]),
        .enable(en),
        .Sum(chain4_1),
        .Cout(chain4_cout[1])
    );
    hyd_adr32 chain4_adder2 (
        .A(chain4_1),
        .B(PP15),
        .Cin(chain4_cout[1]),
        .enable(en),
        .Sum(chain4_final),
        .Cout(chain4_cout[2])
    );
    
    //======================================================================
    // Stage 2: Combine the 4 chain results in two groups
    // Group 1: Chain 1 final + Chain 2 final
    // Group 2: Chain 3 final + Chain 4 final
    //======================================================================
    wire [31:0] group1, group2;
    hyd_adr32 group_adder0 (
        .A(chain1_final),
        .B(chain2_final),
        .Cin(1'b0),
        .enable(en),
        .Sum(group1),
        .Cout()
    );
    hyd_adr32 group_adder1 (
        .A(chain3_final),
        .B(chain4_final),
        .Cin(1'b0),
        .enable(en),
        .Sum(group2),
        .Cout()
    );
    
    //======================================================================
    // Stage 3: Final Adder to combine group results
    //======================================================================
    wire [31:0] final_sum;
    hyd_adr32 final_adder (
        .A(group1),
        .B(group2),
        .Cin(1'b0),
        .enable(en),
        .Sum(final_sum),
        .Cout()
    );
    
    // Final Output: if en is low, output zero; otherwise, output final_sum
    assign Product = (en ? final_sum : 32'b0);
    
endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Adder unit


module hyd_adr32 (
    input  [31:0] A,         // 32-bit operand A
    input  [31:0] B,         // 32-bit operand B
    input         Cin,       // Overall carry-in
    input         enable,    // Global enable (or power gating) signal
    output [31:0] Sum,       // 32-bit sum output
    output        Cout       // Overall carry-out
);

    //--------------------------------------------------------------------------
    // Split the 32-bit operands into lower and upper 16-bit halves.
    //--------------------------------------------------------------------------
    wire [15:0] A_low, A_high;
    wire [15:0] B_low, B_high;
    
    assign A_low  = A[15:0];
    assign A_high = A[31:16];
    assign B_low  = B[15:0];
    assign B_high = B[31:16];
    
    //--------------------------------------------------------------------------
    // Wires for each 16-bit block.
    //--------------------------------------------------------------------------
    wire [15:0] Sum_low, Sum_high;
    wire        Cout_low, Cout_high;
    
    //--------------------------------------------------------------------------
    // Lower 16-bit adder using a Ling architecture.
    // Ling adders are known for having reduced logic levels (lower delay/power).
    // The enable signal is passed directly to the Ling adder.
    //--------------------------------------------------------------------------
     ling_adder16_en lower_adder (
        .A(A_low),
        .B(B_low),
        .Cin(Cin),
        .enable(enable),
        .Sum(Sum_low),
        .CarryOut(Cout_low)
    );
    
   
    sparse_kogge_stone_adder_16_en upper_adder (
        .a(A_high),
        .b(B_high),
        .cin(Cout_low),
        .enable(enable),
        .sum(Sum_high),
        .cout(Cout_high)
    );
    
    //--------------------------------------------------------------------------
    // Combine the two halves into a 32-bit result.
    // First, combine the two halves into internal wires.
    //--------------------------------------------------------------------------
    wire [31:0] combined_sum;
    wire        combined_cout;
    
    assign combined_sum  = {Sum_high, Sum_low};
    assign combined_cout = Cout_high;
    
    //--------------------------------------------------------------------------
    // Use an always block to drive the final outputs based on the enable signal.
    // If enable is high, the outputs reflect the combined result.
    // Otherwise, the outputs are forced to zero.
    //--------------------------------------------------------------------------
    reg [31:0] out_Sum;
    reg        out_Cout;
    always @(*) begin
        if (enable) begin
            out_Sum  = combined_sum;
            out_Cout = combined_cout;
        end else begin
            out_Sum  = 32'd0;
            out_Cout = 1'b0;
        end
    end
    
    assign Sum  = out_Sum;
    assign Cout = out_Cout;

endmodule


///////////////////////////////////////////////ling16

module  ling_adder16_en (
    input  [15:0] A,       // Input operand A
    input  [15:0] B,       // Input operand B
    input         Cin,     // Carry-in input
    input         enable,  // Active-high enable signal
    output [15:0] Sum,     // Sum output
    output        CarryOut // Final carry output
);

    // Internal wires for propagate, generate, and Ling carry signals
    wire [15:0] P;  // Propagate signals: P[i] = A[i] XOR B[i]
    wire [15:0] G;  // Generate signals:  G[i] = A[i] AND B[i]
    wire [15:0] H;  // Ling carry signals

    // Compute propagate and generate signals.
    assign P = A ^ B;
    assign G = A & B;

    // Compute Ling carry signals explicitly.
    // Each Ling carry is computed as: H[i] = G[i] OR (P[i] AND H[i-1]),
    // with H[0] including the external carry Cin.
    assign H[0]  = G[0]  | (P[0]  & Cin);
    assign H[1]  = G[1]  | (P[1]  & H[0]);
    assign H[2]  = G[2]  | (P[2]  & H[1]);
    assign H[3]  = G[3]  | (P[3]  & H[2]);
    assign H[4]  = G[4]  | (P[4]  & H[3]);
    assign H[5]  = G[5]  | (P[5]  & H[4]);
    assign H[6]  = G[6]  | (P[6]  & H[5]);
    assign H[7]  = G[7]  | (P[7]  & H[6]);
    assign H[8]  = G[8]  | (P[8]  & H[7]);
    assign H[9]  = G[9]  | (P[9]  & H[8]);
    assign H[10] = G[10] | (P[10] & H[9]);
    assign H[11] = G[11] | (P[11] & H[10]);
    assign H[12] = G[12] | (P[12] & H[11]);
    assign H[13] = G[13] | (P[13] & H[12]);
    assign H[14] = G[14] | (P[14] & H[13]);
    assign H[15] = G[15] | (P[15] & H[14]);

    // Compute the internal sum bits.
    // Each sum bit is given by: Sum[i] = P[i] XOR (carry into bit i)
    // where for bit 0 the carry is Cin, and for bit i (i>0) it is H[i-1].
    wire [15:0] computed_sum;
    assign computed_sum[0]  = P[0]  ^ Cin;
    assign computed_sum[1]  = P[1]  ^ H[0];
    assign computed_sum[2]  = P[2]  ^ H[1];
    assign computed_sum[3]  = P[3]  ^ H[2];
    assign computed_sum[4]  = P[4]  ^ H[3];
    assign computed_sum[5]  = P[5]  ^ H[4];
    assign computed_sum[6]  = P[6]  ^ H[5];
    assign computed_sum[7]  = P[7]  ^ H[6];
    assign computed_sum[8]  = P[8]  ^ H[7];
    assign computed_sum[9]  = P[9]  ^ H[8];
    assign computed_sum[10] = P[10] ^ H[9];
    assign computed_sum[11] = P[11] ^ H[10];
    assign computed_sum[12] = P[12] ^ H[11];
    assign computed_sum[13] = P[13] ^ H[12];
    assign computed_sum[14] = P[14] ^ H[13];
    assign computed_sum[15] = P[15] ^ H[14];

    // The final Ling carry H[15] becomes the adder's carry-out.
    wire computed_carry;
    assign computed_carry = H[15];

    // Final output registers
    reg [15:0] out_sum;
    reg        out_carry;

    // Use an always block with if-else to drive the outputs based on enable.
    always @(*) begin
        if (enable) begin
            out_sum  = computed_sum;
            out_carry = computed_carry;
        end
        else begin
            out_sum  = 16'd0;
            out_carry = 1'b0;
        end
    end

    // Connect the final outputs.
    assign Sum      = out_sum;
    assign CarryOut = out_carry;

endmodule


///////////////////////////////////////////////////////sksa16



module sparse_kogge_stone_adder_16_en (
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    input         enable,
    output [15:0] sum,
    output        cout
);

// Precompute Generate (G) and Propagate (P) signals
  wire [15:0] g0, p0;
  assign g0 = a & b;
  assign p0 = a ^ b;

  // Stage 1: Span 1
  wire [15:0] g1, p1;
  assign g1[0] = g0[0] | (p0[0] & cin);
  assign p1[0] = p0[0];
  assign g1[1] = g0[1] | (p0[1] & g1[0]);
  assign p1[1] = p0[1] & p1[0];
  assign g1[2] = g0[2] | (p0[2] & g1[1]);
  assign p1[2] = p0[2] & p1[1];
  assign g1[3] = g0[3] | (p0[3] & g1[2]);
  assign p1[3] = p0[3] & p1[2];
  assign g1[4] = g0[4] | (p0[4] & g1[3]);
  assign p1[4] = p0[4] & p1[3];
  assign g1[5] = g0[5] | (p0[5] & g1[4]);
  assign p1[5] = p0[5] & p1[4];
  assign g1[6] = g0[6] | (p0[6] & g1[5]);
  assign p1[6] = p0[6] & p1[5];
  assign g1[7] = g0[7] | (p0[7] & g1[6]);
  assign p1[7] = p0[7] & p1[6];
  assign g1[8] = g0[8] | (p0[8] & g1[7]);
  assign p1[8] = p0[8] & p1[7];
  assign g1[9] = g0[9] | (p0[9] & g1[8]);
  assign p1[9] = p0[9] & p1[8];
  assign g1[10] = g0[10] | (p0[10] & g1[9]);
  assign p1[10] = p0[10] & p1[9];
  assign g1[11] = g0[11] | (p0[11] & g1[10]);
  assign p1[11] = p0[11] & p1[10];
  assign g1[12] = g0[12] | (p0[12] & g1[11]);
  assign p1[12] = p0[12] & p1[11];
  assign g1[13] = g0[13] | (p0[13] & g1[12]);
  assign p1[13] = p0[13] & p1[12];
  assign g1[14] = g0[14] | (p0[14] & g1[13]);
  assign p1[14] = p0[14] & p1[13];
  assign g1[15] = g0[15] | (p0[15] & g1[14]);
  assign p1[15] = p0[15] & p1[14];

  // Stage 2: Span 2
  wire [15:0] g2, p2;
  assign g2[0]  = g1[0];  assign p2[0]  = p1[0];
  assign g2[1]  = g1[1];  assign p2[1]  = p1[1];
  assign g2[2]  = g1[2]  | (p1[2]  & g1[0]);
  assign p2[2]  = p1[2]  & p1[0];
  assign g2[3]  = g1[3]  | (p1[3]  & g1[1]);
  assign p2[3]  = p1[3]  & p1[1];
  assign g2[4]  = g1[4]  | (p1[4]  & g1[2]);
  assign p2[4]  = p1[4]  & p1[2];
  assign g2[5]  = g1[5]  | (p1[5]  & g1[3]);
  assign p2[5]  = p1[5]  & p1[3];
  assign g2[6]  = g1[6]  | (p1[6]  & g1[4]);
  assign p2[6]  = p1[6]  & p1[4];
  assign g2[7]  = g1[7]  | (p1[7]  & g1[5]);
  assign p2[7]  = p1[7]  & p1[5];
  assign g2[8]  = g1[8]  | (p1[8]  & g1[6]);
  assign p2[8]  = p1[8]  & p1[6];
  assign g2[9]  = g1[9]  | (p1[9]  & g1[7]);
  assign p2[9]  = p1[9]  & p1[7];
  assign g2[10] = g1[10] | (p1[10] & g1[8]);
  assign p2[10] = p1[10] & p1[8];
  assign g2[11] = g1[11] | (p1[11] & g1[9]);
  assign p2[11] = p1[11] & p1[9];
  assign g2[12] = g1[12] | (p1[12] & g1[10]);
  assign p2[12] = p1[12] & p1[10];
  assign g2[13] = g1[13] | (p1[13] & g1[11]);
  assign p2[13] = p1[13] & p1[11];
  assign g2[14] = g1[14] | (p1[14] & g1[12]);
  assign p2[14] = p1[14] & p1[12];
  assign g2[15] = g1[15] | (p1[15] & g1[13]);
  assign p2[15] = p1[15] & p1[13];

  // Stage 3: Span 4
  wire [15:0] g3, p3;
  assign g3[0]  = g2[0];  assign p3[0]  = p2[0];
  assign g3[1]  = g2[1];  assign p3[1]  = p2[1];
  assign g3[2]  = g2[2];  assign p3[2]  = p2[2];
  assign g3[3]  = g2[3];  assign p3[3]  = p2[3];
  assign g3[4]  = g2[4]  | (p2[4]  & g2[0]);
  assign p3[4]  = p2[4]  & p2[0];
  assign g3[5]  = g2[5]  | (p2[5]  & g2[1]);
  assign p3[5]  = p2[5]  & p2[1];
  assign g3[6]  = g2[6]  | (p2[6]  & g2[2]);
  assign p3[6]  = p2[6]  & p2[2];
  assign g3[7]  = g2[7]  | (p2[7]  & g2[3]);
  assign p3[7]  = p2[7]  & p2[3];
  assign g3[8]  = g2[8]  | (p2[8]  & g2[4]);
  assign p3[8]  = p2[8]  & p2[4];
  assign g3[9]  = g2[9]  | (p2[9]  & g2[5]);
  assign p3[9]  = p2[9]  & p2[5];
  assign g3[10] = g2[10] | (p2[10] & g2[6]);
  assign p3[10] = p2[10] & p2[6];
  assign g3[11] = g2[11] | (p2[11] & g2[7]);
  assign p3[11] = p2[11] & p2[7];
  assign g3[12] = g2[12] | (p2[12] & g2[8]);
  assign p3[12] = p2[12] & p2[8];
  assign g3[13] = g2[13] | (p2[13] & g2[9]);
  assign p3[13] = p2[13] & p2[9];
  assign g3[14] = g2[14] | (p2[14] & g2[10]);
  assign p3[14] = p2[14] & p2[10];
  assign g3[15] = g2[15] | (p2[15] & g2[11]);
  assign p3[15] = p2[15] & p2[11];

  // Stage 4: Span 8
  wire [15:0] g4, p4;
  assign g4[0]  = g3[0];  assign p4[0]  = p3[0];
  assign g4[1]  = g3[1];  assign p4[1]  = p3[1];
  assign g4[2]  = g3[2];  assign p4[2]  = p3[2];
  assign g4[3]  = g3[3];  assign p4[3]  = p3[3];
  assign g4[4]  = g3[4];  assign p4[4]  = p3[4];
  assign g4[5]  = g3[5];  assign p4[5]  = p3[5];
  assign g4[6]  = g3[6];  assign p4[6]  = p3[6];
  assign g4[7]  = g3[7];  assign p4[7]  = p3[7];
  assign g4[8]  = g3[8]  | (p3[8]  & g3[0]);
  assign p4[8]  = p3[8]  & p3[0];
  assign g4[9]  = g3[9]  | (p3[9]  & g3[1]);
  assign p4[9]  = p3[9]  & p3[1];
  assign g4[10] = g3[10] | (p3[10] & g3[2]);
  assign p4[10] = p3[10] & p3[2];
  assign g4[11] = g3[11] | (p3[11] & g3[3]);
  assign p4[11] = p3[11] & p3[3];
  assign g4[12] = g3[12] | (p3[12] & g3[4]);
  assign p4[12] = p3[12] & p3[4];
  assign g4[13] = g3[13] | (p3[13] & g3[5]);
  assign p4[13] = p3[13] & p3[5];
  assign g4[14] = g3[14] | (p3[14] & g3[6]);
  assign p4[14] = p3[14] & p3[6];
  assign g4[15] = g3[15] | (p3[15] & g3[7]);
  assign p4[15] = p3[15] & p3[7];

  // Compute Sum and Carry-out.
  wire [15:0] computed_sum;
  wire computed_out;

  // The carry into bit i is g4[i-1] (with c0 = cin) and cout = g4[15].
  assign computed_sum[0]  = p0[0] ^ cin;
  assign computed_sum[1]  = p0[1] ^ g4[0];
  assign computed_sum[2]  = p0[2] ^ g4[1];
  assign computed_sum[3]  = p0[3] ^ g4[2];
  assign computed_sum[4]  = p0[4] ^ g4[3];
  assign computed_sum[5]  = p0[5] ^ g4[4];
  assign computed_sum[6]  = p0[6] ^ g4[5];
  assign computed_sum[7]  = p0[7] ^ g4[6];
  assign computed_sum[8]  = p0[8] ^ g4[7];
  assign computed_sum[9]  = p0[9] ^ g4[8];
  assign computed_sum[10] = p0[10] ^ g4[9];
  assign computed_sum[11] = p0[11] ^ g4[10];
  assign computed_sum[12] = p0[12] ^ g4[11];
  assign computed_sum[13] = p0[13] ^ g4[12];
  assign computed_sum[14] = p0[14] ^ g4[13];
  assign computed_sum[15] = p0[15] ^ g4[14];
  assign computed_cout    = g4[15];

  reg [15:0] out_sum;
  reg        out_cout;

  always @(*) begin
    if (enable) begin
      out_sum  = computed_sum;
      out_cout = computed_cout;
    end
    else begin
      out_sum  = 16'd0;
      out_cout = 1'b0;
    end
  end

  assign sum  = out_sum;
  assign cout = out_cout;


endmodule