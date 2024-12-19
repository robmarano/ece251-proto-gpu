`ifndef MEMORY_CONTROLLER
`define MEMORY_CONTROLLER

module memory_controller (
  input clk,
  input rst,
  input [15:0] addr,        // Address from the GPU
  input write_en,         // Write enable signal from the GPU
  input [31:0] write_data, // Data to write from the GPU
  output reg [31:0] read_data // Data read from the memory
);

  // Declare the external memory
  reg [31:0] memory [0:65535]; // Example: 64KB memory

  // Display message at the start of simulation
  // initial begin
  //     $display("Memory Controller initialized.");
  //     if (rst) begin
  //       $display("Memory controller reset");
  //       // Initialize memory
  //       for (int i = 0; i < 65536; i = i + 1) begin
  //         memory[i] = 32'b0;
  //       end
  //       read_data <= 32'b0;
  //     end

  // end

  // // Reset operation
  // always @(posedge clk or posedge rst) begin
  //   $display("Memory controller reset");
  //   // Initialize memory
  //   for (int i = 0; i < 65536; i = i + 1) begin
  //     memory[i] = 32'b0;
  //   end
  //   read_data <= 32'b0;
  // end

  // // Read operation
  // always @(posedge clk) begin
  //   read_data <= memory[addr]; 
  // end

  always @(posedge clk) begin
    if (rst) begin
      $display("Memory controller reset");
      // Initialize memory
      for (int i = 0; i < 65536; i = i + 1) begin
            memory[i] = 32'b0;
      end
      read_data <= 32'b0;
    end else begin
      read_data <= memory[addr]; 
    end
  end

  // Write operation
  always @(posedge clk) begin
    if (write_en) begin
      $display("Memory controller write");
      memory[addr] <= write_data;
    end
  end


endmodule
`endif // MEMORY_CONTROLLER