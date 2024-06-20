with Ada.Real_Time;

with Global_Initialization;
with Motor_Prod;
with Position_Manager;
with Sonar_DMA;
with Scanner;
with System_Configuration;
with Lcd_Out;

package body Vehicle is
   
   use Ada.Real_Time;
   use Motor_Prod;
   use Position_Manager;

   M1, M2, M3, M4 : Basic_Motor;
   
   Distance_Limit : constant Float := 40.0;
   
   Period : constant Time_Span := 
      Milliseconds (System_Configuration.Vehicle_Period);
   
   task Controller 
      with
         Priority => System_Configuration.Vehicle_Priority;

   ----------------
   -- Controller --
   ----------------
   
   task body Controller is
      Next_Time               : Time;
      Dist                    : Float;
      Current_Posi, Last_Posi : Float := 0.0;
      Average_Posi            : Float := 0.0;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Time);

      Collision_Check:
      loop         
         -- Get distance from obstacle
         Dist := Sonar_DMA.Get_Distance;     
         Position_Manager.Get_Samples (M1, M2, M3, M4);
     
         if Dist < Distance_Limit then
            Motor_Prod.Set_Internal_State (Braking);
         else
            Motor_Prod.Set_Internal_State (Running);
         end if;
         
         Motor_Prod.Turn_Motor (M1, M2, M3, M4);

         for I in 1 ..4 loop
            Average_Posi := Average_Posi + Position_Manager.Get_Current_Position (I);
         end loop;

         Current_Posi := Average_Posi / 4.0;

         if Current_Posi - Last_Posi >= 1.0 then
            Scanner.Notify_To_Scan;
            Motor_Prod.Set_Internal_State (Braking);
            Last_Posi := Current_Posi;
         end if;

         Next_Time := Next_Time + Period;
         delay until Next_Time;

      end loop Collision_Check;
      
   end Controller; 

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Motor_Prod.Initialize_Motors (M1, M2, M3, M4);
      Sonar_DMA.Initialize;
      Scanner.Initialize_Arm;
   end Initialize;

end Vehicle;
