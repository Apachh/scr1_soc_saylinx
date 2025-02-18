`include "scr1_arch_types.svh"
`include "scr1_arch_description.svh"
`include "scr1_memif.svh"
`include "scr1_ipic.svh"

//`define SCR1_ARCH_CUSTOM

module saylinx_scr1 (
    input   logic       CLK_50MHZ,

    output  logic [3:0] LED,
    input   logic [1:0] KEY,

`ifdef SCR1_DBG_EN  
    input   logic       JTAG_SRST_N,
    input   logic       JTAG_TRST_N,
    input   logic       JTAG_TCK,
    input   logic       JTAG_TMS,
    input   logic       JTAG_TDI,
    output  logic       JTAG_TDO,
`endif//SCR1_DBG_EN

    // === UART ============================================
    output logic                    UART_TXD,    // <- UART
    input  logic                    UART_RXD     // -> UART
);



    logic                               pwrup_rst_n;
    logic                               cpu_clk;
    logic                               extn_rst_in_n;
    logic                               extn_rst_n;
    logic [1:0]                         extn_rst_n_sync;
    logic                               hard_rst_n;
    logic [3:0]                         hard_rst_n_count;
    logic                               cpu_rst_n;
    `ifdef SCR1_DBG_EN
    logic                               sys_rst_n;
    `endif // SCR1_DBG_EN

    assign cpu_clk = CLK_50MHZ; 

    // --- SCR1 ---------------------------------------------
    logic [3:0]                         ahb_imem_hprot;
    logic [2:0]                         ahb_imem_hburst;
    logic [2:0]                         ahb_imem_hsize;
    logic [1:0]                         ahb_imem_htrans;
    logic [SCR1_AHB_WIDTH-1:0]          ahb_imem_haddr;
    logic                               ahb_imem_hready;
    logic [SCR1_AHB_WIDTH-1:0]          ahb_imem_hrdata;
    logic                               ahb_imem_hresp;
    //
    logic [3:0]                         ahb_dmem_hprot;
    logic [2:0]                         ahb_dmem_hburst;
    logic [2:0]                         ahb_dmem_hsize;
    logic [1:0]                         ahb_dmem_htrans;
    logic [SCR1_AHB_WIDTH-1:0]          ahb_dmem_haddr;
    logic                               ahb_dmem_hwrite;
    logic [SCR1_AHB_WIDTH-1:0]          ahb_dmem_hwdata;
    logic                               ahb_dmem_hready;
    logic [SCR1_AHB_WIDTH-1:0]          ahb_dmem_hrdata;
    logic                               ahb_dmem_hresp;
    `ifdef SCR1_IPIC_EN
    logic [31:0]                        scr1_irq;
    `else
    logic                               scr1_irq;
    `endif // SCR1_IPIC_EN

    //=======================================================
    //  Resets
    //=======================================================
    assign extn_rst_in_n    = KEY[0]
    `ifdef SCR1_DBG_EN
                            & JTAG_SRST_N
    `endif // SCR1_DBG_EN
    ;

    always_ff @(posedge cpu_clk, negedge pwrup_rst_n)
    begin
        if (~pwrup_rst_n) begin
            extn_rst_n_sync     <= '0;
        end else begin
            extn_rst_n_sync[0]  <= extn_rst_in_n;
            extn_rst_n_sync[1]  <= extn_rst_n_sync[0];
        end
    end
    assign extn_rst_n = extn_rst_n_sync[1];

    always_ff @(posedge cpu_clk, negedge pwrup_rst_n)
    begin
        if (~pwrup_rst_n) begin
            hard_rst_n          <= 1'b0;
            hard_rst_n_count    <= '0;
        end else begin
            if (hard_rst_n) begin
                // hard_rst_n == 1 - de-asserted
                hard_rst_n          <= extn_rst_n;
                hard_rst_n_count    <= '0;
            end else begin
                // hard_rst_n == 0 - asserted
                if (extn_rst_n) begin
                    if (hard_rst_n_count == '1) begin
                        // If extn_rst_n = 1 at least 16 clocks,
                        // de-assert hard_rst_n
                        hard_rst_n          <= 1'b1;
                    end else begin
                        hard_rst_n_count    <= hard_rst_n_count + 1'b1;
                    end
                end else begin
                    // If extn_rst_n is asserted within 16-cycles window -> start
                    // counting from the beginning
                    hard_rst_n_count    <= '0;
                end
            end
        end
    end

    // scr1_top_ahb
    // i_scr1 (
    //         // Common
    //         .pwrup_rst_n                (pwrup_rst_n            ),
    //         .rst_n                      (hard_rst_n             ),
    //         .cpu_rst_n                  (cpu_rst_n              ),
    //         .test_mode                  (1'b0                   ),
    //         .test_rst_n                 (1'b1                   ),
    //         .clk                        (cpu_clk                ),
    //         .rtc_clk                    (1'b0                   ),
    // `ifdef SCR1_DBG_EN
    //         .sys_rst_n_o                (sys_rst_n              ),
    //         .sys_rdc_qlfy_o             (                       ),
    // `endif // SCR1_DBG_EN

    //         // Fuses
    //         .fuse_mhartid               ('0                     ),
    // `ifdef SCR1_DBG_EN
    //         .fuse_idcode                (`SCR1_TAP_IDCODE       ),
    // `endif // SCR1_DBG_EN

    //         // IRQ
    // `ifdef SCR1_IPIC_EN
    //         .irq_lines                  (scr1_irq               ),
    // `else
    //         .ext_irq                    (scr1_irq             ),
    // `endif//SCR1_IPIC_EN
    //         .soft_irq                   ('0                     ),

    // `ifdef SCR1_DBG_EN
    //         // Debug Interface - JTAG I/F
    //         .trst_n                     (scr1_jtag_trst_n       ),
    //         .tck                        (scr1_jtag_tck          ),
    //         .tms                        (scr1_jtag_tms          ),
    //         .tdi                        (scr1_jtag_tdi          ),
    //         .tdo                        (scr1_jtag_tdo_int      ),
    //         .tdo_en                     (scr1_jtag_tdo_en       ),
    // `endif//SCR1_DBG_EN

    //         // Instruction Memory Interface
    //         .imem_hprot                 (ahb_imem_hprot         ),
    //         .imem_hburst                (ahb_imem_hburst        ),
    //         .imem_hsize                 (ahb_imem_hsize         ),
    //         .imem_htrans                (ahb_imem_htrans        ),
    //         .imem_hmastlock             (                       ),
    //         .imem_haddr                 (ahb_imem_haddr         ),
    //         .imem_hready                (ahb_imem_hready        ),
    //         .imem_hrdata                (ahb_imem_hrdata        ),
    //         .imem_hresp                 (ahb_imem_hresp         ),
    //         // Data Memory Interface
    //         .dmem_hprot                 (ahb_dmem_hprot         ),
    //         .dmem_hburst                (ahb_dmem_hburst        ),
    //         .dmem_hsize                 (ahb_dmem_hsize         ),
    //         .dmem_htrans                (ahb_dmem_htrans        ),
    //         .dmem_hmastlock             (                       ),
    //         .dmem_haddr                 (ahb_dmem_haddr         ),
    //         .dmem_hwrite                (ahb_dmem_hwrite        ),
    //         .dmem_hwdata                (ahb_dmem_hwdata        ),
    //         .dmem_hready                (ahb_dmem_hready        ),
    //         .dmem_hrdata                (ahb_dmem_hrdata        ),
    //         .dmem_hresp                 (ahb_dmem_hresp         )
    // );
endmodule