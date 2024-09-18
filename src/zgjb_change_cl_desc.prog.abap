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
  IF gr_alvgrid IS INITIAL.
      gr_ccontainer = NEW cl_gui_custom_container(
        container_name              =  gc_custom_control_name  " Name of the dynpro CustCtrl name to link this container to
      ).
      IF sy-subrc <> 0.
      ENDIF.
  ENDIF.

  gr_alvgrid = NEW cl_gui_alv_grid(
*    i_shellstyle            = 0                " Control Style
*    i_lifetime              =                  " Lifetime
    i_parent                = gr_ccontainer                 " Parent-Container
*    i_appl_events           = space            " Ereignisse als Applikationsevents registrieren
*    i_parentdbg             =                  " Internal, donnot use.
*    i_applogparent          =                  " Container for application log
*    i_graphicsparent        =                  " Container for graphics
*    i_name                  =                  " Name
*    i_fcat_complete         = space            " boolsche Variable (X=true, space=false)
*    o_previous_sral_handler =
*    i_use_one_ux_appearance = abap_false
  ).

  PERFORM prepare_field_catalog CHANGING gt_fieldcat.

  PERFORM prepare_layout CHANGING gs_layout.

  gr_alvgrid->set_table_for_first_display(
    EXPORTING
*      i_buffer_active               =                  " Pufferung aktiv
*      i_bypassing_buffer            =                  " Puffer ausschalten
*      i_consistency_check           =                  " Starte Konsistenzverprobung für Schnittstellefehlererkennung
*      i_structure_name              =                  " Strukturname der internen Ausgabetabelle
*      is_variant                    =                  " Anzeigevariante
*      i_save                        =                  " Anzeigevariante sichern
      i_default                     = 'X'              " Defaultanzeigevariante
      is_layout                     = gs_layout                 " Layout
*      is_print                      =                  " Drucksteuerung
*      it_special_groups             =                  " Feldgruppen
*      it_toolbar_excluding          =                  " excludierte Toolbarstandardfunktionen
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Tabelle von der Struktur DTC_S_TC
*      it_except_qinfo               =                  " Tabelle für die Exception Quickinfo
*      ir_salv_adapter               =                  " Interface ALV Adapter
    CHANGING
      it_outtab                     =  gt_cl        " Ausgabetabelle
      it_fieldcatalog               =  gt_fieldcat      " Feldkatalog
*      it_sort                       =                  " Sortierkriterien
*      it_filter                     =                  " Filterkriterien
    EXCEPTIONS
      invalid_parameter_combination = 1                " Parameter falsch
      program_error                 = 2                " Programmfehler
      too_many_lines                = 3                " Zu viele Zeilen in eingabebereitem Grid.
      others                        = 4
  ).
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  gr_alvgrid->refresh_table_display(
*    EXPORTING
*      is_stable      =                  " zeilen-/spaltenstabil
*      i_soft_refresh =                  " Ohne Sortierung, Filter, etc.
    EXCEPTIONS
      finished       = 1                " Display wurde beendet ( durch Export ).
      others         = 2
  ).
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM prepare_field_catalog CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA ls_fcat TYPE lvc_s_fcat.

  ls_fcat-fieldname = 'clsname'.
  ls_fcat-inttype = 'C'.
  ls_fcat-outputlen = '30'.
  ls_fcat-coltext = 'Class Name'.
  ls_fcat-seltext = 'Class Name'.
  INSERT ls_fcat INTO TABLE pt_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'descript'.
  ls_fcat-ref_table = 'SEOCLASSTX'.
  ls_fcat-inttype = 'C'.
  ls_fcat-outputlen = '60'.
  ls_fcat-coltext = 'Class Description'.
  ls_fcat-seltext = 'Class Description'.
  INSERT ls_fcat INTO TABLE pt_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_layout  CHANGING p_gs_layout.

ENDFORM.
