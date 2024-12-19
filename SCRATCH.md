`simple_gpu.sv`

```verilog
module simple_gpu (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    output reg [31:0] output_data,
    output reg [31:0] memory [0:255]
);
    // Internal registers
    reg [31:0] result;

    // Initialize memory
    initial begin
        for (int i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // ...existing code...
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 32'b0;
        end else begin
            case (opcode)
                4'b0001: result <= operand1 + operand2; // ADD
                4'b0010: result <= operand1 - operand2; // SUB
                4'b0011: result <= operand1 * operand2; // MUL
                4'b0100: result <= memory[operand1];    // LOAD
                4'b0101: memory[operand1] <= operand2;  // STORE
                default: result <= 32'b0;
            endcase
        end
    end

    // Output
    assign output_data = result;
endmodule
```

`tb_simple_gpu.sv` segments

```verilog
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        opcode = 4'b0000;
        operand1 = 32'b0;
        operand2 = 32'b0;
        #10 reset = 0;

        operand1 = 32'd201;
        $display("%b\t%b\t%0.4d\t%0.4d",operand1,operand1, operand1, operand1);

        // Test ADD
        $display("ADD OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        #10 opcode = 4'b0001; operand1 = 32'd10; operand2 = 32'd20;
        #10 $display("ADD Result: %d", result);

        // Test SUB
        $display("SUB OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        #10 opcode = 4'b0010; operand1 = 32'd20; operand2 = 32'd10;
        #10 $display("SUB Result: %d", result);

        // Test MUL
        $display("MUL OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        #10 opcode = 4'b0011; operand1 = 32'd5; operand2 = 32'd4;
        #10 $display("MUL Result: %d", result);

        // Test LOAD
        $display("LOAD OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        #10 opcode = 4'b0100; operand1 = 32'd0; memory[0] = 32'd100;
        #10 $display("LOAD Result: %d", result);

        // Test STORE
        $display("STORE OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        #10 opcode = 4'b0101; operand1 = 0; operand2 = 3; //32'd1
        #10 $display("STORE Result: Memory[%d] is %d", operand1, memory[operand2]);

        // Print memory contents
        $display("Memory Contents:");
        for (int i = 0; i < 256; i = i + 1) begin
            if (memory[i] !== 32'bx) begin
                $display("Memory[%d] = %d", i, memory[i]);
            end
        end

        $finish;
    end
```

`simple_gpu.sv`

````verilog
`ifndef SIMPLE_GPU
`define SIMPLE_GPU

`include "memory_controller.sv"

module simple_gpu (
  input clk,
  input rst,
  input [31:0] instruction,
  output [31:0] data_out,
  output [15:0] mem_addr,  // Address for external memory
  output mem_write_en,     // Write enable signal for external memory
  output [31:0] mem_write_data, // Data to write to external memory
  input [31:0] mem_read_data  // Data read from external memory
);

  // Internal registers
  reg [31:0] A;
  reg [31:0] B;
  reg [31:0] result;
  reg [15:0] addr_reg; // Register to hold memory address
  reg write_en_reg;   // Register to hold write enable signal

  // Control unit
  always @(posedge clk) begin
    if (rst) begin
      A <= 0;
      B <= 0;
      result <= 0;
      addr_reg <= 0;
      write_en_reg <= 0;
    end else begin
      // [31:28 - opcode] [27:16 - operand1] [15:4 - operand2] [3:0 - unused]
      case (instruction[31:28])
        4'b0001: begin // ADD
          A <= mem_read_data; // Read from external memory
          addr_reg <= instruction[15:4]; // Address for second operand
          write_en_reg <= 0; // Disable write
        end
        4'b0010: begin // SUB
          A <= mem_read_data; // Read from external memory
          addr_reg <= instruction[15:4]; // Address for second operand
          write_en_reg <= 0; // Disable write
        end
        4'b0011: begin // MUL
          A <= mem_read_data; // Read from external memory
          addr_reg <= instruction[15:4]; // Address for second operand
          write_en_reg <= 0; // Disable write
        end
        4'b0100: begin // LOAD
          addr_reg <= instruction[27:16]; // Load address
          write_en_reg <= 0; // Disable write
        end
        4'b0101: begin // STORE
          addr_reg <= instruction[27:16]; // Store address
          write_en_reg <= 1; // Enable write
        end
        default: begin // For other instructions or no-op
          addr_reg <= 0;
          write_en_reg <= 0;
        end
      endcase

      // Perform ALU operation after reading second operand
      if (instruction[31:28] == 4'b0001 && addr_reg != 0) begin // ADD
        result <= A + mem_read_data;
      end else if (instruction[31:28] == 4'b0010 && addr_reg != 0) begin // SUB
        result <= A - mem_read_data;
      end else if (instruction[31:28] == 4'b0011 && addr_reg != 0) begin // MUL
        result <= A * mem_read_data;
      end
    end
  end

  // External memory interface connections
  assign mem_addr = addr_reg;
  assign mem_write_en = write_en_reg;
  assign mem_write_data = A;

  // Output
  assign data_out = result;

endmodule

`endif // SIMPLE_GPU
```

`tb_simple_gpu.sv`
```verilog
`ifndef TB_SIMPLE_GPU
`define TB_SIMPLE_GPU

`include "simple_gpu.sv"
`include "memory_controller.sv"
`include "my_utils.sv"

module simple_gpu_tb;
    reg clk;
    reg reset;
    reg  [31:0] test_val;
    reg  [31:0] instr;
    reg  [3:0] opcode;
    reg  [15:0] operand1;
    reg  [15:0] operand2;
    wire [31:0] result;
    wire [15:0] memory_addr;
    wire         memory_write_en;
    wire [31:0] mem_write_data;
    wire [31:0] mem_read_data;

    // Internal registers
    reg [31:0] A;
    reg [31:0] B;
    reg [31:0] C;

    string formatted_string = "";

    simple_gpu uut_gpu (
        .clk(clk),
        .rst(reset),
        .instruction(instr),
        .data_out(result),
        .mem_addr (memory_addr),
        .mem_write_en(memory_write_en),
        .mem_write_data(memory_write_data),
        .mem_read_data(memory_read_data)
    );

    memory_controller uut_mem (
        .clk(clk),
        .rst(rst),
        .addr(memory_addr),
        .write_en(memory_write_en),
        .write_data(memory_write_data),
        .read_data(memory_read_data)
  );


    always #5 clk = ~clk;

    initial begin
        $display("Starting GPU Testbench");
        // Initialize signals
        clk = 0;
        reset = 1;
        test_val = 32'd0;
        instr = 32'b0;
        opcode = 4'b0;
        operand1 = 32'b0;
        operand2 = 32'b0;

        #10 reset = 0;

        // Example of stimulating inputs and observing outputs:
        // [31:28 - opcode] [27:16 - operand1] [15:4 - operand2] [3:0 - unused]

        // Test STORE
        #10 opcode = 4'b0101; operand1 = 12'b0; operand2 = 12'd05;
        test_val = operand1;
        $display("STORE OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        instr = {opcode, operand1, operand2, 4'b0000}; // STORE instruction, address 0x0005 as 12-bit addr
        formatted_string = binary_to_string(instr);
        $display("instruction = %h", formatted_string);
        $display("\n");

        #10 $display("STORE Result: Memory[%d] is %d", operand1, );


        // // Test LOAD
        // #10 opcode = 4'b0100; operand1 = 12'b0; operand2 = 12'd05;
        // $display("LOAD OP: op1 = %d, op2 = %d opcode = %d", operand1, operand2, opcode);
        // instr = {opcode, operand1, operand2, 4'b0000}; // STORE instruction, address 0x0005 as 12-bit addr
        // $display("instruction = %h", formatted_string);
        // $display("\n");

        // #10 $display("LOAD Result: %d", result);

        $finish;
    end
endmodule
`endif // TB_SIMPLE_GPU
```

````
