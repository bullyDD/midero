with STM32.GPIO;           use STM32.GPIO;
with STM32.Timers;         use STM32.Timers;
with STM32.PWM;            use STM32.PWM;

package Servo is

   type PWM_Frequency_T is range 50 .. 100;
   
   --  Type MG996R represent a physical servo object
   --  it has 3 wires : 
   --  Brown for GND
   --  Red for 5V
   --  Yellow for Data which is associated to PWM_Engine component
   type MG996R_Servo is tagged limited private;

   ----------------------------
   -- **  Servo utilities ** --
   ----------------------------

   procedure Initialize (
      This              : in out MG996R_Servo;
      Channel           : Timer_Channel;
      PWM_Engine        : GPIO_Point;
      PWM_Output_Timer  : not null access Timer;
      PWM_Output_AF     : STM32.GPIO_Alternate_Function;
      PWM_Frequency     : PWM_Frequency_T);

   procedure Rotate (
      This     : out MG996R_Servo; 
      value    : STM32.PWM.Microseconds);

   function Enabled (This : MG996R_Servo) return Boolean;

private

   type MG996R_Servo is tagged limited 
      record
         Channel           : Timer_Channel;
         PWM_Engine        : GPIO_Point;
         PWM_Output_Timer  : access Timer;
         PWM_Output_Engine : PWM_Modulator;
         PWM_Output_AF     : STM32.GPIO_Alternate_Function;
         PWM_Frequency     : PWM_Frequency_T;
      end record;

end Servo;
