-- project_reti_logiche.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        i_start     : in  std_logic;
        i_add       : in  std_logic_vector(15 downto 0);
        i_k         : in  std_logic_vector(9 downto 0);
        
        o_done      : out std_logic;

        o_mem_addr  : out std_logic_vector(15 downto 0);     
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal r3_load : STD_LOGIC;
signal r4_load : STD_LOGIC;
signal r5_load : STD_LOGIC;
signal r1_is0 : STD_LOGIC;
signal r2_is0 : STD_LOGIC;
signal k_is0 : STD_LOGIC;
signal k_sel : STD_LOGIC;
signal add_sel: STD_LOGIC_VECTOR(1 downto 0);
signal write_sel: STD_LOGIC;

component address_calc is
    Port (
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_add: in STD_LOGIC_VECTOR(15 downto 0);
        add_sel: in STD_LOGIC_VECTOR(1 downto 0);
        r5_load: in STD_LOGIC;
        o_addr_res: out STD_LOGIC_VECTOR(15 downto 0)
    );
end component address_calc;

component k_calc is
    Port( 
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_k: in STD_LOGIC_VECTOR(9 downto 0);
        k_sel: in STD_LOGIC;
        r4_load: in STD_LOGIC;
        k_is0: out STD_LOGIC
    );
end component k_calc;

component datapath is
    Port ( 
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_mem_data: in STD_LOGIC_VECTOR(7 downto 0);
        r1_load: in STD_LOGIC;
        r2_load: in STD_LOGIC;
        r3_load: in STD_LOGIC;
        write_sel: in STD_LOGIC;
        r1_is0: out STD_LOGIC;
        r2_is0: out STD_LOGIC;
        o_mem_data: out STD_LOGIC_VECTOR(7 downto 0)
    );
end component datapath;

component fsm is
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_start: in STD_LOGIC;
        
        o_done: out STD_LOGIC;
        o_mem_en: out STD_LOGIC;
        o_mem_we: out STD_LOGIC;
        
        r1_load: out STD_LOGIC;
        r2_load: out STD_LOGIC;
        r3_load: out STD_LOGIC;
        r4_load: out STD_LOGIC;
        r5_load: out STD_LOGIC;
        
        r1_is0: in STD_LOGIC;
        r2_is0: in STD_LOGIC;
        k_is0: in STD_LOGIC;
        
        k_sel: out STD_LOGIC;
        add_sel: out STD_LOGIC_VECTOR(1 downto 0);
        write_sel: out STD_LOGIC
    );
end component fsm;

begin
    ADDRESS_C: address_calc port map(
        i_clk,
        i_rst,
        i_add => i_add,
        add_sel => add_sel,
        r5_load => r5_load,
        o_addr_res => o_mem_addr
    );
    K_C: k_calc port map(
        i_clk,
        i_rst,
        i_k => i_k,
        k_sel => k_sel,
        r4_load => r4_load,
        k_is0 => k_is0
    );
    DATA_PATH: datapath port map(
        i_clk,
        i_rst,
        i_mem_data => i_mem_data,
        o_mem_data => o_mem_data,
        r1_load => r1_load,
        r2_load => r2_load,
        r3_load => r3_load,
        write_sel => write_sel,
        r1_is0 => r1_is0,
        r2_is0 => r2_is0
    );
    FsMs: fsm port map(
        i_clk,
        i_rst,
        i_start => i_start,
        o_done => o_done,
        o_mem_en => o_mem_en,
        o_mem_we => o_mem_we,
        r1_load => r1_load,
        r2_load => r2_load,
        r3_load => r3_load,
        r4_load => r4_load,
        r5_load => r5_load,
        r1_is0 => r1_is0,
        r2_is0 => r2_is0,
        k_is0 => k_is0,
        k_sel => k_sel,
        add_sel => add_sel,
        write_sel => write_sel
    );
end project_reti_logiche_arch;

-- address_calc.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity address_calc is
    Port (
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_add: in STD_LOGIC_VECTOR(15 downto 0);
        add_sel: in STD_LOGIC_VECTOR(1 downto 0);
        r5_load: in STD_LOGIC;
        o_addr_res: out STD_LOGIC_VECTOR(15 downto 0)
    );
end address_calc;

architecture address_calc_arch of address_calc is
signal mux5 : std_logic_vector(15 downto 0);
signal res5 : std_logic_vector(15 downto 0);
signal add1 : std_logic_vector(15 downto 0);
signal add2 : std_logic_vector(15 downto 0);

begin
    o_addr_res <= res5;
    with add_sel select
        mux5 <= i_add when "01", -- starting address
                add1 when "11", -- add 1
                add2 when "00", -- add 2
                "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            res5 <= "0000000000000000";
        elsif falling_edge(i_clk) then
            if(r5_load = '1') then
                res5 <= mux5;
            end if;
        end if;
    end process;
    
    add1 <= std_logic_vector(unsigned(res5) + 1);
    add2 <= std_logic_vector(unsigned(res5) + 2);
end address_calc_arch;

-- k_calc.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity k_calc is
    Port( 
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_k: in STD_LOGIC_VECTOR(9 downto 0);
        k_sel: in STD_LOGIC;
        r4_load: in STD_LOGIC;
        k_is0: out STD_LOGIC
    );
end k_calc;

architecture k_calc_arch of k_calc is
signal mux4 : std_logic_vector(9 downto 0);
signal minus1 : std_logic_vector(9 downto 0);
signal res4 : std_logic_vector(9 downto 0);

begin
    with k_sel select
        mux4 <= i_k when '0',
                minus1 when '1',
                "XXXXXXXXXX" when others;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            res4 <= "XXXXXXXXXX";
        elsif falling_edge(i_clk) then
            if(r4_load = '1') then
                res4 <= mux4;
                minus1 <= std_logic_vector(unsigned(mux4) - 1);
            end if;
        end if;
    end process;
    
    k_is0 <= '1' when (res4 = "0000000000") else '0';

end k_calc_arch;

-- datapath.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity datapath is
    Port ( 
        i_clk: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_mem_data: in STD_LOGIC_VECTOR(7 downto 0);
        r1_load: in STD_LOGIC;
        r2_load: in STD_LOGIC;
        r3_load: in STD_LOGIC;
        write_sel: in STD_LOGIC;
        r1_is0: out STD_LOGIC;
        r2_is0: out STD_LOGIC;
        o_mem_data: out STD_LOGIC_VECTOR(7 downto 0)
    );
end datapath;

architecture datapath_arch of datapath is
signal reg1: std_logic_vector(7 downto 0);
signal reg2: std_logic_vector(7 downto 0);
signal reg3: std_logic_vector(4 downto 0);
signal r1_0: std_logic;
signal r2_0: std_logic;
signal r3_0: std_logic_vector(1 downto 0);
signal mux3: std_logic_vector(4 downto 0);
signal mux3_sel: std_logic_vector(1 downto 0);
signal minus1: std_logic_vector(4 downto 0);


begin
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            reg1 <= "00000000";
                elsif falling_edge(i_clk) then
                    if(r1_load = '1') then
                        reg1 <= i_mem_data;
                    end if;
                end if;
    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            reg2 <= "00000000";
                elsif falling_edge(i_clk) then
                    if(r2_load = '1') then
                        reg2 <= reg1;
                    end if;
                end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            reg3 <= "00000";
                elsif falling_edge(i_clk) then
                    if(r3_load = '1') then
                        reg3 <= mux3;
                    end if;
                end if;
    end process;


    with write_sel select
        o_mem_data <= reg2 when '0',
                      ("000" & reg3) when '1',
                      "XXXXXXXX" when others;
                      
    with mux3_sel select
        mux3 <= "11111" when "00",
                minus1 when "01",
                "00000" when "11",
                "11111" when "10",
                "XXXXX" when others;
    minus1 <= std_logic_vector(unsigned(reg3) - 1);
    
    r1_0 <= '1' when (reg1 = "00000000") else '0';
    r2_0 <= '1' when (reg2 = "00000000") else '0';
    r3_0 <=     "00" when (r2_0 = '0' and r1_0 = '0')
                else "11" when ((r2_0 = '1' and r1_0 = '1') or reg3 = "00000")
                else "01" when (r2_0 = '0' and r1_0 = '1')
                else "XX"; -- ?

    r1_is0 <= r1_0;
    r2_is0 <= r2_0;
    
    mux3_sel <= (r2_0 & r1_0) or r3_0;
    
    
end datapath_arch;

-- fsm.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_start: in STD_LOGIC;
        
        o_done: out STD_LOGIC;
        o_mem_en: out STD_LOGIC;
        o_mem_we: out STD_LOGIC;
        
        r1_load: out STD_LOGIC;
        r2_load: out STD_LOGIC;
        r3_load: out STD_LOGIC;
        r4_load: out STD_LOGIC;
        r5_load: out STD_LOGIC;
        
        r1_is0: in STD_LOGIC;
        r2_is0: in STD_LOGIC;
        k_is0: in STD_LOGIC;
        
        k_sel: out STD_LOGIC;
        add_sel: out STD_LOGIC_VECTOR(1 downto 0);
        write_sel: out STD_LOGIC
    );
end fsm;

architecture fsm_arch of fsm is

type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13);

signal cur_state, next_state : S;

begin
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(i_clk, i_rst, i_start, r1_is0, r2_is0, k_is0, cur_state)
    begin
        next_state <= cur_state; -- evitiamo latch
        case cur_state is
            when S0 =>
                if(i_start = '1') then 
                    next_state <= S1;
                end if;
            when S1 =>
                if(k_is0 = '1') then 
                    next_state <= S13;
                else
                    next_state <= S2;
                end if;
            when S2 =>
                next_state <= S3;
            when S3 => next_state <= S4;
            when S4 =>
                if(k_is0 = '1') then -- since this has max priority, it may needs to be the first "if" of this "case"
                    next_state <= S13;
                elsif(r1_is0 = '1' and r2_is0 = '1') then -- if both are 0
                    next_state <= S5;
                elsif(r1_is0 = '1' and r2_is0 = '0') then -- if only r1 is 0
                    next_state <= S7;
                else
                    next_state <= S9;
                end if;
            when S5 => next_state <= S6;
            when S6 => next_state <= S4;
            when S9 => next_state <= S7;
            when S7 => next_state <= S8;
            when S8 => next_state <= S10;
            when S10 => next_state <= S11;
            when S11 => next_state <= S12;
            when S12 => next_state <= S4;
            when S13 =>
                if(i_start = '0') then
                    next_state <= S0;
                end if;
        end case;
    end process;

    process(cur_state)
    begin
        -- initialisation (otherwise there are problems)
        o_done <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r5_load <= '0';
        
        add_sel <= "01";
        k_sel <= '0';
        write_sel <= '0';
        
        case cur_state is
            when S0 => report "s0";
            when S1 => 
                report "s1";
                o_mem_en <= '1';
                r5_load <= '1';
                add_sel <= "01";
                r4_load <= '1';
                k_sel <= '0';
            when S2 =>
                report "s2";
                r1_load <= '1';
            when S3 =>
                report "s3";
                r2_load <= '1';
            when S4 => report "s4";
            when S5 => 
                report "s5";
                r2_load <= '1';
                r5_load <= '1';
                r4_load <= '1';
                k_sel <= '1';
                add_sel <= "00";
                o_mem_en <= '1';
            when S6 => 
                report "s6";
                r1_load <= '1';
            when S7 => 
                report "s7";
                r3_load <= '1';
                write_sel <= '0';
                k_sel <= '1';
                r4_load <= '1';
                o_mem_en <= '1';
                o_mem_we <= '1';
            when S8 =>
                report "s8";
                add_sel <= "11";
                r5_load <= '1';
            when S9 =>
                report "s9"; 
                r2_load <= '1';
            when S10 => 
                report "s10";
                write_sel <= '1';
                o_mem_en <= '1';
                o_mem_we <= '1';
            when S11 => 
                report "s11";
                add_sel <= "11";
                r5_load <= '1';
                o_mem_en <= '1';
            when S12 =>
                report "s12";
                r1_load <= '1';
            when S13 => 
                report "s13";
                o_done <= '1';
        end case;
    end process;
end fsm_arch;
