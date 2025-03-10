 `define UART_ADDR_WIDTH 5
 `define UART_DATA_WIDTH 32

module uart_ahb_top (
    input   logic clk,
    input   logic nrst,
    input   logic ahb_hwrite,
    input   logic [31:0] ahb_haddr,
    input   logic [31:0] ahb_hwdata,
    input   logic ahb_hsel,
    input   logic [1:0] ahb_htrans,
    input   logic [2:0] ahb_hburst,
    output  logic ahb_hready,
    output  logic ahb_hresp,
    output  logic [31:0] ahb_hrdata,

    input   logic uart_rx,
    output  logic uart_tx,
    output  logic uart_rts,
    input   logic uart_cts,
    output  logic uart_dtr,
    input   logic uart_dsr,
    input   logic uart_ri,
    input   logic uart_dcd
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
        .dat_i (wbs_dat_o),
        .dat_o (wbs_dat_i),
        .ack_i (wbs_ack_o),
        .we_o (wbs_we_i) ,
        .adr_o (wbs_adr_i),
        .cyc_o (wbs_cyc_i),
        .stb_o (wbs_stb_i),

        // Unused
        .hsize('0), 
	    .clk_i('0),
	    .rst_i('0)
    );

    uart_top #(`UART_DATA_WIDTH, `UART_ADDR_WIDTH) 
    i_uart_top
    (
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
        .stx_pad_o          (uart_tx),
        .srx_pad_i          (uart_rx),
        // Modem signals    
        .rts_pad_o          (uart_rts),
        .cts_pad_i          (uart_cts),
        .dtr_pad_o          (uart_dtr),
        .dsr_pad_i          (uart_dsr),
        .ri_pad_i           (uart_ri),
        .dcd_pad_i          (uart_dcd)
    );

endmodule