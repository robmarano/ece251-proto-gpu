`ifndef MY_UTILS
`define MY_UTILS

function string binary_to_string (input [31:0] bin_num);
  string str;
  str = ""; 

  for (int i = 31; i >= 0; i = i - 4) begin
    str = str + {"%b", bin_num >> (i - 3) & 4'hf}; // Use shift and mask
    if (i > 0) str = str + "-";
  end

  return str;
endfunction

`endif // MY_UTILS