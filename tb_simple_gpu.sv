`ifndef TB_SIMPLE_GPU
`define TB_SIMPLE_GPU
`timescale 1ms/10us

`include "simple_gpu.sv"
`include "memory_controller.sv"
//`include "my_utils.sv" // don't use yet; broken

module tb_simple_gpu;
    reg clk;
    reg reset;
    reg  [31:0] test_val;
    reg  [31:0] instr;
    reg  [3:0] opcode;
    reg  [3:0] operand1;
    reg  [3:0] operand2;
    wire [31:0] result;
    wire [15:0] memory_addr;
    wire         memory_write_en;
    wire [31:0] mem_write_data;
    wire [31:0] mem_read_data;
    reg  [31:0] registers [0:15]; // Output register file
    reg  [19:0] imm; // Immediate value for ADDI

    // string formatted_string = "";

    memory_controller uut_mem (
        .clk(clk),
        .rst(reset),
        .addr(memory_addr),
        .write_en(memory_write_en),
        .write_data(memory_write_data),
        .read_data(memory_read_data)
    );

    simple_gpu uut_gpu (
        .clk(clk),
        .rst(reset),
        .instruction(instr),
        .result(result),
        .mem_addr (memory_addr),
        .mem_write_en(memory_write_en),
        .mem_write_data(memory_write_data),
        .mem_read_data(memory_read_data),
        .register_file(registers)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting GPU Testbench");
        $dumpfile("tb_simple_gpu.vcd");
        $dumpvars(2, tb_simple_gpu, uut_gpu, uut_mem);
        clk = 0;
        reset = 1;
    end
    
    initial begin
        // Initialize signals
        // clk = 0;
        // reset = 1;
        // test_val = 0;
        // instr = 32'b0;
        // opcode = 0;
        // operand1 = 0;
        // operand2 = 0;

        #20 reset = 0;

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


        // Example of stimulating inputs and observing outputs:

        // Test ADD
        #10;

        opcode = 4'b1001; // ADDI
        operand1 = 4'b0001;
        operand2 = 4'b0010;
        imm = 20'b0000_0000_0000_0001;
        instr = {opcode, operand1, operand2, imm};
        // instr = {4'b1001, 4'b0001, 4'b0010, 20'b0000_0000_0000_0001}; // STORE operand1 to register 2
        $display("ADDI instruction: %b %b %b %b %b %b %b %b", instr[31:28], instr[27:24], instr[23:20], 
                                    instr[19:16], instr[15:12], instr[11:8], 
                                    instr[7:4], instr[3:0]);
        #10;
        // Print the values of all registers
        for (int i = 0; i < 16; i++) begin
            // $display("Register %d: %h", i, registers[i]);
            $display("Register %d: %h", i, uut_gpu.register_file[i]);
        end


        #10;
        // opcode = 4'b0001; 
        // operand1 = 4'd5;   // Value for source register 1
        // operand2 = 4'd10;  // Value for source register 2
        // Store values in registers 2 and 3
        // instr = {4'b0101, 4'b0001, 4'b0010, 4'b0011, 16'b0}; // STORE operand1 to register 2
        // instr = {4'b1001, 4'b0001, 4'b0010, 20'b0000_0000_0000_0001}; // STORE operand1 to register 2
        // instr = {4'b0101, 4'd2, operand1, 4'b0000}; // STORE operand1 to register 2
        // $display("STORE instruction: %h", instr);
        // $display("%b %b %b %b %b %b %b %b", instr[31:28], instr[27:24], instr[23:20], 
                                    // instr[19:16], instr[15:12], instr[11:8], 
                                    // instr[7:4], instr[3:0]);
        // $display("STORE instruction: %h", binary_to_string(instr));

        #10;
        // instr = {4'b0101, 16'd3, operand2, 4'b0000}; // STORE operand2 to register 3
        // $display("STORE instruction: %h", instr);
        // // $display("STORE instruction: %h", binary_to_string(instr));
        // $display("%b %b %b %b %b %b %b %b", instr[31:28], instr[27:24], instr[23:20], 
        //                             instr[19:16], instr[15:12], instr[11:8], 
        //                             instr[7:4], instr[3:0]);

        #10;
        // // ADD instruction: R2 + R3 -> R1
        // instr = {opcode, 4'b0010, 4'b0011, 4'b0001, 12'b0000}; 
        // $display("ADD instruction: %h", instr);
        // // $display("ADD instruction: %h", binary_to_string(instr));
        // $display("%b %b %b %b %b %b %b %b", instr[31:28], instr[27:24], instr[23:20], 
        //                             instr[19:16], instr[15:12], instr[11:8], 
        //                             instr[7:4], instr[3:0]);

        #10;

        // // Verify the result (R1 should contain 15)
        // $display("ADD Result (Register 1): %d", registers[1]); 
        // $display("%b %b %b %b %b %b %b %b", registers[1][31:28], registers[1][27:24], registers[1][23:20], 
        //                             registers[1][19:16], registers[1][15:12], registers[1][11:8], 
        //                             registers[1][7:4], registers[1][3:0]);

        // // Print the values of all registers
        // for (int i = 0; i < 16; i++) begin
        //     $display("Register %d: %h", i, registers[i]);
        // end

        $finish;
    end
endmodule
`endif // TB_SIMPLE_GPU