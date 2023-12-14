----------------------------------------------------------------
--  This program demonstrates driving DC Planetarium motor using
--  STM32F4 Discovery board and motor interface L298N.
--  The program iteratively increases power by 25% and displays
--  the relative speed using the four LEDs.

with STM32.Board;
with STM32.Device;

with Ada.Real_Time;
with Motor;

procedure Demo_Encoder is

   use STM32.Device;
   use STM32.Board;
   use Ada.Real_Time;
   use Motor;

   M1, M2, M3, M4 : Basic_Motor;

   Throttle_Setting : Power_Level := 0;
   -- Power setting for controlling motor speed

   Encoder_Sampling_Interval : constant Time_Span := Seconds(1);
   -- Sampling interval for compting encoder counts per second

   subtype Stopped is Motor_Encoder_Counts range 0 .. 0;
   subtype Slow is Motor_Encoder_Counts range Stopped'Last + 1 .. 600;
   subtype Cruising is Motor_Encoder_Counts range Slow'Last + 1 .. 1400;
   subtype Fast is Motor_Encoder_Counts range Cruising'Last + 1 .. 1600;
   subtype RedLine is Motor_Encoder_Counts range Fast'Last + 1 .. 10_000;

   function Encoder_Delta (This : Basic_Motor; Sample_Interval :  Time_Span)
                           return Motor_Encoder_Counts;
   -- return the encoder count delta for this motor over the Sample_Interval
   -- time. Delays the caller for the interval since it waits that amount of
   -- time btw taking the two samples used to calculate the delta.

   procedure Panic with No_Return;
   -- Flash the LEDs to indicate disaster, forever.

   procedure All_Stop (This : Basic_Motor);
   --  Power down this motor and waits for rotations to cease by polling the
   --  motor's encoder.

   procedure Await_Button_Toggle;
   -- Wait for the blue user button to be pressed and then released, by polling

   -----------
   -- Panic --
   -----------

   procedure Panic is
   begin
      loop
         --- When in danger, or in doubt
         All_LEDs_Off;
         delay until Clock + Milliseconds (250);
         All_LEDs_On;
         delay until Clock + Milliseconds (250);
      end loop;
   end Panic;

   --------------------
   --  Encoder_Delta --
   --------------------
   function Encoder_Delta (This : Basic_Motor; Sample_Interval :  Time_Span)
                           return Motor_Encoder_Counts
   is
      Start_Sample, End_Sample : Motor_Encoder_Counts;
   begin
      Start_Sample := This.Encoder_Count;
      delay until Clock + Sample_Interval;
      End_Sample := This.Encoder_Count;
      return abs (End_Sample - Start_Sample);    --  They can rotate backwards
   end Encoder_Delta;

   --------------
   -- All_Stop --
   -------------

   procedure All_Stop (This : Basic_Motor) is
      Stopping_TIme : constant Time_Span := Milliseconds (50);
   begin
      Motor.Set_Internal_State (Braking);
      Turn_Motor (M1, M2, M3, M4);
      loop
         exit when Encoder_Delta (This            => This,
                                  Sample_Interval => Stopping_TIme)   = 0;
      end loop;
   end All_Stop;

   -------------------------
   -- Await_Button_Toggle --
   -------------------------

   procedure Await_Button_Toggle is
   begin
      loop
         exit when User_Button_Point.Set;
      end loop;

      --  loop
      --     exit when not User_Button_Point.Set;
      --  end loop;
   end Await_Button_Toggle;

begin
   -- Initialization
   STM32.Board.Initialize_LEDs;
   STM32.Board.All_LEDs_Off;

   STM32.Board.Configure_User_Button_GPIO; --- for blue user button

   loop

      Await_Button_Toggle;

      Throttle_Setting := (if Throttle_Setting = 100 then 0
                           else Throttle_Setting + 25);
      if Throttle_Setting = 0 then
         All_Stop (M1);
      else
         Motor.Set_Internal_State (Running);
         M1.Accelere (Throttle_Setting);
      end if;

      case Encoder_Delta (M1, Encoder_Sampling_Interval) is
      when Stopped =>
         All_LEDs_Off;
      when Slow =>
         STM32.Board.LCH_LED.Set;
      when Cruising =>
         STM32.Board.Green_LED.Set;
      when Fast =>
         STM32.Board.Red_LED.Set;
      when Others =>
         Panic;
      end case;
   end loop;
end Demo_Encoder;
