{   Routines that deal with string lengths.
}
module strflex_len;
define strflex_len;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Function STRFLEX_LEN (STR)
*
*   Returns the number of characters in the string.
}
function strflex_len (                 {get string length}
  in      str: strflex_t)              {the string}
  :sys_int_machine_t;                  {0-N number of characters in the string}
  val_param;

begin
  strflex_len := str.len;
  end;
