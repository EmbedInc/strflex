{   Routines that deal with flex string memory blocks.
}
module strflex_block;
define strflex_block_new;
define strflex_block_unuse;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_BLOCK_NEW (STRMEM, BLOCK_P)
*
*   Get a new or unused flex string memory block.  STRMEM is the memory state to
*   get the block from.  BLOCK_P is returned pointing to the new block.  The new
*   block will be initialized to empty and unlinked.
}
procedure strflex_block_new (          {get a new or free flex string memory block}
  in out  strmem: strflex_mem_t;       {memory state to get the block from}
  out     block_p: strflex_block_p_t); {pointer to new block, block initialized}
  val_param;

var
  ii: sys_int_machine_t;

begin
  if strmem.free_p <> nil
    then begin                         {a free block is available, return it}
      block_p := strmem.free_p;        {return the first block on the free chain}
      strmem.free_p := strmem.free_p^.next_p; {remove this block from free chain}
      end
    else begin                         {no free block available, allocate a new one}
      util_mem_grab (                  {allocate a new block}
        sizeof(block_p^),              {amount of memory to allocate}
        strmem.mem_p^,                 {memory context to allocate under}
        false,                         {will not need to individually deallocate}
        block_p);                      {returned pointer to the new memory}
      end
    ;

  block_p^.prev_p := nil;              {initialize the block to empty}
  block_p^.next_p := nil;
  block_p^.nch := 0;
  for ii := 1 to strflex_blkchars do begin
    block_p^.ch[ii] := chr(0);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_BLOCK_UNUSE (STRMEM, BLOCK_P)
*
*   Release a flex string memory block by indicating it is not used.  STRMEM is
*   the memory state the block was created from.  BLOCK_P points to the block on
*   entry, and is returned NIL
}
procedure strflex_block_unuse (        {indicate a flex string mem block no longer used}
  in out  strmem: strflex_mem_t;       {memory state the block came from}
  in out  block_p: strflex_block_p_t); {pointer to the block, returned NIL}
  val_param;

begin
  block_p^.next_p := strmem.free_p;    {link new block to start of free chain}
  strmem.free_p := block_p;
  block_p := nil;                      {invalidate caller's pointer to the block}
  end;
