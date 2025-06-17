----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/16/2025 10:35:51 AM
-- Design Name:
-- Module Name: registres_z - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registres_z is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           -- Writing Data (synchronous)
           i_WE : in STD_LOGIC;                           -- Write Enable
           i_Wr_DAT : in STD_LOGIC_VECTOR (127 downto 0); -- Data to write, written when WE is true.
           i_WDest : in STD_LOGIC_VECTOR (4 downto 0);    -- Destination register where Wr_DAT is written.
           -- Reading Data (async)
           i_RS1 : in STD_LOGIC_VECTOR (4 downto 0);         -- From Operand A (rs in all cases)
           i_RS2 : in STD_LOGIC_VECTOR (4 downto 0);         -- From Operand B (rt in all cases)
           o_RS1_DAT : out STD_LOGIC_VECTOR (127 downto 0);  -- To Operand A (data stored in rs)
           o_RS2_DAT : out STD_LOGIC_VECTOR (127 downto 0)); -- To Operand B (data stored in rt)
end registres_z;

architecture comport of registres_z is
    signal regs: RAM(0 to 31) := (others => (others => '0')); -- pas de sp comme dans registre standard. Ce banc de registre la est juste pour des vecteurs.
    signal destination : std_logic_vector(4 downto 0);
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);

begin

  -- Vector address needs to be multiplied by 4.
  destination <= std_logic_vector( unsigned(i_WDest) sll 2 );
  rs1         <= std_logic_vector( unsigned(i_RS1) sll 2 );
  rs2         <= std_logic_vector( unsigned(i_RS2) sll 2 );

  process( clk )
  begin
    if clk='1' and clk'event then
        if i_WE = '1' and reset = '0' and destination /= "000000" then
          regs( to_integer( unsigned(destination))+3) <= i_Wr_DAT(31 downto 0);
          regs( to_integer( unsigned(destination))+2) <= i_Wr_DAT(63 downto 32);
          regs( to_integer( unsigned(destination))+1) <= i_Wr_DAT(95 downto 64);
          regs( to_integer( unsigned(destination))+0) <= i_Wr_DAT(127 downto 96);
        end if; -- Write-enable
    end if; -- clk
  end process;

  process(i_RS1,i_RS2,regs, clk, i_WE, i_Wr_DAT, i_WDest)
  begin

    if (unsigned(rs1) <= 28) then
      o_RS1_DAT <= regs(to_integer(unsigned(rs1))+3) &
                   regs(to_integer(unsigned(rs1))+2) &
                   regs(to_integer(unsigned(rs1))+1) &
                   regs(to_integer(unsigned(rs1))+0) ;
    else
      o_RS1_DAT <= (others => '0');
    end if;


    if (unsigned(rs2) <= 28)  then
    o_RS2_DAT <= regs(to_integer(unsigned(rs2))+3) &
                 regs(to_integer(unsigned(rs2))+2) &
                 regs(to_integer(unsigned(rs2))+1) &
                 regs(to_integer(unsigned(rs2))+0) ;
    else
      o_RS2_DAT <= (others => '0');
    end if;
end process;

end comport;
