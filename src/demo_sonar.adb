with Ada.Real_Time;
with Sonar;        pragma Unreferenced (Sonar);

procedure Demo_Sonar is

   use Ada.Real_Time;

begin
   loop
      delay until Time_Last;
   end loop;

end Demo_Sonar;
