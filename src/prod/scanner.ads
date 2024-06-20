-------------------------------------------------------------------------
--  Interface
--
--  S1, S2, S3, S4 represent Four joints (base, shoulder, elbow and wrist)
--  of robotic arm.
--
--  Theta1, Theta2, Theta3 and Theta4 represent rotation angles for the
--  corresponding joints.
--  Their respective rotation's intervals are :
--
--  Theta1 � [0, 180�]
--  Theta2 � [0, 90�]
--  Theta3 � [0, 90�]
--  Theta4 � [0, 90�]
-- 
------------------------------------------------------------------------

package Scanner is

  pragma Elaborate_Body;

  procedure Initialize_Arm;
  procedure Notify_To_Scan;

end Scanner;
