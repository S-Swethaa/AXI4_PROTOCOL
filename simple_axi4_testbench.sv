module tb;

parameter ADDR_W   = 32;
parameter DATA_W   = 32;
parameter ID_WIDTH = 4;

logic clk;
logic rst;
logic start;

logic [ADDR_W-1:0] o_mas_awaddr;
logic [2:0]  o_mas_awsize;
logic [1:0]  o_mas_awburst;
logic [7:0]  o_mas_awlen;
logic [3:0]  o_mas_awcache;
logic [3:0]  o_mas_awid;
logic         o_mas_awlock;

logic [DATA_W-1:0] o_mas_wdata;
logic [3:0]        o_mas_strb;

logic [ADDR_W-1:0] o_mas_araddr;
logic [2:0]  o_mas_arsize;
logic [1:0]  o_mas_arburst;
logic [7:0]  o_mas_arlen;
logic [3:0]  o_mas_arcache;
logic [ID_WIDTH-1:0] o_mas_arid;
logic         o_mas_arlock;


// CLOCK

initial clk = 0;
always #5 clk = ~clk;


// DUT

axi4_top dut(

    .clk(clk),
    .rst(rst),
    .start(start),

    .o_mas_awaddr(o_mas_awaddr),
    .o_mas_awsize(o_mas_awsize),
    .o_mas_awburst(o_mas_awburst),
    .o_mas_awlen(o_mas_awlen),
    .o_mas_awcache(o_mas_awcache),
    .o_mas_awid(o_mas_awid),
    .o_mas_awlock(o_mas_awlock),

    .o_mas_wdata(o_mas_wdata),
    .o_mas_strb(o_mas_strb),

    .o_mas_araddr(o_mas_araddr),
    .o_mas_arsize(o_mas_arsize),
    .o_mas_arburst(o_mas_arburst),
    .o_mas_arlen(o_mas_arlen),
    .o_mas_arcache(o_mas_arcache),
    .o_mas_arid(o_mas_arid),
    .o_mas_arlock(o_mas_arlock)

);
initial begin
    rst = 1;
    start = 0;

    #20;
    rst = 0;

    o_mas_awaddr  = 32'h10;
    o_mas_awsize  = 3'b010;
    o_mas_awburst = 2'b01;
    o_mas_awlen   = 8;
    o_mas_awcache = 4'b0011;
    o_mas_awid    = 1;
    o_mas_awlock  = 0;

    o_mas_wdata   = 32'hA5A5_F0F0;
    o_mas_strb    = 4'b1111;

    o_mas_araddr  = 32'h10;
    o_mas_arsize  = 3'b010;
    o_mas_arburst = 2'b01;
    o_mas_arlen   = 8;
    o_mas_arcache = 4'b0011;
    o_mas_arid    = 1;
    o_mas_arlock  = 0;
  

    #10;
    start = 1;

    #10;
    start = 0;

    #300;
    $finish;

end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end

endmodule

# //
# Loading sv_std.std
# Loading work.tb(fast)
# Loading work.axi4_top(fast)
# Loading work.axi4_master(fast)
# Loading work.axi4_slave(fast)
# 
# run -all
# [55] SLAVE: WRITE ADDRESS RECEIVED
# AWID=1, AWADDR=00000010, AWLEN=8
# WRITE ADDRESS HANDSHAKE: AWADDR=00000010 AWLEN=8 TOTAL WRITE BYTES=36
# [75] SLAVE: WRITE DATA RECEIVED
# BEAT=0, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# WRITE DATA BEAT=0 WDATA=a5a5f0f0 WSTRB=1111
# WRITE DATA BEAT=1 WDATA=a5a5f0f0 WSTRB=1111
# [85] SLAVE: WRITE DATA RECEIVED
# BEAT=1, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# [95] SLAVE: WRITE DATA RECEIVED
# BEAT=2, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# WRITE DATA BEAT=2 WDATA=a5a5f0f0 WSTRB=1111
# WRITE DATA BEAT=3 WDATA=a5a5f0f0 WSTRB=1111
# [105] SLAVE: WRITE DATA RECEIVED
# BEAT=3, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# [115] SLAVE: WRITE DATA RECEIVED
# BEAT=4, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# WRITE DATA BEAT=4 WDATA=a5a5f0f0 WSTRB=1111
# WRITE DATA BEAT=5 WDATA=a5a5f0f0 WSTRB=1111
# [125] SLAVE: WRITE DATA RECEIVED
# BEAT=5, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# [135] SLAVE: WRITE DATA RECEIVED
# BEAT=6, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# WRITE DATA BEAT=6 WDATA=a5a5f0f0 WSTRB=1111
# WRITE DATA BEAT=7 WDATA=a5a5f0f0 WSTRB=1111
# [145] SLAVE: WRITE DATA RECEIVED
# BEAT=7, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# [155] SLAVE: WRITE DATA RECEIVED
# BEAT=8, WDATA=a5a5f0f0, WSTRB=1111, WLAST=0
# WRITE DATA BEAT=8 WDATA=a5a5f0f0 WSTRB=1111
# WRITE DATA BEAT=9 WDATA=a5a5f0f0 WSTRB=1111
# (LAST BEAT)
# [165] SLAVE: WRITE DATA RECEIVED
# BEAT=9, WDATA=a5a5f0f0, WSTRB=1111, WLAST=1
# [165] SLAVE: LAST WRITE DATA RECEIVED
# [185] SLAVE: WRITE RESPONSE SENT
# BID=1, BRESP=0
# WRITE RESPONSE RECEIVED BID=1 BRESP=0
# [205] SLAVE: READ ADDRESS RECEIVED
# ARID=1, ARADDR=00000010, ARLEN=8
# READ ADDRESS HANDSHAKE: ARADDR=00000010 ARLEN=8 TOTAL READ BYTES=36
# [225] SLAVE: READ DATA SENT
# BEAT=0, RDATA=a5a5f0f0, RLAST=0
# READ DATA BEAT=0 RDATA=a5a5f0f0
# READ DATA BEAT=1 RDATA=a5a5f0f0
# [235] SLAVE: READ DATA SENT
# BEAT=1, RDATA=a5a5f0f0, RLAST=0
# [245] SLAVE: READ DATA SENT
# BEAT=2, RDATA=a5a5f0f0, RLAST=0
# READ DATA BEAT=2 RDATA=a5a5f0f0
# READ DATA BEAT=3 RDATA=a5a5f0f0
# [255] SLAVE: READ DATA SENT
# BEAT=3, RDATA=a5a5f0f0, RLAST=0
# [265] SLAVE: READ DATA SENT
# BEAT=4, RDATA=a5a5f0f0, RLAST=0
# READ DATA BEAT=4 RDATA=a5a5f0f0
# READ DATA BEAT=5 RDATA=a5a5f0f0
# [275] SLAVE: READ DATA SENT
# BEAT=5, RDATA=a5a5f0f0, RLAST=0
# [285] SLAVE: READ DATA SENT
# BEAT=6, RDATA=a5a5f0f0, RLAST=0
# READ DATA BEAT=6 RDATA=a5a5f0f0
# READ DATA BEAT=7 RDATA=a5a5f0f0
# [295] SLAVE: READ DATA SENT
# BEAT=7, RDATA=a5a5f0f0, RLAST=0
# [305] SLAVE: READ DATA SENT
# BEAT=8, RDATA=a5a5f0f0, RLAST=0
# READ DATA BEAT=8 RDATA=a5a5f0f0
# READ DATA BEAT=9 RDATA=a5a5f0f0
# (LAST BEAT) RID=1 RRESP=0
# [315] SLAVE: READ DATA SENT
# BEAT=9, RDATA=a5a5f0f0, RLAST=1
# [315] SLAVE: LAST READ DATA SENT
# ? AXI4 WRITE AND READ COMPLETED
# ** Note: $finish    : testbench.sv(99)
#    Time: 340 ns  Iteration: 0  Instance: /tb
# End time: 05:52:50 on May 15,2026, Elapsed time: 0:00:00
# Errors: 0, Warnings: 0
End time: 05:52:50 on May 15,2026, Elapsed time: 0:00:01
*** Summary *********************************************
    qrun: Errors:   0, Warnings:   0
    vlog: Errors:   0, Warnings:   0
    vopt: Errors:   0, Warnings:   1
    vsim: Errors:   0, Warnings:   0
  Totals: Errors:   0, Warnings:   1
Finding VCD file...
./dump.vcd
