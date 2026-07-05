// Vector Functional Unit for Custom AI Instructions
// Supports: VDOT, VRELU, VGELU
module vec_fu #(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,
    parameter type fu_data_t = logic
) (
    input  logic                        clk_i,
    input  logic                        rst_ni,
    input  logic [CVA6Cfg.XLEN-1:0]    operand_a_i,
    input  logic [CVA6Cfg.XLEN-1:0]    operand_b_i,
    input  ariane_pkg::fu_op           operation_i,
    output logic [CVA6Cfg.XLEN-1:0]    result_o,
    output logic                        valid_o
);

  // VDOT: 8x signed INT8 dot product
  logic signed [7:0]  a_bytes [0:7];
  logic signed [7:0]  b_bytes [0:7];
  logic signed [15:0] products [0:7];
  logic signed [63:0] dot_sum;

  genvar i;
  generate
    for (i = 0; i < 8; i++) begin : gen_dot
      assign a_bytes[i]  = operand_a_i[8*i+7 : 8*i];
      assign b_bytes[i]  = operand_b_i[8*i+7 : 8*i];
      assign products[i] = a_bytes[i] * b_bytes[i];
    end
  endgenerate

  assign dot_sum = $signed(products[0]) + $signed(products[1]) +
                   $signed(products[2]) + $signed(products[3]) +
                   $signed(products[4]) + $signed(products[5]) +
                   $signed(products[6]) + $signed(products[7]);

  // VRELU: max(0, x) per signed byte
  logic [CVA6Cfg.XLEN-1:0] vrelu_result;
  generate
    for (i = 0; i < 8; i++) begin : gen_relu
      assign vrelu_result[8*i+7:8*i] = operand_a_i[8*i+7] ? 8'h00 : operand_a_i[8*i+7:8*i];
    end
  endgenerate

  // VGELU: gelu(x) ≈ relu(x) - relu(x)>>3 per byte
  logic [CVA6Cfg.XLEN-1:0] vgelu_result;
  generate
    for (i = 0; i < 8; i++) begin : gen_gelu
      logic [7:0] r;
      assign r = operand_a_i[8*i+7] ? 8'h00 : operand_a_i[8*i+7:8*i];
      assign vgelu_result[8*i+7:8*i] = r - (r >> 3);
    end
  endgenerate

  // Output mux
  always_comb begin
    result_o = '0;
    unique case (operation_i)
      ariane_pkg::VDOT:  result_o = dot_sum[CVA6Cfg.XLEN-1:0];
      ariane_pkg::VRELU: result_o = vrelu_result;
      ariane_pkg::VGELU: result_o = vgelu_result;
      default:           result_o = '0;
    endcase
  end

  assign valid_o = 1'b1;

endmodule
