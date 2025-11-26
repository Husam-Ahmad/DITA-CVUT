--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--entity citac_7segment is
--port (Clock,Reset,Stop : in std_logic;
-- digit1, digit2 : out std_logic_vector(6 downto 0));-- zde doplnte deklaraci portu
--end citac_7segment;
--
--architecture Structural of citac_7segment is
---- zde doplnte deklaraci signalu stav1, stav2, prenos12
--signal citej : std_logic :='1';
--signal stav1 : std_logic_vector(3 downto 0);
--signal stav2 : std_logic_vector(3 downto 0);
--signal prenos12 : std_logic;
--
--component citac is
--generic (modulo : integer :=9); -- zde doplnte deklaraci komponenty citac
--port(clock,reset,enable : in std_logic;
-- prenos : out std_logic;
-- stav : buffer std_logic_vector(3 downto 0));
--end component;
--
--component BCD7segmentVHDL is
--port (a,b,c,d : in std_logic;
--s0,s1,s2,s3,s4,s5,s6 : out std_logic);
--end component;
--
--begin
--citac_1: citac -- pouziti komponenty citac pro jednotky sekund
--generic map(9) -- mapovani generic parametru modulo = 9
--port map(Clock,Reset,Stop,prenos12,stav1); -- mapovani portu
--citac_2: citac -- pouziti komponenty citac pro desitky sekund
--generic map(5) -- obdobne vytvorte mapovani citace desitek sekund
--port map(clock => prenos12,
--reset => Reset,
--enable => Stop,
--stav => stav2);
--
--displej_1: BCD7segmentVHDL
--port map (stav1(3),stav1(2),stav1(1),stav1(0),digit1(0),digit1(1),digit1(2),digit1(3),digit1(4),digit1(5),digit1(6));
--displej_2: BCD7segmentVHDL
--port map (stav2(3),stav2(2),stav2(1),stav2(0),digit2(0),digit2(1),digit2(2),digit2(3),digit2(4),digit2(5),digit2(6));
--
--process(stop) -- proces detekce stisknuti tlacitka Stop
--begin
--if stop='0' and stop'event then
--	citej<=not citej; -- po stisku tlacitka Stop dojde k invertovani hodnoty signalu citej, ktery ovlada enable vstupy
--end if;
--end process;
--end Structural;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity citac is
    generic (modulo : integer := 9);
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        down   : in  std_logic;  -- NEW: 1 = count down, 0 = count up
        prenos : out std_logic;
        stav   : buffer std_logic_vector(3 downto 0)
    );
end citac;

architecture Behavioral of citac is
begin
    process (clock, reset)
    begin
        if reset = '0' then
            stav   <= (others => '0');
            prenos <= '1';
        elsif clock = '0' and clock'event then
            if enable = '1' then
                if down = '1' then  
                    if unsigned(stav) = 0 then
                        stav   <= std_logic_vector(to_unsigned(modulo, 4));
                        prenos <= '0';
                    else
                        stav   <= std_logic_vector(unsigned(stav) - 1);
                        prenos <= '1';
                    end if;
                else                
                    if unsigned(stav) = modulo then
                        stav   <= (others => '0');
                        prenos <= '0';
                    else
                        stav   <= std_logic_vector(unsigned(stav) + 1);
                        prenos <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
