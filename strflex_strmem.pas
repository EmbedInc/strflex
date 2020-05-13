{   Routines that deal with flex string memory states.
}
module strflex_strmem;
define strflex_strmem_create;
define strflex_strmem_delete;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_STRMEM_CREATE (MEM, STRMEM)
*
*   Create a new flex strings memory state.  MEM is the parent memory context.
*   A subordinate context will be created for the new flex string memory state.
}
procedure strflex_strmem_create (      {create memory state for flex strings}
  in out  mem: util_mem_context_t;     {system memory context, will create subordinate}
  out     strmem: strflex_mem_t);      {returned initialized flex string memory state}
  val_param;

begin
  util_mem_context_get (mem, strmem.mem_p); {create private mem context}
  strmem.free_p := nil;                {init to no unused free blocks}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_STRMEM_DELETE (STRMEM)
*
*   Delete a flex strings memory state.  All dynamic memory will be released.
*   All strings using this memory state will become invalid.
}
procedure strflex_strmem_delete (      {delete flex string mem state and all its strings}
  in out  strmem: strflex_mem_t);      {returned invalid, all str using this block invalid}
  val_param;

begin
  util_mem_context_del (strmem.mem_p); {dealloc all dynamic mem, delete mem context}
  strmem.free_p := nil;
  end;
