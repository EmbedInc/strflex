{   Routines that deal with flex string memory states.
}
module strflex_strmem;
define strflex_strmem_create;
define strflex_strmem_delete;
%include 'strflex2.ins.pas';

procedure strflex_strmem_create (      {create memory state for flex strings}
  in out  mem: util_mem_context_t;     {system memory context, will create subordinate}
  out     strmem: strflex_mem_t);      {returned initialized flex string memory state}
  val_param;

begin
  end;

procedure strflex_strmem_delete (      {delete flex string mem state and all its strings}
  in out  strmem: strflex_mem_t);      {returned invalid, all str using this block invalid}
  val_param;

begin
  end;

