function I2=Calibrate(SC,I1)

I2=I1; % Default if none of the projects below are recognised.

if(strcmp(SC.PRO,'Cassini'))
  I2 = CalLP_Cassini(I1);
end
