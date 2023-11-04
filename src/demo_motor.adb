with Ada.Real_Time;

with Motor;

procedure Demo_Motor is

   use Ada.Real_Time;
   use Motor;

   Period : constant Time_Span := Milliseconds (150);
   Next_Time : Time := Clock + Period;
   --  Period is a global constant of type Duration

   M1, M2, M3, M4 : Basic_Motor;

begin
   --  Unitary test DC Motor
   --  Initialize basic motors before used them
   Initialize_Motors (M1, M2, M3, M4);
   loop
      delay until Next_Time;
      --  Repeated every 150 milliseconds
      Turn_Motor (M1, M2, M3, M4);
      Next_Time := Next_Time + Period;
   end loop;

end Demo_Motor;
