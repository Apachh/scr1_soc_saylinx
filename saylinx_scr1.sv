`include "scr1_arch_types.svh"
`include "scr1_arch_description.svh"
`include "scr1_memif.svh"
`include "scr1_ipic.svh"

//`define SCR1_ARCH_CUSTOM

module saylinx_scr1 (
    input   logic       CLK_50MHZ,

    input   logic       JTAG_SRST_N,
    input   logic       JTAG_TRST_N,
    input   logic       JTAG_TCK,
    input   logic       JTAG_TMS,
    input   logic       JTAG_TDI,
    output  logic       JTAG_TDO,

//    output  logic [3:0] LED,
//    input   logic [1:0] KEY
	input   logic KEY

    // === UART ============================================
    // output logic                    UART_TXD,    // <- UART
    // input  logic                    UART_RXD     // -> UART
    );

    //=======================================================
    //  Signals / Variables declarations
    //=======================================================
    logic                               nrst;
    logic                               cpu_clk;

    assign nrst = KEY & JTAG_SRST_N;
    assign cpu_clk = CLK_50MHZ;

    `ifdef SCR1_IPIC_EN
    logic [31:0]                        scr1_irq;
    `else
    logic                               scr1_irq;
    `endif // SCR1_IPIC_EN

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

    

    ahb3lite_interconnect_master_port #(.HADDR_SIZE(SCR1_AHB_WIDTH), .HDATA_SIZE(SCR1_AHB_WIDTH), .MASTERS(1))
    scr1_imem_ahb (
        .HCLK(cpu_clk),
        .HRESETn(nrst),
        .mst_HSEL('1),
        .mst_HADDR(ahb_imem_haddr),
        .mst_HWDATA('0),
        .mst_HRDATA(ahb_imem_hrdata),
        .mst_HWRITE('0),
        .mst_HSIZE(ahb_imem_hsize),
        .mst_HBURST(ahb_imem_hburst),
        .mst_HPROT(ahb_imem_hprot),
        .mst_HTRANS(ahb_imem_htrans),
        .mst_HREADY(ahb_imem_hready),
        .mst_HRESP(ahb_imem_hresp),
        .mst_HMASTLOCK(ahb_imem_hmastlock),
        .mst_HREADYOUT()
    );

    ahb3lite_interconnect_master_port #(.HADDR_SIZE(SCR1_AHB_WIDTH), .HDATA_SIZE(SCR1_AHB_WIDTH), .MASTERS(1))
    scr1_dmem_ahb (
        .HCLK(cpu_clk),
        .HRESETn(nrst),
        .mst_HSEL('1),
        .mst_HADDR(ahb_dmem_haddr),
        .mst_HWDATA(ahb_dmem_hwdata),
        .mst_HRDATA(ahb_dmem_hrdata),
        .mst_HWRITE(ahb_dmem_hwrite),
        .mst_HSIZE(ahb_dmem_hsize),
        .mst_HBURST(ahb_dmem_hburst),
        .mst_HPROT(ahb_dmem_hprot),
        .mst_HTRANS(ahb_dmem_htrans),
        .mst_HREADY(ahb_dmem_hready),
        .mst_HRESP(ahb_dmem_hresp),
        .mst_HMASTLOCK(ahb_dmem_hmastlock),
        .mst_HREADYOUT()
    );


//=======================================================
//  SCR1 Core's Processor Cluster
//=======================================================
   scr1_top_ahb
   i_scr1 (
       // Common
       .pwrup_rst_n                (1'b1                   ),
       .rst_n                      (nrst                   ),
       .cpu_rst_n                  (1'b1                   ),
       .test_mode                  (1'b0                   ),
       .test_rst_n                 (1'b1                   ),
       .clk                        (cpu_clk                ),
       .rtc_clk                    (1'b0                   ),
`ifdef SCR1_DBG_EN
       .sys_rst_n_o                (                       ),
       .sys_rdc_qlfy_o             (                       ),
`endif // SCR1_DBG_EN

       // Fuses
       .fuse_mhartid               ('0                     ),
`ifdef SCR1_DBG_EN
       .fuse_idcode                (`SCR1_TAP_IDCODE       ),
`endif // SCR1_DBG_EN

       // IRQ
`ifdef SCR1_IPIC_EN
       .irq_lines                  ('0                     ),
`else
       .ext_irq                    ('0                     ),
`endif//SCR1_IPIC_EN
       .soft_irq                   ('0                     ),

`ifdef SCR1_DBG_EN
       // Debug Interface - JTAG I/F
       .trst_n                     (scr1_jtag_trst_n       ),
       .tck                        (scr1_jtag_tck          ),
       .tms                        (scr1_jtag_tms          ),
       .tdi                        (scr1_jtag_tdi          ),
       .tdo                        (scr1_jtag_tdo_int      ),
       .tdo_en                     (scr1_jtag_tdo_en       ),
`endif//SCR1_DBG_EN

       // Instruction Memory Interface
       .imem_hprot                 (ahb_imem_hprot         ),
       .imem_hburst                (ahb_imem_hburst        ),
       .imem_hsize                 (ahb_imem_hsize         ),
       .imem_htrans                (ahb_imem_htrans        ),
       .imem_hmastlock             (                       ),
       .imem_haddr                 (ahb_imem_haddr         ),
       .imem_hready                (ahb_imem_hready        ),
       .imem_hrdata                (ahb_imem_hrdata        ),
       .imem_hresp                 (ahb_imem_hresp         ),
       // Data Memory Interface
       .dmem_hprot                 (ahb_dmem_hprot         ),
       .dmem_hburst                (ahb_dmem_hburst        ),
       .dmem_hsize                 (ahb_dmem_hsize         ),
       .dmem_htrans                (ahb_dmem_htrans        ),
       .dmem_hmastlock             (                       ),
       .dmem_haddr                 (ahb_dmem_haddr         ),
       .dmem_hwrite                (ahb_dmem_hwrite        ),
       .dmem_hwdata                (ahb_dmem_hwdata        ),
       .dmem_hready                (ahb_dmem_hready        ),
       .dmem_hrdata                (ahb_dmem_hrdata        ),
       .dmem_hresp                 (ahb_dmem_hresp         )
   );

    `ifdef SCR1_DBG_EN
    assign scr1_jtag_trst_n     = JTAG_TRST_N;
    assign scr1_jtag_tck        = JTAG_TCK;
    assign scr1_jtag_tms        = JTAG_TMS;
    assign scr1_jtag_tdi        = JTAG_TDI;
    assign JTAG_TDO             = (scr1_jtag_tdo_en) ? scr1_jtag_tdo_int : 1'bZ;
    `endif // SCR1_DBG_EN

    

endmodule