module axi4_master#(parameter ADDR_W=32, DATA_W=32, ID_WIDTH=4)(
input  logic clk,
input  logic rst,
input  logic start,

// Write Address Channel
input  logic awready,
  output logic [ADDR_W-1:0] AWADDR,
output logic awvalid,
output logic [2:0] awsize,
output logic [1:0] awburst,
output logic [7:0] awlen,
output logic [3:0] awcache,
  output logic [ID_WIDTH-1:0] awid,
output logic awlock,

  input logic [ADDR_W-1:0] o_mas_awaddr,
input logic [2:0]  o_mas_awsize,
input logic [1:0]  o_mas_awburst,
input logic [7:0]  o_mas_awlen,
input logic [3:0]  o_mas_awcache,
input logic [3:0]  o_mas_awid,
input logic        o_mas_awlock,

// Write Data Channel
input  logic wready,
  output logic [DATA_W-1:0] WDATA,
output logic wvalid,
output logic wlast,
output logic [3:0] wstrb,

  input logic [DATA_W-1:0] o_mas_wdata,
input logic [3:0]  o_mas_strb,

// Response Channel Write
input  logic bvalid,
input  logic [1:0] bresp,
  input  logic [ID_WIDTH-1:0] bid,   
output logic bready,

// Read Address Channel
input  logic arready,
  output logic [ADDR_W-1:0] ARADDR,
output logic arvalid,
output logic [2:0] arsize,
output logic [1:0] arburst,
output logic [7:0] arlen,
output logic [3:0] arcache,
  output logic [ID_WIDTH-1:0] arid,
output logic arlock,

  input logic [ADDR_W-1:0] o_mas_araddr,
input logic [2:0]  o_mas_arsize,
input logic [1:0]  o_mas_arburst,
input logic [7:0]  o_mas_arlen,
input logic [3:0]  o_mas_arcache,
  input logic [ID_WIDTH-1:0]  o_mas_arid,
input logic        o_mas_arlock,

// Read Data Channel
input  logic rvalid,
  input  logic [DATA_W-1:0] rdata,
input  logic rlast,
input  logic [1:0] rresp,
  input  logic [ID_WIDTH-1:0] rid, 
output logic rready
);

typedef enum logic [2:0] {IDLE,SEND_AW,SEND_W,BRESP,SEND_AR,READ_DATA,DONE} state_t;
state_t st, ns;

logic [7:0] beat_count;
logic [7:0] stored_awlen;
logic [7:0] stored_arlen;

wire [15:0] total_write_bytes;
wire [15:0] total_read_bytes;

assign total_write_bytes =(1 << o_mas_awsize) * (o_mas_awlen + 1);

  
assign total_read_bytes  =(1 << o_mas_arsize) * (o_mas_arlen + 1);

always_ff @(posedge clk or posedge rst) begin
    if(rst) st <= IDLE;
    else    st <= ns;
end

always_comb begin
    ns = st;
    case(st)
        IDLE:     if(start) ns = SEND_AW;
        SEND_AW:  if(awvalid && awready) ns = SEND_W;
        SEND_W:   if(wvalid && wready && wlast) ns = BRESP;
        BRESP:    if(bvalid && bready) ns = SEND_AR;
        SEND_AR:  if(arvalid && arready) ns = READ_DATA;
        READ_DATA:if(rvalid && rready && rlast) ns = DONE;
        DONE:     ns = IDLE;
        default:  ns = IDLE;
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        AWADDR<=0;awvalid<=0;awsize<=0;awburst<=0;awlen<=0;awcache<=0;awid<=0;awlock<=0;
        WDATA<=0;wvalid<=0;wlast<=0;wstrb<=0;
        bready<=0;
        ARADDR<=0;arvalid<=0;arsize<=0;arburst<=0;arlen<=0;arcache<=0;arid<=0;arlock<=0;
        rready<=0;
        beat_count<=0;stored_awlen<=0;stored_arlen<=0;
    end else begin
        awvalid<=0;wvalid<=0;wlast<=0;bready<=0;arvalid<=0;rready<=0;
        case(st)
        SEND_AW: begin
            awvalid<=1;
            AWADDR<=o_mas_awaddr;
          awsize<=o_mas_awsize;
          awburst<=o_mas_awburst;
          awlen<=o_mas_awlen;
            awcache<=o_mas_awcache;
          awid<=o_mas_awid;
          awlock<=o_mas_awlock;
            if(awvalid && awready) begin
                stored_awlen<=o_mas_awlen;
              beat_count<=0;
                $display("WRITE ADDRESS HANDSHAKE: AWADDR=%h AWLEN=%0d TOTAL WRITE BYTES=%0d",o_mas_awaddr,o_mas_awlen,total_write_bytes);
            end
        end
        SEND_W: begin
            wvalid<=1;
          WDATA<=o_mas_wdata;
          wstrb<=o_mas_strb;
            if(beat_count==stored_awlen)
              wlast<=1; 
          else
            wlast<=0;
            if(wvalid && wready) begin
                $display("WRITE DATA BEAT=%0d WDATA=%h WSTRB=%0b",beat_count,WDATA,wstrb);
                if(wlast) $display("(LAST BEAT)");
                beat_count<=beat_count+1;
            end
        end
        BRESP: begin
            bready<=1;
            if(bvalid && bready) $display("WRITE RESPONSE RECEIVED BID=%0d BRESP=%0d",bid,bresp);
        end
        SEND_AR: begin
            arvalid<=1;
            ARADDR<=o_mas_araddr;
          arsize<=o_mas_arsize;
          arburst<=o_mas_arburst;
          arlen<=o_mas_arlen;
            arcache<=o_mas_arcache;
          arid<=o_mas_arid;
          arlock<=o_mas_arlock;
            if(arvalid && arready) begin
                stored_arlen<=o_mas_arlen;
              beat_count<=0;
                $display("READ ADDRESS HANDSHAKE: ARADDR=%h ARLEN=%0d TOTAL READ BYTES=%0d",o_mas_araddr,o_mas_arlen,total_read_bytes);
            end
        end
        READ_DATA: begin
            rready<=1;
            if(rvalid && rready) begin
                $display("READ DATA BEAT=%0d RDATA=%h",beat_count,rdata);
                if(rlast) $display("(LAST BEAT) RID=%0d RRESP=%0d",rid,rresp);
                beat_count<=beat_count+1;
            end
        end
        DONE: $display("✓ AXI4 WRITE AND READ COMPLETED");
        endcase
    end
end
endmodule
