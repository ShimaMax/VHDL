entity NO2 is 
port(A, B: in BIT; 
  Y: out BIT); 
end NO2; 

architecture NO2_arch of NO2 is 
begin 
  Y <= (not( A or B )) after 3 ns;
end NO2_arch;