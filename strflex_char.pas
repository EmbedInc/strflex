{   Routines for reading characters from flex strings.
}
module strflex_char;
define strflex_char;
define strflex_char_inc;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Function STRFLEX_CHAR (POS)
*
*   Return the character of a flex string at the position POS.  The NULL
*   character is returned if the position is outside the string.
}
function strflex_char (                {get string character at current position}
  in      pos: strflex_pos_t)          {position into string}
  :char;                               {character at position, NULL past end of string}
  val_param;

begin
  strflex_char := chr(0);              {init to returning NULL}

  if pos.blk_p = nil then return;      {not at a block ?}
  if pos.blkn > pos.blk_p^.nch then return; {past end of the current block ?}
  strflex_char := pos.blk_p^.ch[pos.blkn]; {fetch and return the character}
  end;
{
********************************************************************************
*
*   Function STRFLEX_CHAR_INC (POS)
*
*   Like STRFLEX_CHAR, except that the position is incremented to the next
*   character of the string after the read.  The position is not changed if it
*   is already past the end of the string.
}
function strflex_char_inc (            {get character at curr position, then increment pos}
  in out  pos: strflex_pos_t)          {position into string}
  :char;                               {character at position, NULL past end of string}
  val_param;

begin
  strflex_char_inc := strflex_char(pos); {read and return the character}
  strflex_pos_inc (pos);               {increment the position, if possible}
  end;
