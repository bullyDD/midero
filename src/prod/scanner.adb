with Ada.Real_Time;

with Global_Initialization;
with Hardware_Config;
with Metal_Detector;
with Motor_Prod;
with Lcd_Out;
with Servo;
with System_Configuration;

package body Scanner is

   use Ada.Real_Time;
   use Hardware_Config;
   use Metal_Detector;
   use Motor_Prod;
   use Lcd_Out;
   use Servo;

   Do_Scan  : Boolean := False with Volatile;
   Period   : Time_Span := 
         Milliseconds (System_Configuration.Scanner_Period);

   Base, Shoulder, Elbow, Wrist : MG996R_Servo;
   Sensor                       : Metal_Sensor;
   
   procedure Sweep;    

   task Scanner_Controller with
      Priority =>  System_Configuration.Scanner_Priority;
   
   ------------------------
   -- Scanner_Controller --
   ------------------------

   task body Scanner_Controller is
      Next_Time : Time;
   begin

      Global_Initialization.Critical_Instant.Wait (Next_Time);

      loop
         if Do_Scan then
            Sweep;
         end if;
         Next_Time := Next_Time + Period;
         delay until Next_Time;
      end loop;

   end Scanner_Controller;

   --------------------
   -- Initialize_Arm --
   --------------------
   
   procedure Initialize_Arm is
   begin
      --  Initialize Base servo
      Base.Initialize (
         Channel          => Base_Channel,
         PWM_Engine       => Base_Pin,
         PWM_Output_Timer => Base_Timer'Access,
         PWM_Output_AF    => Base_AF,
         PWM_Frequency    => 50);

      Shoulder.Initialize
        (Channel          => Shoulder_Channel,
         PWM_Engine       => Shoulder_Pin,
         PWM_Output_Timer => Shoulder_Timer'Access,
         PWM_Output_AF    => Shoulder_AF,
         PWM_Frequency    => 50);

      Elbow.Initialize
        (Channel          => Elbow_Channel,
         PWM_Engine       => Elbow_Pin,
         PWM_Output_Timer => Elbow_Timer'Access,
         PWM_Output_AF    => Elbow_AF,
         PWM_Frequency    => 50);

      Wrist.Initialize
        (Channel          => Wrist_Channel,
         PWM_Engine       => Wrist_Pin,
         PWM_Output_Timer => Wrist_Timer'Access,
         PWM_Output_AF    => Wrist_AF,
         PWM_Frequency    => 50);

      Metal_Detector.Initialize (This => Sensor);

   end Initialize_Arm;


   --------------------
   -- Notify_To_Scan --
   --------------------

   procedure Notify_To_Scan is
   begin
      Do_Scan := True;
   end Notify_To_Scan;
   
   -----------
   -- Sweep --
   -----------

   procedure Sweep is
      Measure : Target_Indicator;
      IO_Successful : Boolean;
   begin
   
      -- base servo rotate from 0 to 180
      Base.Rotate (1000);
      delay (0.5);
      Base.Rotate (1500);
      delay (0.8);
      Base.Rotate (3500);
      delay (0.45);
   
      Metal_Detector.Get_Raw_Reading (Sensor, Integer (Measure), Successful => IO_Successful);
      
      if IO_Successful then
         if Measure > 512 then
            Motor_Prod.Set_Internal_State (Braking);
         end if;
      end if;
   end Sweep;
   

end Scanner;
