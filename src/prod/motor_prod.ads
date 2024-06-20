with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;
with Quadrature_Encoders; 

package Motor_Prod is


   pragma Elaborate_Body;
   
   -----------------------
   -- Package interface --
   -----------------------
   
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   use Quadrature_Encoders;

   type Direction is (Forward, Backward);
   type Motor_State is (ON, OFF);
   type Current_State_T is (Running, Braking);
   
   subtype Power_Level is Integer range 0 .. 100;
   
   type Basic_Motor is tagged limited private;
   ----------------------
   -- Motor Facilities --
   ----------------------
   procedure Initialize_Motors  (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Turn_Motor         (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Set_Internal_State (State : Current_State_T);

   type Motor_Encoder_Counts is range -(2 ** 31) .. +(2 ** 31 - 1);
   Encoder_Counts_Per_Revolution : constant := 720;
   --  Thus 1/2 degree resolution
   function Encoder_Count (This : Basic_Motor) return Motor_Encoder_Counts;

private
   type Basic_Motor is tagged limited 
      record
         Encoder           : Rotary_Encoder;
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
   end record;
end Motor_Prod;
