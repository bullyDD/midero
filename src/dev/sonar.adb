with Ada.Real_Time;

with Global_Initialization;
with System_Configuration;

package body Sonar is
   
   use Ada.Real_Time;
   
   Period : constant Time_Span := 
     Milliseconds (System_Configuration.Sonar_Period);
   
   protected Critical_Distance is
      procedure Set_Internal_Dist (Reading : Centimeters);
      function  Get_Internal_Dist return Centimeters;
   private
      Internal_Distance : Centimeters;
   end Critical_Distance;
   
   -----------------------
   -- Critical_Distance --
   -----------------------
   protected body Critical_Distance is
      
      -----------------------
      -- Set_Internal_Dist --
      -----------------------
      procedure Set_Internal_Dist (Reading : Centimeters) is
      begin
         Internal_Distance := Reading;
      end Set_Internal_Dist;
      -----------------------
      -- Get_Internal_Dist --
      -----------------------
      function Get_Internal_Dist return Centimeters is
        (Internal_Distance);

   end Critical_Distance;
   
   task Controller with Priority => System_Configuration.Sonar_Priority;
   ----------------
   -- Controller --
   ----------------
   task body Controller is
      G : Generator;
      Next_Time : Time;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Time);
      Reset (G);
      loop
         delay until Next_Time;
         Critical_Distance.Set_Internal_Dist (Random (G));
         Next_Time := Next_Time + Period;
      end loop;
   end Controller;
   ------------------
   -- Get_Distance --
   ------------------
   function Get_Distance return Centimeters is
     (Critical_Distance.Get_Internal_Dist);

end Sonar;
