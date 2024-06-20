with Ada.Real_Time;

with Global_Initialization;
with System_Configuration;

with Motor_Prod;                    pragma Unreferenced (Motor_Prod);
with Sonar_DMA;                     pragma Unreferenced (Sonar_DMA);
with Scanner;                       pragma Unreferenced (Scanner);
with Vehicle;                       pragma Unreferenced (Vehicle);

procedure Midero is
   pragma Priority (System_Configuration.Main_Priority);
   use Ada.Real_Time;

begin

   Vehicle.Initialize;
   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
   end loop;
end Midero;
