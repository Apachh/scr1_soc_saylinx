`ifndef SCR1_ARCH_CUSTOM_SVH
`define SCR1_ARCH_CUSTOM_SVH

// Current FPGA build identificators, can be modified
`define SCR1_PTFM_SOC_ID            32'h21041500
`define SCR1_PTFM_BLD_ID            32'h22011203
`define SCR1_PTFM_CORE_CLK_FREQ     32'd20000000

// Uncomment to select recommended core architecture configurations
// Default SCR1 FPGA SDK created for RV32IMC_MAX config

// `define SCR1_CFG_RV32IMC_MAX
//`define SCR1_CFG_RV32IC_BASE
`define SCR1_CFG_RV32EC_MIN

`define SCR1_ARCH_CUSTOM

// `define SCR1_DBG_EN
// `undef SCR1_TCM_EN

parameter bit [`SCR1_XLEN-1:0]          SCR1_ARCH_RST_VECTOR        = 'hFFFFFF00;   // Reset vector
parameter bit [`SCR1_XLEN-1:0]          SCR1_ARCH_MTVEC_BASE        = 'hFFFFFF80;   // MTVEC BASE field reset value

parameter bit [`SCR1_DMEM_AWIDTH-1:0]   SCR1_TCM_ADDR_MASK          = 'hFFFF0000;   // TCM mask and size
parameter bit [`SCR1_DMEM_AWIDTH-1:0]   SCR1_TCM_ADDR_PATTERN       = 'hF0000000;   // TCM address match pattern

parameter bit [`SCR1_DMEM_AWIDTH-1:0]   SCR1_TIMER_ADDR_MASK        = 'hFFFFFFE0;   // Timer mask (should be 0xFFFFFFE0)
parameter bit [`SCR1_DMEM_AWIDTH-1:0]   SCR1_TIMER_ADDR_PATTERN     = 'hF0040000;   // Timer address match pattern

`endif // SCR1_ARCH_CUSTOM_SVH
