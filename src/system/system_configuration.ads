--  Task periods and priorities

with System;    

package System_Configuration is

   use System;

   --  These constants are the priorities of the tasks in the system, defined
   --  here for ease of setting with the big picture in view.

   Main_Priority           : constant Priority := Priority'First; -- lowest
   Engine_Monitor_Priority : constant Priority := Main_Priority + 1;
   Scanner_Priority        : constant Priority := Engine_Monitor_Priority + 1;
   Vehicle_Priority        : constant Priority := Scanner_Priority + 1;
   Sonar_Priority          : constant Priority := Vehicle_Priority + 1;
   Scheduler_Priority      : constant Priority := Sonar_Priority   + 1;

   Highest_Priority        : Priority renames Scheduler_Priority;

   Highest_Period          : constant := 450;                     -- millisecond
   Engine_Monitor_Period   : constant := Highest_Period - 50;
   Scanner_Period          : constant := Engine_Monitor_Period - 50;    
   Vehicle_Period          : constant := Scanner_Period - 50;
   Sonar_Period            : constant := Vehicle_Period - 50;

end System_Configuration;
