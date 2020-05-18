{   Routines for appending to the end of flex strings.
}
module strflex_append;
define strflex_append_char;
define strflex_append_vstr;
define strflex_append_str;
define strflex_append_t_vstr;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_APPEND_CHAR (STR, C)
*
*   Append the character C to the end of the flex string STR.  Any existing
*   positions into the string should be considered invalid after this call.
}
procedure strflex_append_char (        {append a character to the end of a flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      c: char);                    {character to append to end of string}
  val_param;

var
  blk_p: strflex_block_p_t;            {pointer to block to add char to}

begin
  if str.last_p = nil then begin       {string has no blocks ?}
    strflex_block_first (str);         {add the first block}
    end;

  str.len := str.len + 1;              {string will have one more character}

  blk_p := str.last_p;                 {get pointer to last block}
  if blk_p^.nch < strflex_blkchars then begin {block has room for new char ?}
    blk_p^.nch := blk_p^.nch + 1;      {one more character in this block}
    blk_p^.ch[blk_p^.nch] := c;        {fill in the new character}
    return;
    end;
{
*   The last block is full.  Add a new block to the end.
}
  strflex_block_new (str.strmem_p^, blk_p); {get and init a new block}

  str.last_p^.next_p := blk_p;         {link new block to end of chain}
  blk_p^.prev_p := str.last_p;
  str.last_p := blk_p;

  blk_p^.nch := 1;                     {new char is first in the new block}
  blk_p^.ch[1] := c;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_APPEND_VSTR (STR, VSTR)
*
*   Append the content of the var string VSTR to the end of the flex string STR.
}
procedure strflex_append_vstr (        {append var string to end of flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      vstr: univ string_var_arg_t); {string to append}
  val_param;

var
  ii: sys_int_machine_t;               {scratch integer and loop counter}

begin
  for ii := 1 to vstr.len do begin     {loop over each character to append}
    strflex_append_char (str, vstr.str[ii]);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_APPEND_STR (STR, S)
*
*   Append the content of the Pascal or C string S to the end of the flex string
*   STR.
}
procedure strflex_append_str (         {append Pascal/C string to end of flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      s: string);                  {string to append, blank padded or NULL term}
  val_param;

var
  vstr: string_var80_t;                {var string version of S}

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_vstring (vstr, s, size_char(s)); {convert input string to var string}
  strflex_append_vstr (str, vstr);     {append the var string}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_APPEND_T_VSTR (STR, VSTR)
*
*   Append the contents of the flex string STR to the end of the var string
*   VSTR.
}
procedure strflex_append_t_vstr (      {append flex string to end of var string}
  in      str: strflex_t;              {source flex string}
  in out  vstr: univ string_var_arg_t); {destination var string}
  val_param;

var
  str_p: strflex_p_t;                  {pointer to input flex string}
  pos: strflex_pos_t;                  {position within input string}
  len: sys_int_machine_t;              {final output string length}
  ii: sys_int_machine_t;               {output string index}

begin
  str_p := addr(str);                  {make pointer to the input string}
  strflex_pos_init (str_p^, pos);      {init source position to first char}

  len := min(vstr.max, vstr.len + str.len); {make total length of result string}

  for ii := vstr.len+1 to len do begin {loop over the destination characters}
    vstr.str[ii] := strflex_char_inc (pos);
    end;
  vstr.len := len;                     {update resulting string length}
  end;
