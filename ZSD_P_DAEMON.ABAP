REPORT ZSD_P_DAEMON.

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME.
  PARAMETERS: Class TYPE SEOCLSNAME OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS: DAEMON TYPE string OBLIGATORY.
PARAMETERS: START TYPE CHAR1 RADIOBUTTON GROUP RD1,
            STOP TYPE CHAR1 RADIOBUTTON GROUP RD1,
            SEND TYPE char1 RADIOBUTTON GROUP rd1.
PARAMETERS: Message TYPE string.
SELECTION-SCREEN END OF BLOCK b1.


INITIALIZATION.

START-OF-SELECTION.
DATA(isOk) = abap_false.
PERFORM CheckDaemonClass USING class CHANGING isOk.
IF isok = abap_true.
  IF start = abap_true.
  DATA(ptab) = VALUE abap_parmbind_tab( ( name  = 'IV_DAEMON_NAME' kind  = cl_abap_objectdescr=>exporting value = REF #( DAEMON ) ) ).
  DATA(etab) = VALUE abap_excpbind_tab( ).
  DATA(_method) = 'START'.
  CALL METHOD (class)=>(_method)  PARAMETER-TABLE ptab EXCEPTION-TABLE etab.
*  zcl_sd_termin_daemon=>start( iv_daemon_name = DAEMON ).
  ELSEIF stop = abap_true.
   ptab = VALUE abap_parmbind_tab( ( name  = 'IV_DAEMON_NAME' kind  = cl_abap_objectdescr=>exporting value = REF #( DAEMON ) ) ).
   etab = VALUE abap_excpbind_tab( ).
  _method = 'STOP'.
  CALL METHOD (class)=>(_method)  PARAMETER-TABLE ptab EXCEPTION-TABLE etab.
*  zcl_sd_termin_daemon=>stop( iv_daemon_name = DAEMON ).
  ELSEIF send = abap_true.
   ptab = VALUE abap_parmbind_tab( ( name  = 'IV_DAEMON_NAME' kind  = cl_abap_objectdescr=>exporting value = REF #( DAEMON ) ) ).
   etab = VALUE abap_excpbind_tab( ).
   _method = 'SEND'.
  CALL METHOD (class)=>(_method)  PARAMETER-TABLE ptab EXCEPTION-TABLE etab.
*  zcl_sd_termin_daemon=>send( iv_daemon_name = DAEMON iv_text = Message ).
  ENDIF.
ENDIF.
END-OF-SELECTION.

FORM CheckDaemonClass USING className TYPE SEOCLSNAME CHANGING isOk TYPE abap_bool.
  SELECT SINGLE * FROM seometarel WHERE refclsname = 'CL_ABAP_DAEMON_EXT_BASE' INTO @DATA(_class).
  IF sy-subrc = '0'.
  isok = abap_true.
  ENDIF.
ENDFORM.
