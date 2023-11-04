with Ada.Numerics.Discrete_Random;

package Sonar is

   type Centimeters is range 8 .. 81;
   type SharpIR is record
      Distance : Centimeters;
   end record;
   
   --  Instantiate generic package for generating random distance
   package Random_Distance is new
     Ada.Numerics.Discrete_Random (Result_Subtype => Centimeters);
   use Random_Distance;
   
   -- basic utilities
   function Get_Distance return Centimeters;

end Sonar;
