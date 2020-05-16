{   Routines to copy flex strings to/from other objects.
}
module strflex_copy;
define strflex_copy_t_vstr;
define strflex_copy_f_vstr;
define strflex_copy_f_str;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_COPY_T_VSTR (STR, VSTR)
*
*   Copy the flex string STR into the var string VSTR.
}
procedure strflex_copy_t_vstr (        {copy flex string into var string}
  in      str: strflex_t;              {source flex string}
  in out  vstr: univ string_var_arg_t); {destination var string}
  val_param;

var
  str_p: strflex_p_t;                  {pointer to input flex string}
  pos: strflex_pos_t;                  {position within input string}
  ii: sys_int_machine_t;               {output string index}

begin
  str_p := addr(str);                  {make pointer to the input string}
  vstr.len := min(vstr.max, str.len);  {make length of result}

  strflex_pos_init (str_p^, pos);      {init source position to first char}

  for ii := 1 to vstr.len do begin     {loop over the characters to copy}
    vstr.str[ii] := strflex_char_inc (pos);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_COPY_F_VSTR (VSTR, STR)
*
*   Copy the var string VSTR into the flex string STR.
}
procedure strflex_copy_f_vstr (        {copy var string into flex string}
  in      vstr: univ string_var_arg_t; {source var string}
  in out  str: strflex_t);             {destination flex string}
  val_param;

var
  ii: sys_int_machine_t;               {source string index}

begin
  strflex_clear (str);                 {reset the destination string to empty}

  for ii := 1 to vstr.len do begin     {loop over each character to copy}
    strflex_append_char (str, vstr.str[ii]);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_COPY_F_STR (S, STR)
*
*   Copy the Pascal or C string S into the flex string STR.
}
procedure strflex_copy_f_str (         {copy Pascal/C string into flex string}
  in      s: string;                   {source string}
  in out  str: strflex_t);             {destination flex string}
  val_param;

var
  vstr: string_var80_t;

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_vstring (vstr, s, size_char(s)); {make var string version of input string}
  strflex_copy_f_vstr (vstr, str);     {copy var string into the flex string}
  end;
