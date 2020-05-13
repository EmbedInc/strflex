{   Routines that manipulate flex string descriptors.
}
module strflex_str;
define strflex_str_create;
define strflex_str_delete;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Local subroutine STRFLEX_STR_INIT (STR)
*
*   Initialize all the fields in STR to default or benign values.
}
procedure strflex_str_init (           {init flex string descriptor}
  out     str: strflex_t);             {flex string descriptor to initialize}
  val_param; internal;

begin
  str.strmem_p := nil;
  str.first_p := nil;
  str.last_p := nil;
  str.len := 0;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_STR_CREATE (STRMEM, STR)
*
*   Create the flex string STR.  STRMEM is the memory state that will be used by
*   the new string.
}
procedure strflex_str_create (         {create a new flex string}
  in out  strmem: strflex_mem_t;       {memory state new string will use}
  out     str: strflex_t);             {returned initialized, zero length}
  val_param;

begin
  strflex_str_init (str);              {init the flex string descriptor}
  str.strmem_p := addr(strmem);        {set pointer to memory state used by this string}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_STR_DELETE (STR)
*
*   Delete the flex string STR.  STR will be invalid.
}
procedure strflex_str_delete (         {delete a flex string}
  in out  str: strflex_t);             {returned invalid, all dynamic memory released}
  val_param;

begin
  strflex_str_init (str);
  end;
