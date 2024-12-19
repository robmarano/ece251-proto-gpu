`ifndef SIMPLE_GPU
`define SIMPLE_GPU

`include "memory_controller.sv"

// ISA
// `[31:28]  [27:24]  [23:20]  [19:16]  [15:12]  [11:0]`
// 16 registers each of 32 bits

// | Bits    | Description |
// | ------- | ----------- |
// | [31:28] | Opcode      |
// | [27:24] | Src Reg1    |
// | [23:20] | Src Reg2    |
// | [19:16] | Dest Reg    |
// | [15:12] | (optional)  |
// | [11:0]  | (unused)    |

module simple_gpu (
  input clk,
  input rst,
  input [31:0] instruction,
  input [31:0] data_in,
  output reg [31:0] result,
  // External memory interface
  output reg [15:0] mem_addr,  // Address for external memory
  output reg mem_write_en,     // Write enable signal for external memory
  output reg [31:0] mem_write_data, // Data to write to external memory
  input [31:0] mem_read_data,  // Data read from external memory
  output reg [31:0] register_file [0:15] // Output register file
);

  // Register File
  // reg [31:0] register_file [0:15]; // 16 registers each of 32 bits

  // Internal registers
  reg [31:0] A;
  reg [31:0] B;
  reg [31:0] C;
  // reg [31:0] result;
  reg [15:0] addr_reg; // Register to hold memory address
  // reg write_en_reg;   // Register to hold write enable signal
  // Internal signal for mem_write_data
  // reg [31:0] mem_write_data_reg;

  // External memory interface connections
  // assign mem_addr = addr_reg;
  // assign mem_write_en = write_en_reg;
  // // Assign the internal register to the output port
  // assign mem_write_data = mem_write_data_reg;
  // Assign the register file to the output ports
  // assign registers = register_file; 

  // Output
  // assign data_out = result;

  // Control unit
  always @(posedge clk) begin
    if (rst) begin
      A <= 0;
      B <= 0;
      C <= 0;
      result <= 0;
      addr_reg <= 0;
      mem_write_en <= 0;
      // Initialize register file (optional)
      for (int i = 0; i < 16; i++) begin
        register_file[i] = 32'b0;
      end
    end
    else begin
      case (instruction[31:28]) // opcode
        4'b0001: begin // ADD
          $display("ADD instruction: %h", instruction);
          A <= register_file[instruction[27:24]]; // Read from register
          B <= register_file[instruction[23:20]]; // Read from register
          result <= A + B;
          register_file[instruction[19:16]] <= result; // Write result to register
        end
        4'b0010: begin // SUB
          $display("SUB instruction: %h", instruction);
          A <= register_file[instruction[27:24]]; // Read from register
          B <= register_file[instruction[23:20]]; // Read from register
          result <= A - B;
          register_file[instruction[19:16]] <= result; // Write result to register
        end
        4'b0011: begin // MUL
          $display("MUL instruction: %h", instruction);
          A <= register_file[instruction[27:24]]; // Read from register
          B <= register_file[instruction[23:20]]; // Read from register
          result <= A * B;
          register_file[instruction[19:16]] <= result; // Write result to register
        end
        4'b0100: begin // LOAD from memory to register
          $display("LOAD instruction: %h", instruction);
          addr_reg <= instruction[27:16]; // Load address
          mem_write_en <= 0; // Disable write to memory
          register_file[instruction[15:12]] <= mem_read_data; // Write data to register
        end
        4'b0101: begin // STORE from register to memory
          $display("STORE instruction: %h", instruction);
          addr_reg <= instruction[27:16]; // Store address
          mem_write_en <= 1; // Enable write to memory
          mem_write_data <= register_file[instruction[15:12]]; // Data to be stored (assigned below) 
        end
        4'b1001: begin // ADD immediate
          $display("ADD immediate instruction: %h", instruction);
          A <= register_file[instruction[23:20]]; // Read from register
          B <= instruction[19:0]; // Read immediate value
          result <= A + B;
          register_file[instruction[27:24]] <= result; // Write result to register
        end
        default: begin // For other instructions or no-op
          addr_reg <= 0; 
          mem_write_en <= 0;
        end
      endcase

      // Assign mem_write_data after reading from register file in STORE operation
      if (instruction[31:28] == 4'b0101) begin 
        mem_write_data <= register_file[instruction[15:12]];
      end
      if (instruction[31:28] == 4'b1001) begin 
        mem_write_data <= register_file[instruction[15:12]];
      end
    end
  end

endmodule

`endif // SIMPLE_GPU