`include "axi4_master.sv"
`include "axi4_slave.sv"

module axi4_top #(
    parameter ADDR_W   = 32,
    parameter DATA_W   = 32,
    parameter ID_WIDTH = 4
)(

input logic clk,
input logic rst,
input logic start,

input logic [ADDR_W-1:0] o_mas_awaddr,
input logic [2:0]  o_mas_awsize,
input logic [1:0]  o_mas_awburst,
input logic [7:0]  o_mas_awlen,
input logic [3:0]  o_mas_awcache,
input logic [3:0]  o_mas_awid,
input logic        o_mas_awlock,

input logic [DATA_W-1:0] o_mas_wdata,
input logic [3:0]        o_mas_strb,

input logic [ADDR_W-1:0] o_mas_araddr,
input logic [2:0]  o_mas_arsize,
input logic [1:0]  o_mas_arburst,
input logic [7:0]  o_mas_arlen,
input logic [3:0]  o_mas_arcache,
input logic [ID_WIDTH-1:0] o_mas_arid,
input logic        o_mas_arlock);

logic awready;
logic [ADDR_W-1:0] awaddr;
logic awvalid;
logic [2:0] awsize;
logic [1:0] awburst;
logic [7:0] awlen;
logic [3:0] awcache;
logic [ID_WIDTH-1:0] awid;
logic awlock;

logic wready;
logic [DATA_W-1:0] wdata;
logic wvalid;
logic wlast;
logic [3:0] wstrb;

logic bvalid;
logic [1:0] bresp;
logic [ID_WIDTH-1:0] bid;
logic bready;

logic arready;
logic [ADDR_W-1:0] araddr;
logic arvalid;
logic [2:0] arsize;
logic [1:0] arburst;
logic [7:0] arlen;
logic [3:0] arcache;
logic [ID_WIDTH-1:0] arid;
logic arlock;

logic rvalid;
logic [DATA_W-1:0] rdata;
logic rlast;
logic [1:0] rresp;
logic [ID_WIDTH-1:0] rid;
logic rready;

axi4_master #(
    .ADDR_W(ADDR_W),
    .DATA_W(DATA_W),
    .ID_WIDTH(ID_WIDTH)
)
master_inst(

    .clk(clk),
    .rst(rst),
    .start(start),

    .awready(awready),
    .AWADDR(awaddr),
    .awvalid(awvalid),
    .awsize(awsize),
    .awburst(awburst),
    .awlen(awlen),
    .awcache(awcache),
    .awid(awid),
    .awlock(awlock),

    .o_mas_awaddr(o_mas_awaddr),
    .o_mas_awsize(o_mas_awsize),
    .o_mas_awburst(o_mas_awburst),
    .o_mas_awlen(o_mas_awlen),
    .o_mas_awcache(o_mas_awcache),
    .o_mas_awid(o_mas_awid),
    .o_mas_awlock(o_mas_awlock),

    .wready(wready),
    .WDATA(wdata),
    .wvalid(wvalid),
    .wlast(wlast),
    .wstrb(wstrb),

    .o_mas_wdata(o_mas_wdata),
    .o_mas_strb(o_mas_strb),

    .bvalid(bvalid),
    .bresp(bresp),
    .bid(bid),
    .bready(bready),

    .arready(arready),
    .ARADDR(araddr),
    .arvalid(arvalid),
    .arsize(arsize),
    .arburst(arburst),
    .arlen(arlen),
    .arcache(arcache),
    .arid(arid),
    .arlock(arlock),

    .o_mas_araddr(o_mas_araddr),
    .o_mas_arsize(o_mas_arsize),
    .o_mas_arburst(o_mas_arburst),
    .o_mas_arlen(o_mas_arlen),
    .o_mas_arcache(o_mas_arcache),
    .o_mas_arid(o_mas_arid),
    .o_mas_arlock(o_mas_arlock),

    .rvalid(rvalid),
    .rdata(rdata),
    .rlast(rlast),
    .rresp(rresp),
    .rid(rid),
    .rready(rready));

axi4_slave #(
    .ADDR_W(ADDR_W),
    .DATA_W(DATA_W),
    .ID_WIDTH(ID_WIDTH)
)
slave_inst(

    .clk(clk),
    .rst(~rst),

    .awready(awready),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awsize(awsize),
    .awburst(awburst),
    .awlen(awlen),
    .awcache(awcache),
    .awid(awid),
    .awlock(awlock),

    .wready(wready),
    .wdata(wdata),
    .wvalid(wvalid),
    .wlast(wlast),
    .wstrb(wstrb),

    .bvalid(bvalid),
    .bid(bid),
    .bresp(bresp),
    .bready(bready),

    .arready(arready),
    .araddr(araddr),
    .arvalid(arvalid),
    .arsize(arsize),
    .arburst(arburst),
    .arlen(arlen),
    .arcache(arcache),
    .arid(arid),
    .arlock(arlock),

    .rvalid(rvalid),
    .rid(rid),
    .rdata(rdata),
    .rlast(rlast),
    .rresp(rresp),
    .rready(rready)

);

endmodule
