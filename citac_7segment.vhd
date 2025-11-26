--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--
--entity citac is
--generic (modulo : integer :=9);
--port (clock,reset,enable : in std_logic;
-- prenos : out std_logic;
-- stav : buffer std_logic_vector(3 downto 0));
--end citac;
--
--architecture Behavioral of citac is
--begin
--process (clock,reset)
--begin
--if reset = '0' then
--	stav <= (others=>'0'); -- zde doplnte nulovani citace
--elsif clock='0' and clock'event then
--	if enable='1' then
--		if unsigned(stav) = modulo or unsigned(stav) = 9 then
--			stav <= (others=>'0'); -- zde doplnte nulovani citace
--			prenos <= '0'; -- zde doplnte nastaveni prenosu na '0'
--		else
--			stav <= std_logic_vector(unsigned(stav)+1); -- zde doplnte stav+1
--			prenos <= '1'; -- zde doplnte nastaveni prenosu na '1'
--		end if;
--	end if;
--end if;
--end process;
--end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity citac_7segment is
    port (
        Clock  : in  std_logic;
        Reset  : in  std_logic;
        Stop   : in  std_logic;
        digit1 : out std_logic_vector(6 downto 0);  -- units
        digit2 : out std_logic_vector(6 downto 0)   -- tens
    );
end citac_7segment;

architecture Structural of citac_7segment is

    -- Signály
    signal citej    : std_logic := '1';
    signal stav1    : std_logic_vector(3 downto 0);
    signal stav2    : std_logic_vector(3 downto 0);
    signal prenos12 : std_logic;

    -- Deklarace komponenty čítače
    component citac is
        generic (modulo : integer := 9);
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            enable : in  std_logic;
            down   : in  std_logic;  -- přidaný signál pro směr
            prenos : out std_logic;
            stav   : buffer std_logic_vector(3 downto 0)
        );
    end component;

    -- Deklarace komponenty BCD → 7segment
    component BCD7segmentVHDL is
        port (
            a, b, c, d : in  std_logic;
            s0, s1, s2, s3, s4, s5, s6 : out std_logic
        );
    end component;

begin

    --------------------------------------------------------------------
    -- Čítač pro jednotky sekund
    --------------------------------------------------------------------
    citac_1: citac
        generic map(9)
        port map(
            clock  => Clock,
            reset  => Reset,
            enable => citej,
            down   => '1',     -- COUNT DOWN MODE
            prenos => prenos12,
            stav   => stav1
        );

    --------------------------------------------------------------------
    -- Čítač pro desítky sekund
    --------------------------------------------------------------------
    citac_2: citac
        generic map(5)
        port map(
            clock  => prenos12,
            reset  => Reset,
            enable => citej,
            down   => '1',     -- COUNT DOWN MODE
            prenos => open,
            stav   => stav2
        );

    --------------------------------------------------------------------
    -- Dekodér pro jednotky sekund
    --------------------------------------------------------------------
    displej_1: BCD7segmentVHDL
        port map (
            a  => stav1(3),
            b  => stav1(2),
            c  => stav1(1),
            d  => stav1(0),
            s0 => digit1(0),
            s1 => digit1(1),
            s2 => digit1(2),
            s3 => digit1(3),
            s4 => digit1(4),
            s5 => digit1(5),
            s6 => digit1(6)
        );

    --------------------------------------------------------------------
    -- Dekodér pro desítky sekund
    --------------------------------------------------------------------
    displej_2: BCD7segmentVHDL
        port map (
            a  => stav2(3),
            b  => stav2(2),
            c  => stav2(1),
            d  => stav2(0),
            s0 => digit2(0),
            s1 => digit2(1),
            s2 => digit2(2),
            s3 => digit2(3),
            s4 => digit2(4),
            s5 => digit2(5),
            s6 => digit2(6)
        );

    --------------------------------------------------------------------
    -- Proces pro tlačítko STOP (pauza/spuštění)
    --------------------------------------------------------------------
    process (Stop)
    begin
        if Stop = '0' and Stop'event then
            citej <= not citej; -- přepnutí mezi pauzou a během
        end if;
    end process;

end Structural;
