with Ada.Real_Time;
with LCD_Std_Out;

with Servo;

procedure Demo_Servo is

   use Ada.Real_Time;
   use LCD_Std_Out;

   use Servo;

   Period : constant Time_Span := Milliseconds (750);
   Next_Time : Time := Clock + Period;

   BaseServo, ShoulderServo, ElbowServo, GripperServo : MG996R_Servo;
   I : Integer := 3;

begin
   --  Unitary test Servo motor
   --  Initialization
   Initialize_Arm (S1 => BaseServo,
                   S2 => ShoulderServo,
                   S3 => ElbowServo,
                   S4 => GripperServo);

   loop
      Clear_Screen;
      delay until Next_Time;

      if I > 14 then
         I := 3;
      else
         Put_Line ("I= " & I'Image);
         BaseServo.Rotate (Degree => I);
         I := I + 1;
      end if;

      Next_Time := Next_Time + Period;

   end loop;

end Demo_Servo;
