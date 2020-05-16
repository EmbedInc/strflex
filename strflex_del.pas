{   Routines for deleting parts of a flex string.
}
module strflex_del;
define strflex_del_bak;
define strflex_del_fwd;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Local subroutine CHAR_DEL (BLK, IND)
*
*   Remove the character at index IND in the block BLK.  Nothing is done if IND
*   is not the index of a valid character in the block.  Characters after IND
*   in the block, if any, are shifted toward the start of the block to fill in
*   the hole left by the deletion.  The block may become empty, but is not
*   deleted.
*
*   IND must from 1 to the number of characters in the block + 1.
}
procedure char_del (                   {delete character in a block}
  in out  blk: strflex_block_t;        {the block to delete char from}
  in      ind: sys_int_machine_t);     {index within block to delete at}
  val_param; internal;

var
  ii: sys_int_machine_t;

begin
  if ind > blk.nch then return;        {no char at IND to delete ?}

  blk.nch := blk.nch - 1;              {update number of chars in this block}

  for ii := ind to blk.nch do begin    {move chars down to fill hole}
    blk.ch[ii] := blk.ch[ii+1];
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_DEL_BAK (POS)
*
*   Delete the string character at POS, then go backward to the previous
*   character.
*
*   Nothing is done if the original position is past the end of the string.  If
*   the original position is the first character of the string, then the
*   resulting position will be at the new first character, or past the end of
*   the string if the new string is empty.
}
procedure strflex_del_bak (            {delete curr char, back to previous}
  in out  pos: strflex_pos_t);         {position into string}
  val_param;

begin
  if pos.ind > pos.str_p^.len then return; {no curr char, nothing to do ?}

  pos.str_p^.len := pos.str_p^.len - 1; {string will be one character shorter}
  pos.ind := max(1, pos.ind - 1);      {position will be one char earlier}

  char_del (pos.blk_p^, pos.blkn);     {delete the char}

  if pos.blkn > 1 then begin           {deleted char wasn't first in block ?}
    pos.blkn := pos.blkn - 1;          {go to previous character}
    return;
    end;
{
*   The deleted character was the first in the current block.
}
  if pos.blk_p^.prev_p <> nil then begin {there is a previous block ?}
    pos.blk_p := pos.blk_p^.prev_p;    {go to previous block}
    pos.blkn := pos.blk_p^.nch;        {to last char in this new block}
    if pos.blk_p^.next_p^.nch <= 0 then begin {the vacated block is now empty ?}
      strflex_block_remove (           {unlink and release the empty block}
        pos.str_p^, pos.blk_p^.next_p);
      end;
    return;
    end;
{
*   The deleted character was the first in the string.
}
  if pos.blk_p^.nch <= 0 then begin    {the whole string is now empty ?}
    strflex_block_remove (pos.str_p^, pos.blk_p); {unlink and release the block}
    pos.blk_p := pos.str_p^.first_p;
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_DEL_FWD (POS)
*
*   Delete the string character at POS, then go forwards to the next character.
*   Nothing is done if the position is past the end of the string.
}
procedure strflex_del_fwd (            {delete curr char, forward to next}
  in out  pos: strflex_pos_t);         {position into string}
  val_param;

begin
  if pos.ind > pos.str_p^.len then return; {no curr char, nothing to do ?}

  pos.str_p^.len := pos.str_p^.len - 1; {string will be one character shorter}
  char_del (pos.blk_p^, pos.blkn);     {delete the char}

  if pos.blkn <= pos.blk_p^.nch then begin {still pointing to a valid char ?}
    return;
    end;
{
*   The last character in the current block was deleted.
}
  if pos.blk_p^.next_p <> nil then begin {there is a following block ?}
    pos.blk_p := pos.blk_p^.next_p;    {go to next block}
    pos.blkn := 1;                     {to first char in this new block}
    if pos.blk_p^.prev_p^.nch <= 0 then begin {the vacated block is now empty ?}
      strflex_block_remove (           {unlink and release the empty block}
        pos.str_p^, pos.blk_p^.prev_p);
      end;
    end;
{
*   The deleted character was the last character of the string.
}
  if pos.blk_p^.nch <= 0 then begin    {the current block is now empty ?}
    pos.blk_p := pos.blk_p^.prev_p;    {go to previous block}
    if pos.blk_p = nil
      then begin                       {string is empty now}
        pos.blkn := 1;
        end
      else begin                       {the new block exists}
        pos.blkn := pos.blk_p^.nch;    {to last char of this new block}
        end
      ;
    strflex_block_remove (pos.str_p^, pos.str_p^.last_p); {delete the vacated block}
    end;
  end;
