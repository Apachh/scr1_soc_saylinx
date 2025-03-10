 `define UART_ADDR_WIDTH 5
 `define UART_DATA_WIDTH 32

module uart_ahb_top (
    input   logic clk,
    input   logic nrst,
    input   logic ahb_hwrite,
    input   logic ahb_haddr,
    input   logic ahb_hwdata,
    input   logic ahb_hsel,
    input   logic ahb_htrans,
    input   logic ahb_hburst,z
    input   logic ahb_hready,
    input   logic ahb_hresp,
    input   logic ahb_hrdata
    input   logic uart_rx,
    output  logic uart_tx
);

    // UART Wishbone Slave signals
    logic                         wb_int_o;
    logic [`UART_ADDR_WIDTH-1:0]  wbs_adr_i;
    logic [`UART_DATA_WIDTH-1:0]  wbs_dat_i;
    logic [`UART_DATA_WIDTH-1:0]  wbs_dat_o;
    logic                  [3:0]  wbs_sel_i;
    logic                         wbs_cyc_i;
    logic                         wbs_stb_i;
    logic                  [2:0]  wbs_cti_i;
    logic                  [1:0]  wbs_bte_i;
    logic                         wbs_we_i;
    logic                         wbs_ack_o;

    // UART signals

    // UART Serial Data I/O signals
    logic                         stx_pad_o;
    logic                         srx_pad_i;
    // UART Modem I/O signals
    logic                         rts_pad_o;
    logic                         cts_pad_i;
    logic                         dtr_pad_o;
    logic                         dsr_pad_i;
    logic                         ri_pad_i;
    logic                         dcd_pad_i;

    ahb2wb
    bridge (
        // AHB
        .hclk (clk),
        .hresetn (nrst),
        .htrans (ahb_htrans),
        .hwrite (ahb_hwrite),
        .hrdata (ahb_hrdata),
        .hsel (ahb_hsel),
        .hready (ahb_hready),
        .hburst (ahb_hburst),
        .hwdata (ahb_hwdata),
        .hresp (ahb_hresp),
        .haddr (ahb_haddr),
        // Wishbone
        .dat_i (dat_i ) ,
        .dat_o (dat_o ) ,
        .ack_i (ack_i ) ,
        .we_o (we_o ) ,
        .adr_o (adr_o ) ,
        .cyc_o (cyc_o ) ,
        .stb_o (stb_o ),
        // Unused
        .hsize (), 
	    .clk_i(),
	    .rst_i()
    );

    uart_top #(`UART_DATA_WIDTH, `UART_ADDR_WIDTH)
    uart (
        .wb_clk_i           (clk),
        .wb_rst_i           (nrst),
        .int_o              (wb_int_o),
        // WB slave signals - 2 address locations for two registers!
        .wb_cyc_i           (wbs_cyc_i),
        .wb_stb_i           (wbs_stb_i),
        .wb_we_i            (wbs_we_i),
        .wb_sel_i           (wbs_sel_i),
        .wb_adr_i           (wbs_adr_i),
        .wb_dat_i           (wbs_dat_i),
        .wb_dat_o           (wbs_dat_o),
        .wb_ack_o           (wbs_ack_o),
        // UART signals
        .stx_pad_o          (stx_pad_o),
        .srx_pad_i          (srx_pad_i)
    );

endmodule