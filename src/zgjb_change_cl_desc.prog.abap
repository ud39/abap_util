*&---------------------------------------------------------------------*
*& Report ZGJB_CHANGE_CL_DESC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgjb_change_cl_desc.

DATA: gt_cl_descript TYPE STANDARD TABLE OF seoclasstx.
DATA: gr_alvgrid TYPE REF TO cl_gui_alv_grid,
      gc_custom_control_name TYPE scrfname VALUE 'CC_ALV',
      gr_ccontainer TYPE REF TO cl_gui_custom_container,
      gt_fieldcat TYPE lvc_t_fcat,
      gs_layout TYPE lvc_s_layo.

PARAMETERS: pv_pcage TYPE string DEFAULT 'ZGJB_EXERCISES',
            pv_user TYPE string DEFAULT 'DEVELOPER'.


SELECT seoclasstx~clsname, seoclasstx~descript
FROM tadir
JOIN seoclasstx ON tadir~obj_name = seoclasstx~clsname
WHERE tadir~author <> 'SAP'
AND tadir~object = 'CLAS'
AND tadir~devclass = @pv_pcage
INTO TABLE @DATA(gt_cl).


*LOOP AT gt_cl ASSIGNING FIELD-SYMBOL(<ls_cl_descr>).
*  DATA lv_new_descript TYPE string.
*  DATA(lv_cls_name) = <ls_cl_descr>-clsname.
*  SPLIT lv_cls_name AT '_' INTO TABLE DATA(lt_exercise_name).
*  LOOP AT lt_exercise_name ASSIGNING FIELD-SYMBOL(<lv_exercise_name>).
*    IF contains( val = <lv_exercise_name> pcre = 'ZCL' ). CONTINUE. ENDIF.
*    lv_new_descript = COND #( WHEN lv_new_descript IS INITIAL THEN <lv_exercise_name> ELSE lv_new_descript && `_` && <lv_exercise_name> ).
*  ENDLOOP.
*
*  CONCATENATE '''' lv_new_descript INTO lv_new_descript.
*  CONCATENATE lv_new_descript '''' INTO lv_new_descript.
*  CONCATENATE `Loesung fuer ` lv_new_descript INTO lv_new_descript.
*  <ls_cl_descr>-descript = lv_new_descript.
*  UPDATE seoclasstx SET descript = lv_new_descript WHERE clsname = <ls_cl_descr>-clsname.
*  IF sy-subrc = 0.
*    MESSAGE 'Description was updated.' TYPE 'S'.
*  ELSE.
*    MESSAGE 'Description update was not successful.' TYPE 'E'.
*  ENDIF.
*  CLEAR lv_new_descript.
*ENDLOOP.

*cl_salv_table=>factory(
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*    r_container    =                           " Abstracter Container fuer GUI Controls
*    container_name =
*  IMPORTING
*    r_salv_table   = DATA(go_salv)                          " Basisklasse einfache ALV Tabellen
*  CHANGING
*    t_table        = gt_cl
*).
*go_salv->display( ).
*CATCH cx_salv_msg. " ALV: Allg. Fehlerklasse  mit Meldung


START-OF-SELECTION.

CALL SCREEN 0100.


MODULE display_alv OUTPUT.
  PERFORM display_alv.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .

ENDFORM.
