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

begin
   -- Initialization
   STM32.Board.Initialize_LEDs;
   STM32.Board.All_LEDs_Off;

   STM32.Board.Configure_User_Button_GPIO; --- for blue user button

   loop
      null;
   end loop;
end Demo_Encoder;
