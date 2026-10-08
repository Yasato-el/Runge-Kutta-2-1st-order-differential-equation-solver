with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Float_Text_IO;         use Ada.Float_Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;   use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
procedure Rk2 is
   str_func : Unbounded_String;
   func : float;
   An : Float;
   Bn : Float;
   j : Integer;
   x : Float;
   y : Float;
   x0 : Float;
   y0 : Float;
   xn : Float;
   yn : Float;
   h : Float;
   n : Integer;

   Clean_Str : Unbounded_String;
   
   function Evaluate_Token (Token : String; Current_X : Float; Current_Y : Float) return Float is
   begin
      if Token = "x" or else Token = "X" then
         return Current_X;
      elsif Token = "y" or else Token = "Y" then
         return Current_Y;
      else
         return Float'Value (Token);
      end if;
   end Evaluate_Token;

   function Parse_And_Evaluate (Formula : String; Current_X : Float; Current_Y : Float) return Float is
      Idx : Natural;
   begin
      Idx := Index (Formula, "+");
      if Idx > 0 then
         return Parse_And_Evaluate (Formula (Formula'First .. Idx - 1), Current_X, Current_Y) +
                Parse_And_Evaluate (Formula (Idx + 1 .. Formula'Last), Current_X, Current_Y);
      end if;

      Idx := Index (Formula, "-");
      if Idx > Formula'First then
         return Parse_And_Evaluate (Formula (Formula'First .. Idx - 1), Current_X, Current_Y) -
                Parse_And_Evaluate (Formula (Idx + 1 .. Formula'Last), Current_X, Current_Y);
      end if;

      Idx := Index (Formula, "*");
      if Idx > 0 and then (Idx = Formula'Last or else Formula (Idx + 1) /= '*') and then (Idx = Formula'First or else Formula(Idx - 1) /= '*') then
         return Parse_And_Evaluate (Formula (Formula'First .. Idx - 1), Current_X, Current_Y) *
                Parse_And_Evaluate (Formula (Idx + 1 .. Formula'Last), Current_X, Current_Y);
      end if;

      Idx := Index (Formula, "/");
      if Idx > 0 then
         return Parse_And_Evaluate (Formula (Formula'First .. Idx - 1), Current_X, Current_Y) /
                Parse_And_Evaluate (Formula (Idx + 1 .. Formula'Last), Current_X, Current_Y);
      end if;

      Idx := Index (Formula, "**");
      if Idx > 0 then
         declare
            Base : constant Float := Parse_And_Evaluate (Formula (Formula'First .. Idx - 1), Current_X, Current_Y);
            Power : constant Float := Parse_And_Evaluate (Formula (Idx + 2 .. Formula'Last), Current_X, Current_Y);
         begin
            return Base ** Power;
         end;
      end if;

      return Evaluate_Token (Trim (Formula, Ada.Strings.Both), Current_X, Current_Y);
   end Parse_And_Evaluate;
begin
   -- Get the function
   Put ("Enter the function y'=f(x, y): ");
   Get_Line (str_func);
   -- Get x0 and y0:
   Put ("Enter x0: "); Get (x0); Skip_Line;
   Put ("Enter y0: "); Get (y0); Skip_Line;
   -- Get step size and number of steps:
   Put ("Enter step size (h): "); Get (h); Skip_Line;
   Put ("Enter the number of steps (n): "); Get (n); Skip_Line;

   -- Change function from string to float

   Clean_Str := Null_Unbounded_String;
   for I in 1 .. Length (str_func) loop
      if Element (str_func, I) /= ' ' then
         Append (Clean_Str, Element (str_func, I));
      end if;
   end loop;

   -- RK2
   for i in 1 .. n loop
      if i = 1 then
         An := Parse_And_Evaluate (To_String (Clean_Str), x0, y0);
         x := x0 + h;
         y := y0 + h * An;
         Bn := Parse_And_Evaluate (To_String (Clean_Str), x, y);
         y := y + h*((An + Bn) / Float (2));
         Put ("x : "); Put (x); New_Line;
         Put ("y : "); Put (y); New_Line; New_Line;
         x := x + h;
      else
         An := Parse_And_Evaluate (To_String (Clean_Str), x, y);
         x := x + h;
         y := y + h * An;
         Bn := Parse_And_Evaluate (To_String (Clean_Str), x, y);
         y := y + h * ((An + Bn) / Float (2));
         Put ("x : "); Put (x); New_Line;
         Put ("y : "); Put (y); New_Line; New_Line;
         x := x + h;
      end if;
   end loop;
end Rk2;