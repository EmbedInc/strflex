{   Routines that manipulat the position within a flex string, and handle flex
*   string position descriptors.
}
module strflex_pos;
define strflex_pos_init;
define strflex_pos_end;
define strflex_pos_last;
define strflex_pos_inc;
define strflex_pos_dec;
define strflex_pos_set;
define strflex_pos;
define strflex_pos_eos;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_INIT (STR, POS)
*
*   Initialize the flex string position descriptor POS.  The position will be
*   the first character of the string STR.  When STR is the empty string, then
*   the position will be after the end of the string.
}
procedure strflex_pos_init (           {init position state within a flex string}
  in var  str: strflex_t;              {string to position within}
  out     pos: strflex_pos_t);         {initialized, at first char}
  val_param;

begin
  pos.str_p := addr(str);
  pos.ind := 1;
  pos.blk_p := str.first_p;
  if pos.blk_p = nil
    then begin
      pos.blkn := 0;
      end
    else begin
      pos.blkn := 1;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_END (POS)
*
*   Position to after the end of the string.
}
procedure strflex_pos_end (            {position to after end of string}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param;

begin
  pos.blk_p := pos.str_p^.last_p;
  if pos.blk_p = nil
    then begin
      pos.ind := 1;
      pos.blkn := 1;
      end
    else begin
      pos.ind := pos.str_p^.len + 1;
      pos.blkn := pos.blk_p^.nch + 1;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_LAST (POS)
*
*   Position to the last character of the string.  If the string is empty, then
*   the position will be after the end of the string.
}
procedure strflex_pos_last (           {position to last character of string, if any}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param;

begin
  pos.blk_p := pos.str_p^.last_p;
  if pos.blk_p = nil
    then begin
      pos.ind := 1;
      pos.blkn := 1;
      end
    else begin
      pos.ind := pos.str_p^.len;
      pos.blkn := pos.blk_p^.nch;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_INC (POS)
*
*   Increment the current position within the string by one character.  Nothing
*   is done if the string position is already past the end of the string.
}
procedure strflex_pos_inc (            {increment position to next char, unless past end}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param;

begin
  if pos.ind > pos.str_p^.len then return; {already past end of string ?}
  pos.ind := pos.ind + 1;              {indicate new position within the whole string}

  if pos.blkn < pos.blk_p^.nch then begin {next char is within same block ?}
    pos.blkn := pos.blkn + 1;          {to next char in same block}
    return;
    end;

  pos.blk_p := pos.blk_p^.next_p;      {advance to the next block}
  pos.blkn := 1;                       {to first character in this new block}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_DEC (POS)
*
*   Decrement the current position within the string by one character.  Nothing
*   is done if the string position is already at the first character.
}
procedure strflex_pos_dec (            {decrement position to prev char, unless at start}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param;

begin
  if pos.ind <= 1 then return;         {already at start of string ?}
  pos.ind := pos.ind - 1;              {indicate new position within the whole string}

  if pos.blkn > 1 then begin           {previous char in same block ?}
    pos.blkn := pos.blkn - 1;          {to previous char in same block}
    return;
    end;

  pos.blk_p := pos.blk_p^.prev_p;      {to previous block in chain}
  pos.blkn := pos.blk_p^.nch;          {to last char in this new block}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_POS_SET (POS, IND)
*
*   Set the string position POS to the index IND within the string.  The string
*   position will be clipped to the first character of the string and to
*   immediately after the last character.  Put another way, regardless of IND,
*   the position will always be at least 1, and never more than the string
*   length + 1.
}
procedure strflex_pos_set (            {set absolute string position}
  in out  pos: strflex_pos_t;          {string position to set}
  in      ind: sys_int_machine_t);     {1-N index to set pos to, clipped at length + 1}
  val_param;

var
  ii: sys_int_machine_t;

begin
  if (ind <= 1) or (pos.str_p^.len <= 0) then begin {to first character ?}
    pos.ind := 1;                      {set absolute string position}
    pos.blk_p := pos.str_p^.first_p;   {to first block in string}
    pos.blkn := 1;                     {to first char in this block}
    return;
    end;
{
*   The string is not empty, and the desired position is not the first
*   character.
}
  if ind > pos.str_p^.len then begin   {go to immediately after end of string ?}
    pos.ind := pos.str_p^.len + 1;     {set absolute string position}
    pos.blk_p := pos.str_p^.last_p;    {to last block in chain}
    pos.blkn := pos.blk_p^.nch + 1;    {to one char past end of block}
    return;
    end;

  pos.ind := ind;                      {string position will be as specified}

  if ind = pos.str_p^.len then begin   {go to last character ?}
    pos.blk_p := pos.str_p^.last_p;    {to last block}
    pos.blkn := pos.blk_p^.nch;        {to last char in the block}
    return;
    end;
{
*   The desired position is somewhere in the internal part of the string.  Loop
*   forward thru the blocks to find the block the desired position is in, then
*   set the position within that block.
}
  pos.blk_p := pos.str_p^.first_p;     {init to first block in the chain}
  ii := pos.blk_p^.nch;                {init index of last char this block}
  while ii < ind do begin              {loop until find block containing char}
    pos.blk_p := pos.blk_p^.next_p;    {to next block in the chain}
    ii := ii + pos.blk_p^.nch;         {update index of last char in this block}
    end;                               {back to check this new block}

  pos.blkn := pos.blk_p^.nch - (ii - ind); {set position within this block}
  end;
{
********************************************************************************
*
}
function strflex_pos (                 {get current string position}
  in      pos: strflex_pos_t)          {string position descriptor}
  :sys_int_machine_t;                  {1-N, never more than one past end}
  val_param;

begin
  strflex_pos := pos.ind;
  end;
{
********************************************************************************
*
}
function strflex_pos_eos (             {find whether past end of string}
  in      pos: strflex_pos_t)          {string position descriptor}
  :boolean;                            {FALSE within string, TRUE past end of string}
  val_param;

begin
  strflex_pos_eos := pos.ind > pos.str_p^.len;
  end;
