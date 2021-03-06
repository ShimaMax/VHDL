Library IEEE, work;
Use IEEE.std_logic_1164.all;
Use work.package1.all;
Use STD.textio.all;

entity test is
end test;

architecture struct of test is

component model is
	port(clk : in std_logic;
		start_eat : in eat_arr;
		ant : out ant_arr);
end component;

signal clk : std_logic;
signal eat : eat_arr;
signal ant : ant_arr;
signal initialize, Eatinitialize: std_logic := '0';

begin
	
	p1 : model port map (clk, eat, ant);

	log_process: process(clk)
		variable indata_line : line;
		file input_data_file : text open read_mode is "input_data_file.txt";
		variable outdata_line : line;
		file output_data_file : text open write_mode is "output_data_file.txt";
		variable tmp_eat : bit_vector(0 to MATRIX_SIZE-1-2);
	begin

		if(Eatinitialize = '0') then

			for i in 0 to MATRIX_SIZE-1-2 loop
			    readline (input_data_file, indata_line);
			    read (indata_line, tmp_eat);
			    eat(i) <= To_StdLogicVector(tmp_eat);
			    Eatinitialize <= '1';
			end loop;

		end if;

		if(clk'event and clk = '1') then

			-- log initialize
			if(initialize = '0') then
				initialize <= '1';
				-- first line in a file: Elements count: (MATRIX_SIZE-2)^2 - eat, 0 - false, 1 - true
				for i in 0 to MATRIX_SIZE-1-2 loop
					for j in 0 to MATRIX_SIZE-1-2 loop
						if(eat(i)(j) = '1') then
							write(outdata_line, 1);
						else
							write(outdata_line, 0);
						end if;
						write(outdata_line, string'(" "));
					end loop;
				end loop;
				writeline(output_data_file,outdata_line);
				-- second line in a file: Elements count: (MATRIX_SIZE)^2 - pheromone
				for i in 0 to MATRIX_SIZE-1 loop
					for j in 0 to MATRIX_SIZE-1 loop
						if(i = 0 or j = 0 or i = MATRIX_SIZE-1 or j = MATRIX_SIZE-1) then
							write(outdata_line, string'("-1 "));
						else
							write(outdata_line, string'("0 "));
						end if;
					end loop;
				end loop;
				writeline(output_data_file,outdata_line);
			
			elsif(initialize = '1') then
				write(outdata_line,ant(0));
				write(outdata_line,string'(" "));
				write(outdata_line,ant(1));
				writeline(output_data_file,outdata_line);
			end if;
		end if;
	end process;

end struct;
