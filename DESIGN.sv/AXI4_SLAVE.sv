module axi4_slave #(
  parameter ADDR_W=32,
  parameter DATA_W=32,
  parameter ID_WIDTH=4,
  parameter DEPTH=1024
)(
  input logic clk,
  input logic rst,

  output logic awready,
  input logic [ADDR_W-1:0] awaddr,
  input logic awvalid,
  input logic [2:0] awsize,
  input logic [1:0] awburst,
  input logic [7:0] awlen,
  input logic [3:0] awcache,
  input logic [ID_WIDTH-1:0] awid,
  input logic awlock,

  output logic wready,
  input logic [DATA_W-1:0] wdata,
  input logic wvalid,
  input logic wlast,
  input logic [(DATA_W/8)-1:0] wstrb,

  output logic bvalid,
  output logic [ID_WIDTH-1:0] bid,
  output logic [1:0] bresp,
  input logic bready,

  output logic arready,
  input logic [ADDR_W-1:0] araddr,
  input logic arvalid,
  input logic [2:0] arsize,
  input logic [1:0] arburst,
  input logic [7:0] arlen,
  input logic [3:0] arcache,
  input logic [ID_WIDTH-1:0] arid,
  input logic arlock,

  output logic rvalid,
  output logic [ID_WIDTH-1:0] rid,
  output logic [DATA_W-1:0] rdata,
  output logic rlast,
  output logic [1:0] rresp,
  input logic rready
);

  reg [DATA_W-1:0] mem[0:DEPTH-1];

  localparam BYTES_PER_BEAT = DATA_W/8;
  localparam BYTE_ADDRESSING = $clog2(BYTES_PER_BEAT);
  localparam R_OKAY = 2'b00;
  localparam R_SLVERR = 2'b10;

  logic [ID_WIDTH-1:0] write_id;
  logic [ADDR_W-1:0] write_addr;
  logic [ADDR_W-1:0] write_cur_addr;
  logic [7:0] write_len;
  logic [2:0] write_size;
  logic [1:0] write_burst;
  logic [7:0] write_beat;
  logic [1:0] write_resp;

  logic [ID_WIDTH-1:0] read_id;
  logic [ADDR_W-1:0] read_addr;
  logic [ADDR_W-1:0] read_cur_addr;
  logic [7:0] read_len;
  logic [2:0] read_size;
  logic [1:0] read_burst;
  logic [7:0] read_beat;

  typedef enum logic [1:0]{W_IDLE=2'b00,W_DATA=2'b01,W_RESP=2'b10} write_state_t;

  typedef enum logic [1:0]{R_IDLE=2'b00,R_DATA=2'b01} read_state_t;

  write_state_t w_state, w_next;
  read_state_t r_state, r_next;

  function automatic logic [ADDR_W-1:0] next_address(
    input logic [ADDR_W-1:0] curr_addr,
    input logic [1:0] burst_type,
    input logic [2:0] size,
    input logic [7:0] len,
    input logic [ADDR_W-1:0] start_addr
  );
    logic [ADDR_W-1:0] bytes_per_beat;
    logic [ADDR_W-1:0] wrap_mask;
    logic [ADDR_W-1:0] wrap_base;

    bytes_per_beat = 1 << size;

    case(burst_type)
      2'b00: begin
        next_address = curr_addr;
      end
      2'b01: begin
        next_address = curr_addr + bytes_per_beat;
      end
      2'b10: begin
        wrap_mask = ((len + 1) * bytes_per_beat) - 1;
        wrap_base = start_addr & ~wrap_mask;
        next_address = wrap_base | ((curr_addr + bytes_per_beat) & wrap_mask);
      end
      default: begin
        next_address = curr_addr + bytes_per_beat;
      end
    endcase
  endfunction

  function automatic logic addr_valid(
    input logic [ADDR_W-1:0] addr
  );
    logic [ADDR_W-1:0] mem_addr;
    mem_addr = addr >> BYTE_ADDRESSING;
    return (mem_addr < DEPTH);
  endfunction

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      w_state <= W_IDLE;
    end else begin
      w_state <= w_next;
    end
  end

  always_comb begin
    w_next = w_state;
    awready = 1'b0;

    case(w_state)
      W_IDLE: begin
        awready = 1'b1;
        if(awvalid)
          w_next = W_DATA;
      end
      W_DATA: begin
        if(wvalid && wready && wlast)
          w_next = W_RESP;
      end
      W_RESP: begin
        if(bvalid && bready)
          w_next = W_IDLE;
      end
      default: w_next = W_IDLE;
    endcase
  end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      write_id <= 0;
      write_addr <= 0;
      write_cur_addr <= 0;
      write_len <= 0;
      write_size <= 0;
      write_burst <= 0;
      write_beat <= 0;
      write_resp <= R_OKAY;
      bid <= 0;
      bresp <= 0;
      bvalid <= 0;
    end else begin
      case(w_state)
        W_IDLE: begin
          bvalid <= 1'b0;
          if(awvalid && awready) begin
            write_id <= awid;
            write_addr <= awaddr;
            write_cur_addr <= awaddr;
            write_len <= awlen;
            write_size <= awsize;
            write_burst <= awburst;
            write_beat <= 0;
            if(addr_valid(awaddr))
              write_resp <= R_OKAY;
            else
              write_resp <= R_SLVERR;
            $display("[%0t] SLAVE: WRITE ADDRESS RECEIVED",$time);
            $display("AWID=%0d, AWADDR=%h, AWLEN=%0d",awid,awaddr,awlen);
          end
        end
        W_DATA: begin
          if(wvalid && wready) begin
            if(addr_valid(write_cur_addr)) begin
              for(int i=0; i<BYTES_PER_BEAT; i=i+1) begin
                if(wstrb[i]) begin
                  mem[write_cur_addr >> BYTE_ADDRESSING][i*8+:8] <= wdata[i*8+:8];
                end
              end
            end else begin
              write_resp <= R_SLVERR;
            end
            $display("[%0t] SLAVE: WRITE DATA RECEIVED",$time);
            $display("BEAT=%0d, WDATA=%h, WSTRB=%b, WLAST=%b",write_beat,wdata,wstrb,wlast);
            if(wlast) begin
              bvalid <= 1'b1;
              bid <= write_id;
              bresp <= write_resp;
              $display("[%0t] SLAVE: LAST WRITE DATA RECEIVED",$time);
            end else begin
              write_cur_addr <= next_address(write_cur_addr,write_burst,write_size,write_len,write_addr);
            end
            write_beat <= write_beat + 1;
          end
        end
        W_RESP: begin
          if(bvalid && bready) begin
            bvalid <= 1'b0;
            $display("[%0t] SLAVE: WRITE RESPONSE SENT",$time);
            $display("BID=%0d, BRESP=%0b",bid,bresp);
          end
        end
      endcase
    end
  end

  assign wready = (w_state == W_DATA);

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      r_state <= R_IDLE;
    end else begin
      r_state <= r_next;
    end
  end

  always_comb begin
    r_next = r_state;
    arready = 1'b0;

    case(r_state)
      R_IDLE: begin
        arready = 1'b1;
        if(arvalid)
          r_next = R_DATA;
      end
      R_DATA: begin
        if(rvalid && rready && rlast)
          r_next = R_IDLE;
      end
      default: r_next = R_IDLE;
    endcase
  end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      read_id <= 0;
      read_addr <= 0;
      read_cur_addr <= 0;
      read_len <= 0;
      read_size <= 0;
      read_burst <= 0;
      read_beat <= 0;
      rid <= 0;
      rresp <= R_OKAY;
      rvalid <= 0;
      rdata <= 0;
      rlast <= 0;
    end else begin
      case(r_state)
        R_IDLE: begin
          rvalid <= 1'b0;
          rlast <= 1'b0;
          if(arvalid && arready) begin
            read_id <= arid;
            read_addr <= araddr;
            read_cur_addr <= araddr;
            read_len <= arlen;
            read_size <= arsize;
            read_burst <= arburst;
            read_beat <= 0;
            $display("[%0t] SLAVE: READ ADDRESS RECEIVED",$time);
            $display("ARID=%0d, ARADDR=%h, ARLEN=%0d",arid,araddr,arlen);
          end
        end
        R_DATA: begin
          rid <= read_id;
          if(addr_valid(read_cur_addr)) begin
            rdata <= mem[read_cur_addr >> BYTE_ADDRESSING];
            rresp <= R_OKAY;
          end else begin
            rdata <= 32'h0;
            rresp <= R_SLVERR;
          end
          if(read_beat == read_len)
            rlast <= 1'b1;
          else
            rlast <= 1'b0;
          rvalid <= 1'b1;
          if(rvalid && rready) begin
            $display("[%0t] SLAVE: READ DATA SENT",$time);
            $display("BEAT=%0d, RDATA=%h, RLAST=%b",read_beat,rdata,rlast);
            if(rlast) begin
              rvalid <= 1'b0;
              rlast <= 1'b0;
              $display("[%0t] SLAVE: LAST READ DATA SENT",$time);
            end else begin
              read_cur_addr <= next_address(read_cur_addr,read_burst,read_size,read_len,read_addr);
            end
            read_beat <= read_beat + 1;
          end
        end
      endcase
    end
  end

endmodule

    
  

  
