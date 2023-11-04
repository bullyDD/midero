with Ada.Real_Time;

with Global_Initialization;
with System_Configuration;

--  with Motor;           pragma Unreferenced (Motor);

procedure Midero is
   pragma Priority (System_Configuration.Main_Priority);

   use Ada.Real_Time;

begin
   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
   end loop;
end Midero;
