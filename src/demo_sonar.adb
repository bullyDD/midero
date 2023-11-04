with Ada.Real_Time;

with Global_Initialization;
with System_Configuration;

with Sonar;                    pragma Unreferenced (Sonar);
with Vehicle;                  pragma Unreferenced (Vehicle);

procedure Demo_Sonar is

   pragma Priority (System_Configuration.Main_Priority);

   use Ada.Real_Time;

   --Period : constant Time_Span := Milliseconds (1000);
   --Next_Time : Time := Clock + Period;

begin
   Vehicle.Initialize;

   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
      --Next_Time := Next_Time + Period;
   end loop;

end Demo_Sonar;
