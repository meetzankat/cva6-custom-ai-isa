// Vector Functional Unit for Custom AI Instructions
// VDOT/VRELU/VGELU - no package dependencies
// funct7_i[1:0]: 00=VDOT, 01=VRELU, 10=VGELU
module vec_fu (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [63:0] operand_a_i,
    input  logic [63:0] operand_b_i,
    input  logic [6:0]  funct7_i,
    output logic [63:0] result_o,
    output logic        valid_o
);
  logic signed [7:0]  a_bytes [0:7];
  logic signed [7:0]  b_bytes [0:7];
  logic signed [15:0] products [0:7];
  logic signed [63:0] dot_sum;
  genvar i;
  generate
    for (i = 0; i < 8; i++) begin : gen_dot
      assign a_bytes[i]  = operand_a_i[8*i+7:8*i];
      assign b_bytes[i]  = operand_b_i[8*i+7:8*i];
      assign products[i] = a_bytes[i] * b_bytes[i];
    end
  endgenerate
  assign dot_sum = $signed(products[0]) + $signed(products[1]) +
                   $signed(products[2]) + $signed(products[3]) +
                   $signed(products[4]) + $signed(products[5]) +
                   $signed(products[6]) + $signed(products[7]);
  logic [63:0] vrelu_result;
  generate
    for (i = 0; i < 8; i++) begin : gen_relu
      assign vrelu_result[8*i+7:8*i] = operand_a_i[8*i+7] ? 8'h00 : operand_a_i[8*i+7:8*i];
    end
  endgenerate
  logic [63:0] vgelu_result;
  generate
    for (i = 0; i < 8; i++) begin : gen_gelu
      logic [7:0] r;
      assign r = operand_a_i[8*i+7] ? 8'h00 : operand_a_i[8*i+7:8*i];
      assign vgelu_result[8*i+7:8*i] = r - (r >> 3);
    end
  endgenerate
  always_comb begin
    case (funct7_i[1:0])
      2'b00:   result_o = dot_sum[63:0];
      2'b01:   result_o = vrelu_result;
      2'b10:   result_o = vgelu_result;
      default: result_o = '0;
    endcase
  end
  assign valid_o = 1'b1;
endmodule
