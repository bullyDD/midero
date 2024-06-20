with STM32;

with STM32.ADC;
with STM32.DMA;
with STM32.Device;
with STM32.GPIO;
with STM32.Timers;

pragma Elaborate_All (STM32);

package Hardware_Config is

   use STM32;
   use STM32.ADC;
   use STM32.DMA;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;

   --  Hardware Configuration used by the fours motors on the
   --  L298N-driver and STM32F429 disco board

   Motor_PWM_Freq : constant := 490;

   ---------------------------------------
   -- ** Motor 1 : Motor Bottom Right **--
   ---------------------------------------
   
   --  Encoder motor
   Motor1_Encoder_Input1 : GPIO_Point renames PA15;
   Motor1_Encoder_Input2 : GPIO_Point renames PB3;
   Motor1_Encoder_Timer  : constant access Timer := Timer_2'Access;
   Motor1_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   --  Engine PWM
   Motor1_PWM_Engine_TMR     : constant access Timer := Timer_4'Access;
   Motor1_PWM_Output_AF      : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   Motor1_PWM_Engine         : GPIO_Point renames PB6;
   Motor1_PWM_Channel        : constant Timer_Channel := Channel_1;
   Motor1_Polarity1          : GPIO_Point renames PA10;
   Motor1_Polarity2          : GPIO_Point renames PB1;

   ---------------------------------------
   -- ** Motor 2 : Motor Bottom Left ** --
   ---------------------------------------

   --  Encoder motor
   Motor2_Encoder_Input1 : GPIO_Point renames PB0;
   Motor2_Encoder_Input2 : GPIO_Point renames PB1;
   Motor2_Encoder_Timer  : constant access Timer := Timer_1'Access;
   Motor2_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM1_1;
   --  Engine PWM
   Motor2_PWM_Engine     : GPIO_Point renames PA3;
   Motor2_PWM_Engine_TMR : constant access Timer := Timer_5'Access;
   Motor2_PWM_Channel    : constant Timer_Channel := Channel_4;
   Motor2_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM5_2;
   Motor2_Polarity1      : GPIO_Point renames PC1;
   Motor2_Polarity2      : GPIO_Point renames PC0;

   -------------------------------------
   -- ** Motor 3 : Motor Top Right ** --
   -------------------------------------

   --  Encoder
   Motor3_Encoder_Input1 : GPIO_Point renames PB6;
   Motor3_Encoder_Input2 : GPIO_Point renames PB7;
   Motor3_Encoder_Timer  : constant access Timer := Timer_4'Access;
   Motor3_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   --  Engine PWM
   Motor3_PWM_Engine     : GPIO_Point renames PA0;
   Motor3_PWM_Engine_TMR : constant access Timer := Timer_2'Access;
   Motor3_PWM_Channel    : constant Timer_Channel := Channel_1;
   Motor3_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   Motor3_Polarity1      : GPIO_Point renames PC3;
   Motor3_Polarity2      : GPIO_Point renames PC2;

   ------------------------------------
   -- ** Motor 4 : Motor Top Left ** --
   ------------------------------------

   --  Encoder
   Motor4_Encoder_Input1 : GPIO_Point renames PB14;
   Motor4_Encoder_Input2 : GPIO_Point renames PB15;
   Motor4_Encoder_Timer  : constant access Timer := Timer_8'Access;
   Motor4_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM8_3;
   --  Engine PWM
   Motor4_PWM_Engine     : GPIO_Point renames PD12;
   Motor4_PWM_Engine_TMR : constant access Timer := Timer_4'Access;
   Motor4_PWM_Channel    : constant Timer_Channel := Channel_1;
   Motor4_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   Motor4_Polarity1      : GPIO_Point renames PC5;
   Motor4_Polarity2      : GPIO_Point renames PC4;

   ------------------------
   -- ** MG996R Servo ** --
   ------------------------

   -- Base Joint
   
   Base_Pin             : GPIO_Point renames PA6;
   Base_Channel         : constant Timer_Channel := Channel_1;
   Base_Timer           : Timer renames Timer_3;
   Base_AF              : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM3_2;

   -- Shoulder Joint
   
   Shoulder_Pin         : GPIO_Point renames PE5;
   Shoulder_Channel     : constant Timer_Channel := Channel_1;
   Shoulder_Timer       : Timer renames Timer_9;
   Shoulder_AF          : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM9_3;


   -- Elbow servo
   
   Elbow_Pin            : GPIO_Point renames PH10;
   Elbow_Channel        : constant Timer_Channel := Channel_1;
   Elbow_Timer          : Timer renames Timer_5;
   Elbow_AF             : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM5_2;


   -- Wrist servo
   
   Wrist_Pin            : GPIO_Point renames PH13;
   Wrist_Channel        : constant Timer_Channel := Channel_1;
   Wrist_Timer          : Timer renames Timer_8;
   Wrist_AF             : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM8_3;


   ----------------------------
   -- *** SharpIR sensors ** --
   ----------------------------

   Converter            : Analog_To_Digital_Converter renames ADC_1;
   Sig_Input_Channel    : constant Analog_Input_Channel := 13;
   Signal_Pin           : constant GPIO_Point           := PE3;

   Controller           : DMA_Controller renames DMA_2;
   Stream               : constant DMA_Stream_Selector := Stream_0;

end Hardware_Config;