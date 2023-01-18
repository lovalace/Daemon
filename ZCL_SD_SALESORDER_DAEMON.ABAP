class ZCL_SD_SALESORDER_DAEMON definition
  public
  inheriting from CL_ABAP_DAEMON_EXT_BASE
  final
  create public .

public section.
  METHODS: if_abap_daemon_extension~on_error REDEFINITION,
           if_abap_daemon_extension~on_message REDEFINITION,
           if_abap_daemon_extension~on_restart REDEFINITION,
           if_abap_daemon_extension~on_server_shutdown REDEFINITION,
           if_abap_daemon_extension~on_accept REDEFINITION,
           if_abap_daemon_extension~on_start REDEFINITION,
           if_abap_daemon_extension~on_stop REDEFINITION,
           if_abap_daemon_extension~on_system_shutdown REDEFINITION,
           if_abap_daemon_extension~on_before_restart_by_system REDEFINITION.

 CLASS-METHODS start IMPORTING iv_daemon_name TYPE string
                    RAISING   cx_abap_daemon_error
                              cx_ac_message_type_pcp_error.
CLASS-METHODS send  IMPORTING iv_daemon_name TYPE string
                              iv_text        TYPE string
                    RAISING   cx_abap_daemon_error
                              cx_ac_message_type_pcp_error.
CLASS-METHODS stop IMPORTING iv_daemon_name TYPE string
                   RAISING cx_abap_daemon_error.
protected section.
CLASS-DATA: OrderTable TYPE zsd05_t_OrderList.
private section.
METHODS deseriliazemessage IMPORTING i_json          TYPE string
                           RETURNING value(r_result) TYPE zsd05_t_OrderList.
ENDCLASS.



CLASS ZCL_SD_SALESORDER_DAEMON IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SD_SALESORDER_DAEMON->DESERILIAZEMESSAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_JSON                         TYPE        STRING
* | [<-()] R_RESULT                       TYPE        ZSD05_T_ORDERLIST
* +--------------------------------------------------------------------------------------</SIGNATURE>
   METHOD deseriliazemessage.
*[{"VBELN":"100000001","POSNR":10},{"VBELN":"100000001","POSNR":20},{"VBELN":"100000002","POSNR":10}]
  /ui2/cl_json=>deserialize( EXPORTING json = i_json CHANGING data = r_result ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_ACCEPT
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT_BASE                 TYPE REF TO IF_ABAP_DAEMON_CONTEXT_BASE
* | [<---] E_SETUP_MODE                   TYPE        IF_ABAP_DAEMON_TYPES=>TY_ABAP_DAEMON_SETUP_MODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_ACCEPT.
     TRY.
          DATA lv_program_name TYPE program.
          lv_program_name = cl_oo_classname_service=>get_classpool_name( 'ZCL_SD_SALESORDER_DAEMON' ).

          IF i_context_base->get_start_caller_info( )-program = lv_program_name.
            e_setup_mode = co_setup_mode-accept.
          ELSE.
            e_setup_mode = co_setup_mode-reject.
          ENDIF.
        CATCH cx_abap_daemon_error.
          " to do: error handling, e.g. write error log!
          e_setup_mode = co_setup_mode-reject.
      ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_BEFORE_RESTART_BY_SYSTEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* | [--->] I_CODE                         TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_BEFORE_RESTART_BY_SYSTEM.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_ERROR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CODE                         TYPE        I(optional)
* | [--->] I_REASON                       TYPE        STRING(optional)
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_ERROR.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_MESSAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_MESSAGE                      TYPE REF TO IF_AC_MESSAGE_TYPE_PCP
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_MESSAGE.
       TRY.
          "Get text from PCP message
          DATA(_Json) = i_message->get_text( ).
          "Sales Order Schedule
         DATA(_input) = DeseriliazeMessage( _Json  ).
         APPEND LINES OF _input to ordertable.

         IF ordertable IS NOT INITIAL.
         DATA(_SalesOrders) = NEW zcl_sd_sales_orders( ).
         LOOP AT ordertable ASSIGNING FIELD-SYMBOL(<order>).
           ##TODO
            IF sy-sysid <> zcl_system=>production.
             DATA(_OrderStatus) = _SalesOrders->updatesalesorderwithdaemon( order = <order> ).
             IF _OrderStatus = abap_true.
              COMMIT WORK.
              DELETE ordertable WHERE vbeln = <order> AND guid = <order>-guid.
             ENDIF.
            ENDIF.
         ENDLOOP.
         ENDIF.
        CATCH cx_ac_message_type_pcp_error.
      ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_RESTART
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_RESTART.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_SERVER_SHUTDOWN
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_SERVER_SHUTDOWN.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_START
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_START.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_STOP
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_MESSAGE                      TYPE REF TO IF_AC_MESSAGE_TYPE_PCP(optional)
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_STOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SD_SALESORDER_DAEMON->IF_ABAP_DAEMON_EXTENSION~ON_SYSTEM_SHUTDOWN
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CONTEXT                      TYPE REF TO IF_ABAP_DAEMON_CONTEXT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD IF_ABAP_DAEMON_EXTENSION~ON_SYSTEM_SHUTDOWN.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_SALESORDER_DAEMON=>SEND
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DAEMON_NAME                 TYPE        STRING
* | [--->] IV_TEXT                        TYPE        STRING
* | [!CX!] CX_ABAP_DAEMON_ERROR
* | [!CX!] CX_AC_MESSAGE_TYPE_PCP_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD SEND.
      " retrieve the list of ABAP Daemon instances
      DATA(lt_ad_info) = cl_abap_daemon_client_manager=>get_daemon_info( i_class_name = 'ZCL_SD_SALESORDER_DAEMON').

      "create PCP message with text
      DATA(lo_pcp) = cl_ac_message_type_pcp=>create( ).
      lo_pcp->set_text( iv_text ).
*      lo_pcp->
      " for each running daemon instance of this class
      LOOP AT lt_ad_info ASSIGNING FIELD-SYMBOL(<ls_info>).
        " send a message if the names match
        IF iv_daemon_name = <ls_info>-name.
          cl_abap_daemon_client_manager=>attach( <ls_info>-instance_id )->send( lo_pcp ).
        ENDIF.
      ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_SALESORDER_DAEMON=>START
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DAEMON_NAME                 TYPE        STRING
* | [!CX!] CX_ABAP_DAEMON_ERROR
* | [!CX!] CX_AC_MESSAGE_TYPE_PCP_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD START.
 "-------------------------------------------------------------------------------------------------"
   DATA(lt_ad_info) = cl_abap_daemon_client_manager=>get_daemon_info( i_class_name = 'ZCL_SD_SALESORDER_DAEMON').
  " for each running daemon instance of this class
   LOOP AT lt_ad_info ASSIGNING FIELD-SYMBOL(<ls_info>).
    " stop the daemon if the names match
    IF iv_daemon_name = <ls_info>-name.
       MESSAGE 'Daemon zaten çalışıyor' TYPE 'E'.
    ENDIF.
  ENDLOOP.
 " set ABAP Daemon start parameters
      DATA(lo_pcp) = cl_ac_message_type_pcp=>create( ).
*  lo_pcp->set_field( i_name = 'timeout' i_value = CONV #( iv_timeout ) ).
   " start the daemon application using the ABAP Daemon Manager
   cl_abap_daemon_client_manager=>start(
          i_class_name = 'ZCL_SD_SALESORDER_DAEMON'
          i_name       = CONV #( iv_daemon_name )
          i_priority   = cl_abap_daemon_client_manager=>co_session_priority_normal
          i_parameter  = lo_pcp ).
     MESSAGE 'Daemon başlatıldı' TYPE 'S'.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_SALESORDER_DAEMON=>STOP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DAEMON_NAME                 TYPE        STRING
* | [!CX!] CX_ABAP_DAEMON_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD STOP.
      " retrieve the list of ABAP Daemon instances
       DATA(lt_ad_info) = cl_abap_daemon_client_manager=>get_daemon_info( i_class_name = 'ZCL_SD_SALESORDER_DAEMON').
      " for each running daemon instance of this class
       LOOP AT lt_ad_info ASSIGNING FIELD-SYMBOL(<ls_info>).
        " stop the daemon if the names match
        IF iv_daemon_name = <ls_info>-name.
            cl_abap_daemon_client_manager=>stop( i_instance_id = <ls_info>-instance_id ).
        ENDIF.
      ENDLOOP.
  ENDMETHOD.
ENDCLASS.
